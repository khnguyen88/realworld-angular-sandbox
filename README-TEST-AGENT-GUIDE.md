# Angular + Vitest Test Creation Guide (for LLMs)

> **Testing Docs Index:**
>
> - **README-TEST-AGENT-GUIDE.md** — This file: recipe book for LLMs writing tests
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — Angular 22 + PrimeNG v20+ companion cookbook
> - **README-TEST-GUIDE.md** — Human-facing tour of realworld-angular test patterns
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

## Who This Guide Is For

You are an LLM or coding agent that has been given a task like: "write tests for this Angular + Vitest codebase." This guide is your reference. It does **not** assume any specific project — every recipe is a template with `<substitution>` placeholders. The codebase under test provides the actual code.

This guide does **not** serve humans learning what the `realworld-angular` project tests. Humans should read `README-TEST-GUIDE.md` instead.

This guide is about **test quality**, not suite greenness. A codebase may have many specs and still be red because tests leak HTTP requests, reuse stale `TestBed` configuration, or assert against outdated fixtures. Use this guide to write deterministic, isolated tests; treat current suite failures as a separate cleanup task unless the user explicitly asks you to fix them.

## How to Use This Guide

1. **Pre-flight** — confirm the project setup (see §1). If pre-flight fails, stop and tell the user.
2. **Identify the file under test** — match its type to the decision tree (§2). Do not read every recipe; jump to the matching recipe.
3. **Read the source before writing** — inspect the constructor, template, injected dependencies, route entries, and public API.
4. **Substitute placeholders** — replace `<ServiceClassName>`, `<relative-path>`, and similar values from the source file.
5. **Write user-facing assertions** — assert rendered DOM, emitted values, route results, request properties, or state changes instead of private fields.
6. **Verify** — every recipe's "Common Variants" and "Pitfalls" sections list the most common LLM errors. Read them before writing.

## Universal "Always" List

Every test in this guide assumes these conventions:

- **Vitest globals**: `import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'`. Never use Jasmine's `jasmine.*` or globals.
- **TestBed + signal inputs**: after `fixture.componentRef.setInput(...)`, call `await fixture.whenStable()` before asserting on the DOM.
- **HTTP tests**: use `HttpTestingController` for Angular HTTP calls and `provideHttpClientTesting()`.
- **No leaked requests**: call `httpTesting.verify()` in `afterEach` whenever a test can create HTTP requests.
- **Reactive graphs**: call `TestBed.tick()` after signal mutations that may trigger effects, including `httpResource` reloads caused by tracked signal changes. (In Angular 22, `TestBed.flushEffects()` is deprecated in favor of `TestBed.tick()`.)
- **Substitutions**: this guide uses `<placeholder>` syntax. Replace with values from the source file.
- **Scope discipline**: do not fix unrelated failing tests, production code, or CI configuration unless the user explicitly asks.

## Table of Contents

- [§1. Pre-flight Checks](#1-pre-flight-checks)
- [§2. Decision Tree](#2-decision-tree)
- [§3. Per-Unit Recipes](#3-per-unit-recipes)
- [§4. Cross-Cutting Concerns](#4-cross-cutting-concerns)
- [§5. PrimeNG Components](#5-primeng-components)
- [§6. Common Mistakes Appendix](#6-common-mistakes-appendix)
- [§7. Quick Reference Table](#7-quick-reference-table)

## 1. Pre-flight Checks

Before writing a single test, confirm the following about the codebase. If any of these don't hold, stop and tell the user.

### 1.1 Confirm the test runner

Open `angular.json` and find the `test` target. The `builder` should be `@angular/build:unit-test` (Vitest). If it's `@angular-devkit/build-angular:karma`, the project uses Jasmine and this guide does **not** apply.

Example healthy target:

```json
"test": {
  "builder": "@angular/build:unit-test"
}
```

If the builder is `@angular/build:application` and the project uses a custom Vitest setup, confirm the actual test command from `package.json` before proceeding.

### 1.2 Confirm Vitest is installed

Open `package.json`. Look for `"vitest"` in `devDependencies` and verify `jsdom` or `happy-dom` is also present. If vitest is absent, the project is not configured for unit testing as the Angular CLI ships it.

### 1.3 Confirm the Angular version

Open `package.json` and check the `@angular/core` version. The patterns in this guide target **Angular 22+** (standalone default, signals, `httpResource`, and signal-based inputs/outputs are the default). For Angular 19 or earlier, some APIs differ (decorator-based inputs, non-default standalone, etc.) — flag this to the user before proceeding.

### 1.4 Confirm no Jasmine globals

Search the test config and a sample spec for `jasmine.`, `fit(`, `fdescribe(`, or any `tsconfig.spec.json` `types: ["jasmine"]`. If found, this is a mixed or migrating project. Most recipes still work, but `vi.fn()` should be used instead of `jasmine.createSpy()`.

### 1.5 Identify the project's testing utility conventions

Some projects have a `src/test-providers.ts` or similar global providers file referenced from `angular.json`. If present, the `beforeEach` blocks in the recipes below can drop providers that the global file already supplies. If absent (the default), every spec is self-contained — apply the recipe verbatim.

### 1.6 Check current suite health without fixing it

Run or inspect the latest test command if the user asks for suite status. If the suite is red, do not infer that the docs or recipes are wrong. Common red-suite causes are stale fixtures, unhandled HTTP requests, stale `TestBed` configuration, or expectation drift from upstream changes.

### 1.7 What to do if pre-flight fails

- **No vitest**: tell the user. Don't try to write tests; the project isn't set up for them.
- **Wrong Angular version**: ask the user. The guide's recipes need translation for v19 and earlier.
- **Mixed Jasmine/Vitest**: ask the user which runner to target, then proceed.
- **Red suite**: continue only if the user asked for new tests or documentation. Do not silently fix unrelated failures.

## 2. Decision Tree

Match the file you are testing to its recipe. Do **not** read the recipes top-to-bottom — pick the right one and jump.

| File ends in / pattern                                   | Recipe section                    |
| -------------------------------------------------------- | --------------------------------- |
| `*.pipe.ts`                                              | §3.1 Pipes                        |
| `*.service.ts` (incl. `*-api.service.ts`)                | §3.2 Services                     |
| `*.api.ts` (raw HTTP client, not injected as a service)  | §3.2 Services                     |
| `*.interceptor.ts`                                       | §3.3 Interceptors                 |
| `*.component.ts` (not a routed page — see heuristic)     | §3.4 Components                   |
| `*.dialog.ts` or imports from `@angular/cdk/dialog`      | §3.5 Dialogs & Overlays           |
| `*.store.ts` or class exposes signals + httpResource     | §3.6 Stores / State               |
| `*.guard.ts`                                             | §3.7 Guards                       |
| `*.resolver.ts`                                          | §3.8 Resolvers                    |
| `*.directive.ts`                                         | §3.9 Directives                   |
| `*.form.ts` (form definition file) or service with form  | §3.10 Forms                       |
| Signal primitives used: `linkedSignal`, `effect`, etc.   | §3.11 Signal Primitives           |
| Component template uses `@defer`                         | §3.12 @defer Blocks               |
| Routed page (has a route entry, top-level for a feature) | §3.13 Page Components             |
| Component uses `p-*` tags or `primeng/*` imports         | §5 PrimeNG Components (companion) |
| `*.routes.ts` (route config files)                       | **Do not write tests**            |

**Page vs component heuristic**: a _page_ is the component referenced directly by a route's `component:` field (or loaded by a lazy route). A _component_ is everything else — dialogs, cards, list items, form fields, layout pieces. If you're not sure, check `*.routes.ts` files for the path-to-component mapping.

**When in doubt**: read the source file's constructor and template. The constructor tells you what dependencies to mock; the template tells you what DOM to assert on. Both are required to write a useful test.

## 3. Per-Unit Recipes

### 3.1 Pipes

#### What to test

- Valid input → expected output
- Edge cases: empty string, `null`, `undefined`
- Encoding/escaping if the pipe builds URLs or HTML
- The "every regex branch" rule — if the pipe uses a regex, every branch of the regex must be tested

#### Pre-flight

- Read the pipe's `transform()` signature — note parameter types and return type.
- Note any constructor dependencies (rare for pure pipes, common for stateful ones).
- Read the source for any regex patterns and list every branch.

#### Recipe template

```typescript
import { describe, it, expect } from 'vitest';
import { <PipeName> } from '<relative-path-to-pipe>';

describe('<PipeName>', () => {
  const pipe = new <PipeName>(/* <constructor-args> */);

  it('should <expected-behavior-on-valid-input>', () => {
    const result = pipe.transform(<valid-input>);
    expect(result).toBe(<expected-output>);
  });

  it('should handle <edge-case>', () => {
    const result = pipe.transform(<edge-input>);
    expect(result).toBe(<expected-edge-output>);
  });
});
```

#### Common variants

- **Pipe with one input arg** — direct call: `pipe.transform(input, arg1)`.
- **Pipe with regex** — write one `it()` per regex branch, naming the branch explicitly.
- **Stateful pipe** (rare) — if the pipe has internal state, use `TestBed.configureTestingModule` and `TestBed.createComponent` with a host component that exercises it through a template binding.

#### Pitfalls

- **Wrapping in TestBed for no reason** — pure pipes don't need it. If the recipe template doesn't show `TestBed`, don't add it.
- **Forgetting `null`/`undefined`** — pure pipes are commonly called with nullable values from templates. Test those cases.
- **URL encoding** — if the pipe builds a URL, the assertion should check the encoded form, not the raw form. `expect(result).toContain(encodeURIComponent('value with spaces'))`.

### 3.2 Services

#### What to test

- Initial state (every signal is at its declared default)
- Every public method: the URL, HTTP method, body, and post-response state
- Both success and error paths for every HTTP call
- `httpResource` (if used): assert `value()`, `isLoading()`, `status()`
- `effect()`-driven HTTP (if the service uses `linkedSignal` or `effect` to trigger calls): flush with `TestBed.tick()`

#### Pre-flight

- List every public method on the class.
- For each method, note the HTTP verb, URL pattern, request body shape, and response shape.
- List signals and computed signals — these are the post-call state to assert on.
- Identify any methods that use `httpResource` or trigger HTTP via effects.

#### Recipe template (HTTP service)

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { <ServiceName> } from '<relative-path-to-service>';

const <mockResponseName> = <shape-of-success-response>;

describe('<ServiceName>', () => {
  let service: <ServiceName>;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClientTesting()],
    });
    service = TestBed.inject(<ServiceName>);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify(); // catches leaked requests
  });

  it('should have <signal-name> in its initial state', () => {
    expect(service.<signal-name>()).toBe(<initial-value>);
  });

  it('should <behavior> on success', () => {
    service.<methodName>(<args>).subscribe();
    const req = httpTesting.expectOne('<url-pattern>');
    expect(req.request.method).toBe('<VERB>');
    expect(req.request.body).toEqual(<body-shape>);
    req.flush(<mockResponseName>);
    expect(service.<signal-name>()).toEqual(<expected-post-state>);
  });

  it('should <behavior> on error', () => {
    service.<methodName>(<args>).subscribe();
    const req = httpTesting.expectOne('<url-pattern>');
    req.flush('<error-message>', { status: <code>, statusText: '<text>' });
    expect(service.<signal-name>()).toBe(<error-state-value>);
  });
});
```

#### Common variants

- **httpResource-based service** — the resource fires automatically; use `TestBed.tick()` to drive the initial request, then `httpTesting.expectOne(...).flush(...)`, then `await TestBed.inject(ApplicationRef).whenStable()` or assert after the fixture stabilizes.
- **httpResource reloads** — after tracked source signals change, use `TestBed.tick()` to drive the new request, then flush and stabilize again.
- **Service with `effect()` calling another method** — call `TestBed.tick()` after the mutation that should trigger the effect.
- **Service with no HTTP** — drop `provideHttpClientTesting()`; `TestBed.inject(<ServiceName>)` alone is enough.
- **Async service returning `Promise<T>`** — use `await service.method()`; `expectOne()` still works because `HttpTestingController` intercepts before the promise resolves.

#### Pitfalls

- **Forgetting `httpTesting.verify()`** — un-flushed requests fail the test, but a missing afterEach hook means the suite still passes while leaking requests. Always include it.
- **Asserting only on the request, not the state** — the _interesting_ assertion is what the signal looks like after the response. Always assert both.
- **`new <ServiceName>(...)` instead of `TestBed.inject`** — DI wiring (interceptors, multi-providers) doesn't apply to direct construction. Always inject.
- **Wrong URL matcher** — `expectOne` matches by URL and method. If the test fails with "no matching request", check that the URL string matches exactly, including query params.

### 3.3 Interceptors

#### What to test

- The interceptor **modifies** the outgoing request as expected (adds header, sets `withCredentials`, rewrites URL)
- The interceptor does **not** modify requests it should skip
- Response transformation (if the interceptor does post-response work) is correct

#### Pre-flight

- Identify the _trigger_ — what request characteristic causes the interceptor to act (URL pattern, header presence, method, etc.)
- Identify the _action_ — what does the interceptor do? Header? URL rewrite? `withCredentials`?
- Identify the _negative case_ — what requests should be left alone?

#### Recipe template

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { HttpClient } from '@angular/common/http';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { <interceptorName> } from '<relative-path>';

describe('<interceptorName>', () => {
  let http: HttpClient;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(withInterceptors([<interceptorName>])),
        provideHttpClientTesting(),
      ],
    });
    http = TestBed.inject(HttpClient);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should <action> on <trigger-condition>', () => {
    http.<method>(<url>).subscribe();
    const req = httpTesting.expectOne(<url>);
    expect(req.request.<property>).toBe(<expected-value>);
    req.flush(<response-body>);
  });

  it('should NOT <action> on <negative-case>', () => {
    http.<method>(<negative-url>).subscribe();
    const req = httpTesting.expectOne(<negative-url>);
    expect(req.request.<property>).toBe(<negative-expected-value>);
    req.flush(<response-body>);
  });
});
```

#### Common variants

- **Header-adding interceptor** — assert `req.request.headers.get('X-Foo')`.
- **withCredentials toggle** — assert `req.request.withCredentials` boolean.
- **URL-rewriting interceptor** — assert the URL on `req.request.url` matches the rewritten form, not the original.
- **Response mapper** — subscribe to the response, assert the transformed value, not the raw body.

#### Pitfalls

- **Forgetting `withInterceptors([...])` in the test providers** — the interceptor is registered through the providers list, not by direct injection. Forgetting it means the request goes through unmodified.
- **Asserting on the `HttpClient` call, not the captured request** — the side effect of the interceptor is visible on `req.request`, not on the `http.get(...)` call. Capture the request first.
- **One test, two requests** — if a single test issues multiple requests, use `match()` (returns array) instead of `expectOne()` (returns single).

### 3.4 Components

#### What to test

- The component renders the correct DOM given its inputs
- CSS classes / styles reflect input values
- The component shows / hides elements based on state
- `output()` emissions fire on user interaction (button click, form submit, etc.)
- ARIA attributes for accessibility (`role`, `aria-*`, `aria-busy` on loading elements)
- Disabled, loading, and active states

#### Pre-flight

- List every `input()` (signal-based) and `@Input()` (decorator-based). These drive the test inputs.
- List every `output()` signal. These drive the test subscriptions.
- Read the template to identify the key DOM queries you'll need (CSS class names, ARIA attributes, structural directives).
- Identify the host element's `host:` bindings if any (these are tested on `fixture.nativeElement`).

#### Recipe template (querySelector + NO_ERRORS_SCHEMA — pragmatic)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { describe, it, expect, beforeEach } from 'vitest';
import { <ComponentName> } from '<relative-path>';

describe('<ComponentName>', () => {
  let fixture: ComponentFixture<<ComponentName>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({}).overrideComponent(<ComponentName>, {
      set: { schemas: [NO_ERRORS_SCHEMA] },
    });
    fixture = TestBed.createComponent(<ComponentName>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should <expected-render-behavior>', async () => {
    fixture.componentRef.setInput('<input-name>', <value>);
    await fixture.whenStable();
    expect(el.querySelector('<selector>')).not.toBeNull();
  });

  it('should emit <output-name> on <user-action>', async () => {
    const emitted: <output-type>[] = [];
    const sub = fixture.componentInstance.<outputName>.subscribe((v) => emitted.push(v));
    el.querySelector<HTMLElement>('<selector>')!.click();
    expect(emitted).toEqual(<expected-emissions>);
    sub.unsubscribe();
  });
});
```

`NO_ERRORS_SCHEMA` lets the test ignore child component selectors. Each child has its own tests. Use it when the test is about _this_ component, not the integration with its children. Do not use it when the test's point is to verify child rendering, child events, or parent/child integration.

#### Common variants

- **Component with harness (recommended for shared components)** — replace the `el.querySelector(...)` block with `loader.getHarness(<HarnessClass>)`. Use harnesses when the component is shared (Button, Input, Modal) because template refactors cascade.
- **Component with form** — see §3.10 Forms.
- **Component with router outlet** — see §3.13 Page Components.
- **Component that uses `output()`** — subscribe to `componentInstance.<outputName>` and assert the captured emissions. Unsubscribe in cleanup or use a `takeUntil(destroyed)` pattern.
- **Component with host bindings** — assert on `fixture.nativeElement` directly (`el.getAttribute('role')`, `el.classList.contains(...)`, `el.style.<property>`).
- **Component with PrimeNG or external components** — read the Angular 22 + PrimeNG v20+ companion guide. Query the configured PrimeNG MCP when available for current selectors/events; if it is not visible, use the versioned PrimeNG docs or the component source.

#### Pitfalls

- **Forgetting `await fixture.whenStable()` after `setInput`** — signal inputs propagate asynchronously in some test setups. The set-and-assert path will silently fail.
- **Asserting on child component internals** — if a child is `NO_ERRORS_SCHEMA`'d away, `el.querySelector('.child-class')` will return null. Use real imports if the test needs to assert on child DOM.
- **Subscribing without unsubscribing** — signal outputs hold the subscription until the component is destroyed. The test will pass, but the listener leaks. Unsubscribe or use the test teardown.
- **Clicking the wrong element** — if the test selector matches multiple elements (`querySelectorAll`), `.click()` on the first one might not be the one you meant. Use a more specific selector.
- **Hardcoding child element structure** — `NO_ERRORS_SCHEMA` is appropriate only when child internals are not the test's concern. If they are, override with real imports.

### 3.5 Dialogs & Overlays

#### What to test

- The dialog renders content from `DIALOG_DATA`
- The close button calls `DialogRef.close()` (with or without a result)
- ARIA attributes on the panel (`role="document"` or `role="dialog"`, `aria-label` on the close button)
- Conditional rendering when optional `DIALOG_DATA` fields are missing
- Form submission inside a dialog: HTTP fires, dialog closes

#### Pre-flight

- Read the constructor to confirm `DialogRef` and `DIALOG_DATA` are injected.
- Identify the result type (`R` in `DialogRef<R>`) — the test will stub the close method to assert the result.
- List the dialog's `input()` / `@Input()` and any conditional rendering on data fields.

#### Recipe template (CDK dialog with data)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { DIALOG_DATA, DialogRef } from '@angular/cdk/dialog';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { <DialogComponent>, <DialogData>, <DialogResult> } from '<relative-path>';

describe('<DialogComponent>', () => {
  let fixture: ComponentFixture<<DialogComponent>>;
  let el: HTMLElement;
  let closeFn: ReturnType<typeof vi.fn>;

  const <defaultDataVar>: <DialogData> = <default-data-shape>;

  beforeEach(async () => {
    closeFn = vi.fn();
    TestBed.configureTestingModule({
      providers: [
        { provide: DialogRef<<DialogResult>>, useValue: { close: closeFn } },
        { provide: DIALOG_DATA, useValue: <defaultDataVar> },
      ],
    }).overrideComponent(<DialogComponent>, { set: { schemas: [NO_ERRORS_SCHEMA] } });
    fixture = TestBed.createComponent(<DialogComponent>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <data-field> from data', () => {
    expect(el.textContent).toContain(<expected-text>);
  });

  it('should close the dialog when <close-button> is clicked', () => {
    el.querySelector<HTMLButtonElement>('<close-button-selector>')!.click();
    expect(closeFn).toHaveBeenCalledWith(<expected-result>);
  });
});
```

#### Common variants

- **Dialog with form + HTTP** — add `provideHttpClientTesting()`, prefer scoped providers or `overrideProvider()` for per-test data, and use `TestBed.tick()` after form mutations.
- **Dialog opened by `DialogService.open()`** — the parent component test stubs `DialogService` with `{ open: vi.fn().mockReturnValue(<ref>) }` and asserts `open` was called with the right config.
- **Reconfiguring `DIALOG_DATA` mid-suite** — prefer scoped provider setup or `overrideProvider()`; use `TestBed.resetTestingModule()` only when a fresh TestBed is truly needed.
- **Dialog with `inject(DialogRef)` (newer pattern)** — same stub, but the component doesn't take it via constructor; the test provides it through `providers:` and DI resolves it.

#### Pitfalls

- **Stubbing `DialogRef` as a class** — the simplest stub is `{ close: vi.fn() }` as a `useValue`. Don't use `useClass` or a real instance.
- **Reusing `DIALOG_DATA` across tests with different data** — scope the provider setup or override the provider when data changes; don't reset the whole TestBed unless necessary.
- **Not asserting the close result** — `closeFn` should be called with the form value (or whatever the dialog returns). `expect(closeFn).toHaveBeenCalledWith(...)` is the test.
- **Hanging on `await dialogRef.closed`** — if the test awaits the closed promise, it will hang forever because the stubbed `close` is a `vi.fn()` that doesn't return an observable. Stub the close, don't await the closed promise.

### 3.6 Stores / State

#### What to test

- Initial state (empty items, null values, `isEmpty = true`)
- Adding / removing items
- Cross-entity constraints (e.g., can't add items from different parent entities)
- Side effects (HTTP triggered by state changes)
- Negative: no HTTP when state is empty or no-op

#### Pre-flight

- List every public method and what state it mutates.
- Identify which methods trigger HTTP (directly or via `effect()`/`linkedSignal()`).
- Identify which computed signals derive from the state.
- Note any cross-entity constraints (e.g., "if the new item's parent ID differs, reset").

#### Recipe template (httpResource-based store)

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { <StoreName> } from '<relative-path>';

const <mockDataName> = <shape-of-store-data>;

describe('<StoreName>', () => {
  let store: <StoreName>;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClientTesting()],
    });
    store = TestBed.inject(<StoreName>);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  describe('initial state', () => {
    it('should have <state-field> in initial state', () => {
      expect(store.<state-field>()).toEqual(<initial-value>);
    });

    it('should not make an HTTP request when empty', () => {
      TestBed.tick();
      httpTesting.expectNone(() => true);
    });
  });

  describe('<methodName>()', () => {
    it('should <behavior> and <state-mutation>', () => {
      store.<methodName>(<args>);
      expect(store.<state-field>()).toEqual(<expected-state>);
    });

    it('should trigger an HTTP request on <condition>', () => {
      store.<methodName>(<args>);
      TestBed.tick();
      const reqs = httpTesting.match((r) => r.url.includes('<url-fragment>'));
      reqs.forEach((r) => r.flush(<mockDataName>));
    });
  });
});
```

#### Common variants

- **Store with `httpResource` only** — use `TestBed.tick()` for the initial request and for reloads caused by tracked signal changes, then `expectOne`/`match` and `flush`.
- **Store with `effect()`-driven HTTP** — call `TestBed.tick()` after every mutation. If a mutation triggers two requests (e.g., the action + a side effect), `match()` returns both, flush each.
- **Store with cross-entity constraint** — add an `it()` that performs the violating action and asserts the state was reset.
- **Store with `linkedSignal` reset** — add an `it()` that changes the source signal, then asserts the linked signal reset to the new derived value.

#### Pitfalls

- **Forgetting to drive `httpResource`** — call `TestBed.tick()` after construction or after tracked signal changes. Without it, the test runs zero HTTP and `expectOne` fails with "no matching request."
- **Using `expectOne` when the action triggers multiple requests** — switch to `match()` (returns array) and flush each.
- **Asserting on `value()` of an unresolved resource** — the resource is loading; `value()` is `undefined`. Flush the request first.
- **Not testing the "no HTTP when empty" case** — the negative assertion (`expectNone`) is one of the most useful tests for a store. Don't skip it.

### 3.7 Guards

#### What to test

- Returns `true` when the condition is met
- Returns a `UrlTree` (redirect) when the condition is not met — and assert the **specific** redirect path, not just the type
- Async guards (returning `Observable<boolean | UrlTree>`): subscribe, flush the HTTP request, assert the captured result

#### Pre-flight

- Identify the guard's type: `CanMatchFn`, `CanActivateFn`, or class-based.
- Note the redirect target (`router.createUrlTree(['/path'])`) — this is what the test asserts.
- For async guards, identify which HTTP call the guard makes.

#### Recipe template (functional CanMatchFn, sync)

```typescript
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, UrlTree, PartialMatchRouteSnapshot } from '@angular/router';
import { describe, it, expect, beforeEach, vi, type Mocked } from 'vitest';
import { <guardName> } from '<relative-path>';
import { <AuthService> } from '<path-to-auth-service>';

const <stubName>: Mocked<Pick<<AuthService>, '<method-name>'>> = {
  <method-name>: vi.fn(),
};

describe('<guardName>', () => {
  let router: Router;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideRouter([]), { provide: <AuthService>, useValue: <stubName> }],
    });
    router = TestBed.inject(Router);
  });

  it('should return true when <condition-met>', () => {
    <stubName>.<method-name>.mockReturnValue(<condition-met-value>);
    const result = TestBed.runInInjectionContext(() =>
      <guardName>({ path: '' }, [], {} as PartialMatchRouteSnapshot),
    );
    expect(result).toBe(true);
  });

  it('should redirect to <expected-path> when <condition-failed>', () => {
    <stubName>.<method-name>.mockReturnValue(<condition-failed-value>);
    const result = TestBed.runInInjectionContext(() =>
      <guardName>({ path: '' }, [], {} as PartialMatchRouteSnapshot),
    );
    expect(result).toBeInstanceOf(UrlTree);
    expect(router.serializeUrl(result as UrlTree)).toBe('<expected-path>');
  });
});
```

#### Common variants

- **Async guard (Observable return)** — wrap the guard call in `(TestBed.runInInjectionContext(() => <guardName>(...)) as Observable<...>).subscribe(r => result = r)`, then `httpTesting.expectOne(<url>).flush(<response>)`, then assert on `result`.
- **Multi-step guard** (e.g., checkout wizard) — use `provideRouter(testRoutes)` so the guard can find prerequisite step URLs.
- **Class-based guard** (legacy) — `TestBed.inject(<GuardClass>)`, then call `guard.canMatch(...)` or `guard.canActivate(...)` directly.
- **Zero-arg guard** (`CanMatchFn = () => ...`) — the project pattern. Call as `<guardName>()` with no args. The 3-arg form above still works (TypeScript tolerates extra args), but a zero-arg call is cleaner.

#### Pitfalls

- **Asserting only `expect(result).toBeInstanceOf(UrlTree)`** — that's a type check, not a behavior check. Always serialize and compare: `expect(router.serializeUrl(result as UrlTree)).toBe('/expected/path')`.
- **Missing `runInInjectionContext`** — functional guards use `inject()` internally. Without the injection context, the test fails with "no provider for X."
- **Wrong 3rd argument type** — `PartialMatchRouteSnapshot` is the correct type. Casting to `Route` for the first arg with `as Route` is fine.
- **Async guard test doesn't flush HTTP** — the guard returns an Observable that emits when HTTP completes. The test must flush the request before asserting.
- **Missing `provideRouter([])`** — `UrlTree` serialization requires a real `Router`. Even with empty routes, the provider is needed.

### 3.8 Resolvers

#### What to test

- Resolver fetches data and returns it to the route
- Resolver handles 404 (returns `EMPTY`, `null`, or redirects)
- Resolver handles 500 / network error
- Resolved data is available to the routed component via `input()` signals (when `withComponentInputBinding()` is used)

#### Pre-flight

- Identify the resolver's `ResolveFn<T>` return type.
- Note the HTTP call (URL, method, response shape).
- Identify the routed component and the `input()` signal that receives the resolved data.

#### Recipe template (RouterTestingHarness + withComponentInputBinding)

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { <resolverName> } from '<relative-path>';
import { <RoutedComponent> } from '<relative-path>';

const <mockData> = <response-shape>;

describe('<resolverName>', () => {
  let harness: RouterTestingHarness;
  let httpTesting: HttpTestingController;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClientTesting(),
        provideRouter(
          [{ path: '<path>', component: <RoutedComponent>, resolve: { <key>: <resolverName> } }],
          withComponentInputBinding(),
        ),
      ],
    });
    harness = await RouterTestingHarness.create();
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should resolve data and pass it to the component', async () => {
    const component = await harness.navigateByUrl('<url>', <RoutedComponent>);
    const req = httpTesting.expectOne('<url>');
    req.flush(<mockData>);
    harness.detectChanges();
    expect(component.<inputName>()).toEqual(<mockData>);
  });

  it('should cancel navigation on 404', async () => {
    await harness.navigateByUrl('<url>');
    httpTesting.expectOne('<url>').flush('Not found', { status: 404, statusText: 'Not Found' });
    expect(harness.router.url).toBe('/');
  });
});
```

#### Common variants

- **Resolver returning `EMPTY` on error** — assert the route didn't activate.
- **Resolver that redirects on error** — assert the URL is the redirect target.
- **Class-based resolver** — `TestBed.inject(<ResolverClass>)`, call `.resolve(...)` directly.

#### Pitfalls

- **Forgetting `withComponentInputBinding()`** — without it, the resolved data isn't mapped to the component's `input()` signals. The assertion on `component.<input>()` will return `undefined`.
- **Not calling `harness.detectChanges()`** — after flushing HTTP, the binding to the input signal needs a change detection cycle.
- **Asserting against the harness root element** — `harness.routeNativeElement` is the _outlet's_ rendered element, not the routed component's. Use the returned component instance from `navigateByUrl` for typed assertions.

### 3.9 Directives

#### What to test

- DOM manipulation effect (added/removed elements, style changes)
- Reactivity to input changes (signal updates, value changes)
- Every branch: different roles, `else` template, null state
- Negative cases: elements WITHOUT the directive are unaffected

#### Pre-flight

- Read the directive's selector and the inputs it accepts.
- Identify every template branch the directive can render (default, else, role-based).
- Note the directive's host element — the `TestHostComponent` template must place the directive on a real element.

#### Recipe template (host component pattern)

```typescript
import { Component } from '@angular/core';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';
import { <DirectiveName> } from '<relative-path>';

@Component({
  imports: [<DirectiveName>],
  template: `
    <span *<directiveSelector>="<value1>" id="<id-1>"><content-1></span>
    <span *<directiveSelector>="<value2>" id="<id-2>"><content-2></span>
    <ng-template #<elseTpl>><span id="<else-id>"><else-content></span></ng-template>
  `,
})
class TestHostComponent {}

describe('<DirectiveName>', () => {
  let fixture: ComponentFixture<TestHostComponent>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(TestHostComponent);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should <positive-case>', () => {
    expect(el.querySelector('#<id>')).not.toBeNull();
  });

  it('should <negative-case>', () => {
    expect(el.querySelector('#<id>')).toBeNull();
  });
});
```

#### Common variants

- **Directive with input signal** — `fixture.componentRef.setInput('<input-name>', <value>)` and re-create the host component, or use a host component that exposes a signal.
- **Directive with reactive input** — the host component has a signal; the directive reads it. Mutate the signal, `await fixture.whenStable()`, assert DOM updated.
- **Attribute directive (no structural `*` syntax)** — the test host uses `[<directiveSelector>]="<value>"` instead of `*<directiveSelector>`.

#### Pitfalls

- **Forgetting `imports: [<DirectiveName>]`** — directives in standalone components must be explicitly imported.
- **Asserting against a removed element** — when the directive hides content, the test should assert `expect(el.querySelector('#id')).toBeNull()`, not just check the inner text.
- **Not testing reactivity** — at least one test must change a signal/value and assert the DOM updated after `whenStable()`. Static-state-only tests miss half the directive's behavior.

### 3.10 Forms

#### What to test

- Initial values (every field's default)
- Computed values derived from form state (totals, validations)
- Field-level validation (required, format, min/max)
- Cross-field effects (e.g., "use same as billing" clears billing fields)
- Form submission: HTTP fires, success state, error state

#### Pre-flight

- Identify the form library: **signal forms** (Angular v22+ stable), **reactive forms** (`@angular/forms`), or **template-driven forms**.
- List every form control and its initial value.
- Identify computed signals that derive from form state — these are the _interesting_ assertions.
- Note any `effect()` that watches form state and triggers side effects.

#### Recipe template (signal forms)

`form()` takes a `WritableSignal<TModel>` (not a plain object). The typical pattern when testing a service is to inject the real service and interact with its own form tree directly. When you need to construct a form tree inline in a test, create the model signal first.

```typescript
import { TestBed } from '@angular/core/testing';
import { signal } from '@angular/core';
import { form } from '@angular/forms/signals';
import { describe, it, expect, beforeEach } from 'vitest';
import { <ServiceName> } from '<relative-path>';

describe('<ServiceName>', () => {
  let service: <ServiceName>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      // <providers-needed-by-the-service>
    });
    service = TestBed.inject(<ServiceName>);
  });

  it('should have <field-name> in initial state', () => {
    // Access the service's own FieldTree — don't reconstruct it in the test
    expect(service.<formTree>.<field-name>().value()).toBe('<initial-value>');
  });

  it('should compute <derived-signal> from form state', () => {
    service.<formTree>.<field-name>().value.set('<new-value>');
    TestBed.tick();
    expect(service.<derivedSignal>()).toBe(<expected-derived-value>);
  });

  it('should <cross-field-effect> when <trigger-field> changes', () => {
    service.<formTree>.<field1>().value.set('<value-1>');
    service.<formTree>.<field2>().value.set('<value-2>');
    TestBed.tick();
    expect(service.<formTree>.<field3>().value()).toBe('<expected-cleared-value>');
  });
});
```

When you need a standalone form tree in a test (e.g., for a custom form control test), create the model signal explicitly:

```typescript
import { signal } from '@angular/core';
import { form } from '@angular/forms/signals';

const model = signal({ <field-name>: '<initial-value>' });
const formTree = form(model);
// formTree.<field-name>().value() === '<initial-value>'
// formTree.<field-name>().value.set('<new-value>') also updates model()
```

#### Common variants

- **Reactive forms** — use `ReactiveFormsModule` in the host component's `imports:`, manipulate `fixture.componentInstance.form.controls.<name>`, and call `fixture.detectChanges()` (no `TestBed.tick()` needed for form value changes).
- **Form with HTTP submission** — add `provideHttpClientTesting()` to providers, assert on the request body and post-submit state.
- **Form with wizard steps** — each step is its own `describe` block; step transitions are tested via the service's `next()`/`previous()` methods.

#### Pitfalls

- **Mutating the wrong control** — signal forms: call `service.<formTree>.<field>().value.set(...)`, NOT `service.<form>.controls.<field>.setValue(...)` (that's reactive forms). FieldTree navigation is depth-first dot access, not `.controls[]`.
- **Forgetting `TestBed.tick()` after a mutation** — derived signals and effects need the reactive cycle to fire.
- **Passing a plain object to `form()`** — `form()` requires a `WritableSignal<TModel>`, not a plain object. Create `const model = signal({...})` first, then `form(model)`.
- **Trying to import `FieldTree` as a value** — `FieldTree` is a TypeScript type, not a runtime value. Use `import type { FieldTree } from '@angular/forms/signals'` or let TypeScript infer it.

### 3.11 Signal Primitives (`linkedSignal`, `effect`, `afterRenderEffect`)

#### What to test

- `linkedSignal`: default value derived from source, manual override, reset on source change, override preserved when still valid
- `effect`: runs at least once, re-runs when tracked signals change, cleanup runs before next run, never propagates state
- `afterRenderEffect`: phase ordering (`earlyRead` → `write` → `mixedReadWrite` → `read`), write phase receives prior read data, never runs during SSR

#### Pre-flight

- Identify which signal primitive(s) the unit uses.
- For `effect`, identify the tracked signals (read inside the effect body) and any cleanup logic (`onCleanup`).
- For `afterRenderEffect`, identify the phase callbacks the unit uses.

#### Recipe template (linkedSignal in a component)

```typescript
import { Component, signal, linkedSignal } from '@angular/core';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

@Component({
  selector: 'app-<name>',
  template: `<!-- minimal template -->`,
})
class <TestComponent> {
  readonly <sourceName> = signal(<initial-source-value>);
  readonly <derivedName> = linkedSignal(() => this.<sourceName>()[0]);
}

describe('<linkedSignal-name>', () => {
  let fixture: ComponentFixture<<TestComponent>>;
  let component: <TestComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(<TestComponent>);
    component = fixture.componentInstance;
  });

  it('should default to the first <source-item>', () => {
    expect(component.<derivedName>()).toBe(<first-source-item>);
  });

  it('should allow manual override', () => {
    component.<derivedName>.set(<override-value>);
    expect(component.<derivedName>()).toBe(<override-value>);
  });

  it('should reset when <source> changes', () => {
    component.<derivedName>.set(<override-value>);
    component.<sourceName>.set(<new-source-values>);
    TestBed.tick();
    expect(component.<derivedName>()).toBe(<new-first-item>);
  });
});
```

#### Common variants

- **`effect` outside a component** — wrap in `TestBed.runInInjectionContext(() => effect(() => { ... }))`, then `TestBed.tick()` to drive it.
- **`effect` with cleanup** — pass `(onCleanup) => { ... }` to `effect`; capture cleanup calls in an array; assert the array after a `counter.set(1)` and `TestBed.tick()`.
- **`afterRenderEffect`** — use `await fixture.whenStable()` to let the render cycle complete. Phase callback receives prior phase's return value as a signal.

#### Pitfalls

- **Creating `effect` outside an injection context** — must be in a constructor or `TestBed.runInInjectionContext()`. Otherwise, `inject()` calls inside fail.
- **Asserting on the linkedSignal after a source change without `TestBed.tick()`** — the reset is effect-driven; without flushing, the assertion sees the stale override.
- **Using `effect` to propagate state** — that's `computed` or `linkedSignal`'s job. `effect` is for side effects (logging, persistence, canvas). If the test asserts the effect's body mutates a signal, that's an anti-pattern.

### 3.12 @defer Blocks

#### What to test

- Placeholder content renders before the trigger condition is met
- Loading content renders while the deferred content is fetching
- Deferred content renders after the trigger activates
- Error content renders if the deferred load fails

#### Pre-flight

- Identify the `@defer` trigger (`(on viewport)`, `(on interaction)`, `(when <condition>)`).
- Identify each block: `@placeholder`, `@loading`, `@error`, and the main deferred content.

#### Recipe template (Manual behavior)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Component } from '@angular/core';
import { DeferBlockBehavior, DeferBlockState } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

@Component({
  selector: 'app-heavy',
  template: '<p>Heavy component loaded!</p>',
})
class HeavyComponent {}

@Component({
  imports: [HeavyComponent],
  template: `
    @defer (when <condition-name>) {
      <app-heavy />
    } @placeholder {
      <p>Placeholder content</p>
    } @loading {
      <p>Loading...</p>
    } @error {
      <p>Failed to load</p>
    }
  `,
})
class TestDeferComponent {
  <condition-name> = false;
}

describe('@defer blocks', () => {
  let fixture: ComponentFixture<TestDeferComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      deferBlockBehavior: DeferBlockBehavior.Manual,
    });
    fixture = TestBed.createComponent(TestDeferComponent);
  });

  it('should render placeholder by default', async () => {
    expect(fixture.nativeElement.innerHTML).toContain('Placeholder content');
  });

  it('should render loading state', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Loading);
    expect(fixture.nativeElement.innerHTML).toContain('Loading...');
  });

  it('should render deferred content in complete state', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Complete);
    expect(fixture.nativeElement.innerHTML).toContain('Heavy component loaded!');
  });

  it('should render error state when deferred load fails', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Error);
    expect(fixture.nativeElement.innerHTML).toContain('Failed to load');
  });
});
```

#### Common variants

- **`Manual` behavior (test default)** — `TestModuleMetadata.deferBlockBehavior` defaults to `Manual` in Angular 22 tests, so explicit configuration is optional. Use `Playthrough` if you want the block to advance naturally like it would in a browser.
- **Multiple `@defer` blocks in one component** — `(await fixture.getDeferBlocks())[0]` vs `[1]` etc.
- **`@defer (on viewport)`** — switching to `Playthrough` is simpler; `Manual` requires simulating the viewport trigger.

#### Pitfalls

- **Forgetting `await` on `getDeferBlocks()`** — it returns a `Promise<DeferBlockFixture[]>`.
- **Asserting on placeholder content after `render(Loading)`** — once you advance the state, the placeholder is gone. Assert before `render()` for placeholder, after for everything else.
- **Forgetting `DeferBlockBehavior.Manual`** — without it, the block plays through states before you can assert, and the placeholder test fails.

### 3.13 Page Components (Smart / Container)

#### What to test

- Renders the correct UI for each logical state: loading, empty, error, populated
- Makes the correct HTTP requests with the right params
- Reacts to child component events (pagination clicks, search input)
- Composes child components correctly

#### Pre-flight

- Identify the page's route — the path that loads it. Use `provideRouter` with the route config in tests.
- List every HTTP call the page makes (initial load, search, pagination).
- Identify the logical states (loading, empty, error, populated) and the DOM that signals each.

#### Recipe template (RouterTestingHarness + real imports)

Use this pattern when the test is about routing context, redirects, guards, resolvers, route parameters, or parent/child page integration. For a quick isolated page smoke test, `provideRouter([])` and `NO_ERRORS_SCHEMA` can be acceptable, but it will not prove child integration.

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { provideRouter } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { <PageComponent> } from '<relative-path>';
import { <ChildA>, <ChildB> } from '<relative-paths>';

const <mockData> = <response-shape>;

describe('<PageComponent>', () => {
  let harness: RouterTestingHarness;
  let httpTesting: HttpTestingController;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClientTesting(),
        provideRouter([{ path: '<path>', component: <PageComponent> }]),
      ],
    });
    harness = await RouterTestingHarness.create();
    await harness.navigateByUrl('<url>');
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should show <loading-indicator> before response', () => {
    expect(harness.routeNativeElement?.querySelector('<loading-selector>')).not.toBeNull();
    httpTesting.expectOne((r) => r.url.includes('<url-fragment>')).flush(<empty-mock-data>);
  });

  it('should render <content> after success', async () => {
    httpTesting.expectOne((r) => r.url.includes('<url-fragment>')).flush(<mockData>);
    await harness.fixture.whenStable();
    expect(harness.routeNativeElement?.textContent).toContain('<expected-text>');
  });

  it('should show <error-callout> on HTTP error', async () => {
    httpTesting
      .expectOne((r) => r.url.includes('<url-fragment>'))
      .flush('Server error', { status: 500, statusText: 'Internal Server Error' });
    await harness.fixture.whenStable();
    expect(harness.routeNativeElement?.querySelector('<error-selector>')).not.toBeNull();
  });

  it('should <behavior> when <child-event> fires', async () => {
    httpTesting.expectOne((r) => r.url.includes('<url-fragment>')).flush(<mockData>);
    await harness.fixture.whenStable();

    // Trigger the child event
    const child = harness.fixture.debugElement.query(/* By.directive(<ChildA>) */);
    child.triggerEventHandler('<event-name>', <event-payload>);
    TestBed.tick();

    const req2 = httpTesting.expectOne((r) => r.url.includes('<url-fragment>'));
    expect(req2.request.params.get('<param>')).toBe('<expected-value>');
    req2.flush(<mockData>);
    await harness.fixture.whenStable();
  });
});
```

#### Common variants

- **Page smoke test with `TestBed.createComponent`** — `realworld-angular` uses `TestBed.configureTestingModule({ providers: [provideHttpClientTesting(), provideRouter([])] })` plus `TestBed.createComponent(<PageComponent>)` for pages that don't need route-transition assertions. This is the pragmatic project pattern; use `RouterTestingHarness` when navigation, guards, resolvers, or child-event routing matter.
- **Page with `httpResource`** — the resource fires on component construction or route activation. Call `TestBed.tick()`, then `expectOne`/`match` and `flush`.
- **Page with guards** — the harness navigates; the guard runs; assert on the final URL.
- **Page with multiple child components** — test each child interaction in its own `it()`.

#### Pitfalls

- **Using `NO_ERRORS_SCHEMA` for the whole page** — this hides the child's DOM. For page tests, prefer real imports of children so child-event assertions can fire.
- **Asserting on `harness.fixture.nativeElement` instead of `harness.routeNativeElement`** — the harness's fixture is the _root component containing the outlet_. The routed page renders inside `routeNativeElement`.
- **Not testing the empty state** — most pages have an "empty list" state. The mock data with an empty array is the easiest test to write and one of the most useful.
- **Not flushing effects between event and assertion** — the event handler may trigger a reactive update; without `TestBed.tick()`, the second `expectOne` fails.
- **Skipping route-sensitive behavior** — if the user's task involves navigation, redirects, guards, or resolvers, use `RouterTestingHarness` rather than direct component creation.

## 4. Cross-Cutting Concerns

These patterns apply across multiple recipes. Read this section once, then refer back as needed.

### 4.1 Async testing with Vitest

Vitest provides Vitest-native async helpers. Use them in place of Jasmine patterns:

- **`vi.waitFor(fn)`** — poll `fn` until it returns truthy or times out. Use for asserting on eventually-consistent state (e.g., a `resource().value()` after a microtask resolves).
- **`vi.useFakeTimers()` / `vi.advanceTimersByTime(ms)`** — control time-dependent code (debounced search, polling, etc.). Call `vi.useRealTimers()` in `afterEach`.
- **`await fixture.whenStable()`** — the Angular equivalent of "wait for the microtask queue to drain." Use after every signal input change, after every form mutation, after every router navigation.

Never use `setTimeout` directly in tests to wait for state — it makes tests slow and flaky. Use one of the above.

### 4.2 Provider strategies

Three patterns for injecting test doubles:

- **`useValue: { method: vi.fn() }`** — the simplest stub. Use for plain services, dialogs, route data.
- **`useClass: <MockClass>`** — when the test needs a real class implementation (e.g., a service with a complex constructor). The mock class extends or replaces the real one.
- **Real service + stubbed dependencies** — the strongest pattern. Inject the real class, but stub its collaborators. This catches integration issues `useValue` misses.

For most recipes, `useValue` is enough. Use real-service-with-stubs when testing a service that has its own logic worth exercising.

### 4.3 Signal-based inputs

The v20+ default. Use `fixture.componentRef.setInput('<name>', <value>)`. Always `await fixture.whenStable()` after the call.

```typescript
fixture.componentRef.setInput('variant', 'outlined');
await fixture.whenStable();
// now assert
```

For tests that need a default input value, set it in the test host component's class field:

```typescript
@Component({ ... })
class TestHost {
  variant = input<'outlined' | 'text'>('text');
}
```

### 4.4 Signal-based outputs

Subscribe directly to the `output()` emitter. Clean up with `unsubscribe()` or by letting the component destroy.

```typescript
const emitted: string[] = [];
const sub = fixture.componentInstance.remove.subscribe((item) => emitted.push(item));
// ... trigger the event ...
expect(emitted).toEqual(['expected']);
sub.unsubscribe();
```

### 4.5 Reactive effects

Whenever a signal mutation may trigger an effect, call `TestBed.tick()` before asserting:

```typescript
store.addItem(...);
TestBed.tick();
// now the effect has run, the HTTP has fired
httpTesting.expectOne(...);
```

For resource-driven tests, use `TestBed.tick()` to drive the initial `httpResource` request and reloads caused by tracked signal changes. (`TestBed.flushEffects()` is deprecated in Angular 22.)

### 4.6 Zoneless apps

Angular 22+ supports zoneless change detection as a first-class option. If the project uses `provideZonelessChangeDetection()` (check `app.config.ts`):

- Every signal change requires a manual `fixture.detectChanges()` or `TestBed.tick()`.
- Some default behaviors (like `setTimeout`-triggered change detection) no longer work.
- Async tests still need `await fixture.whenStable()`.

The recipes in this guide assume zoneless mode by default. If the project uses Zone.js, some steps can be dropped, but they're harmless to keep.

### 4.7 Standalone components

Angular 22+ default. Every component, directive, and pipe is standalone. Tests must import them in the host component's `imports:[]` array, and you do **not** need (and should not add) `standalone: true` in decorators.

```typescript
@Component({
  imports: [<ComponentA>, <ComponentB>, <DirectiveC>],
  template: `...`,
})
class TestHost {}
```

Or override the component-under-test's `imports`:

```typescript
TestBed.configureTestingModule({}).overrideComponent(<ComponentName>, {
  set: { imports: [<ChildA>, <ChildB>] },
});
```

`NO_ERRORS_SCHEMA` is the escape hatch when you don't want to enumerate children. Use it when the test doesn't depend on child internals; use real imports when it does.

## 5. PrimeNG Components

When a component uses **PrimeNG** (`p-*` tags in its template, `import { ... } from 'primeng/<module>'` in its source), the test setup requires more than the standard `TestBed.configureTestingModule` block. The full pattern cookbook is in the companion file:

> **[README-TEST-PRIMENG-AGENT-GUIDE.md](README-TEST-PRIMENG-AGENT-GUIDE.md)** — Angular 22 + PrimeNG v20+ universal setup, service stubs, component recipes, legacy v17/v18 renames table, pitfalls.

**Note on `realworld-angular`:** the current upstream codebase does **not** depend on PrimeNG. The recipes below are for projects that do use PrimeNG; they are kept here because this guide is project-agnostic.

**TL;DR for PrimeNG tests:**

- Use `provideAnimationsAsync()` when the component path depends on animation events. Start without it for simple rendering assertions, then add it only when the component path depends on animation events or PrimeNG throws animation-related errors.
- Avoid `NoopAnimationsModule` when testing transitions, open/close state, portal behavior, or any path that depends on animation events.
- Stub the PrimeNG services the component injects:
  - `MessageService` → `{ add: vi.fn() }`
  - `ConfirmationService` → `{ confirm: vi.fn() }`
  - `DialogService` → `{ open: vi.fn().mockReturnValue(<ref>) }`
- For the **current API** of any PrimeNG component, query the configured PrimeNG MCP when available. If it is not visible in the session, use the versioned PrimeNG docs or the component source. The companion file gives the testing pattern.
- Treat PrimeNG class selectors as version/theme-dependent. Prefer stable attributes, roles, labels, or rendered-DOM queries after the component is opened/triggered.

**Renames to watch for in older codebases** (PrimeNG v17/v18 → v20+):

| v17/v18        | v20+         |
| -------------- | ------------ |
| `Dropdown`     | `Select`     |
| `Calendar`     | `DatePicker` |
| `TabView`      | `Tabs`       |
| `OverlayPanel` | `Popover`    |
| `Sidebar`      | `Drawer`     |

If the codebase uses one of the v17/v18 names, the v20+ import is the renamed module — but the import path may still resolve to the old name during a migration.

## 6. Common Mistakes Appendix

The most common errors an LLM makes when writing Angular + Vitest tests. Each item is a single sentence; the recipes in §3 have more detail.

1. **Forgetting `await fixture.whenStable()`** after `setInput`, after form mutation, after signal change. The set-and-assert path silently fails.
2. **Forgetting `httpTesting.verify()` in `afterEach`** — un-flushed requests fail the next test, but a missing afterEach hook means the suite still passes while leaking requests.
3. **Forgetting to drive `httpResource`** after construction or tracked signal changes; use `TestBed.tick()` for both the initial request and reloads.
4. **Asserting only on the request, not the post-state** for services. The interesting assertion is the signal after the response.
5. **Asserting `expect(result).toBeInstanceOf(UrlTree)` in a guard test** — that's a type check, not a behavior check. Serialize and compare the URL.
6. **Missing `runInInjectionContext`** around a functional guard call. The guard uses `inject()` internally; without the context, the test fails.
7. **Using `new <Service>(...)` instead of `TestBed.inject`** — DI wiring (interceptors, multi-providers) doesn't apply to direct construction.
8. **Hardcoding selectors in component tests** that break on template refactors. Use `data-testid` or stable class names.
9. **Asserting on child component internals** when the test uses `NO_ERRORS_SCHEMA`. The child is invisible to the test; use real imports if needed.
10. **Subscribing to `output()` without unsubscribing** — the subscription leaks. Use `takeUntilDestroyed()` or explicit unsubscribe.
11. **Using `setTimeout` in tests to wait for state** — slow and flaky. Use `vi.waitFor`, `vi.advanceTimersByTime`, or `await fixture.whenStable()`.
12. **Wrapping pure pipes in `TestBed`** — pure pipes don't need it. `new <Pipe>(...)` is enough.
13. **Asserting on `p-dialog` DOM before `visible` is `true`** — the dialog only renders when visible. Open it first, then query.
14. **Treating `provideAnimationsAsync()` as mandatory for every PrimeNG test** — use it when animation events matter; do not add it blindly.
15. **Using brittle PrimeNG class selectors everywhere** — component classes vary by PrimeNG version and theme. Query rendered DOM after opening/triggering the component.
16. **Skipping the negative test** — `httpTesting.expectNone(...)` for "no HTTP when empty", `expect(...).toBeNull()` for "element should be absent". Negative tests catch over-firing.

## 7. Quick Reference Table

A condensed lookup. Use this when you need a quick reminder; the recipes in §3 have full templates.

| Unit                   | Test setup essentials                                                                                 | Key assertion shape                                         |
| ---------------------- | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Pipe                   | `new <Pipe>(...)`                                                                                     | `expect(pipe.transform(input)).toBe(expected)`              |
| Service (HTTP)         | `provideHttpClientTesting()` + `httpTesting`                                                          | `req = expectOne(url); flush(...); expect(signal())`        |
| Service (httpResource) | `tick()` for initial request and reloads                                                              | `expect(resource.value()).toBe(...)`                        |
| Interceptor            | `provideHttpClient(withInterceptors([fn]))`                                                           | `expect(req.request.<prop>).toBe(expected)`                 |
| Component              | `TestBed.createComponent`; `NO_ERRORS_SCHEMA` only for shallow tests                                  | `setInput(...) → whenStable → querySelector`                |
| Dialog                 | `DialogRef` + `DIALOG_DATA` `useValue` stubs                                                          | `expect(closeFn).toHaveBeenCalledWith(result)`              |
| Store                  | `tick()` as needed + `HttpTestingController`                                                          | `expect(store.<signal>()).toBe(<post-state>)`               |
| Guard (sync)           | `runInInjectionContext` + 3-arg invocation; harness for routing integration                           | `expect(serializeUrl(result)).toBe('/expected')`            |
| Guard (async)          | Same + `subscribe` + `httpTesting.flush`                                                              | Same as above                                               |
| Resolver               | `RouterTestingHarness` + `withComponentInputBinding`                                                  | `expect(component.<input>()).toBe(<resolved>)`              |
| Directive              | `TestHostComponent` template                                                                          | `expect(querySelector('#id')).toBeNull()/.not.toBeNull()`   |
| Form (signal)          | `signal({...})` → `form(model)`; `formTree.<field>().value.set(...)` + `tick()`                       | `expect(service.<derivedSignal>()).toBe(<expected>)`        |
| Form (reactive)        | `ReactiveFormsModule` + `fixture.detectChanges()`                                                     | Same shape, different mechanism                             |
| linkedSignal           | `linkedSignal(() => source()[0])`                                                                     | After source change: `expect(derived()).toBe(<new>)`        |
| effect                 | `TestBed.runInInjectionContext(() => effect(...))`                                                    | `expect(captured).toBe(<tracked-signal-value>)`             |
| afterRenderEffect      | `await fixture.whenStable()` after mutation                                                           | `expect(phaseCallback).toHaveBeenCalledWith(<data>)`        |
| @defer                 | `DeferBlockBehavior.Manual` + `getDeferBlocks()`                                                      | `await render(DeferBlockState.<X>)` then assert             |
| Page                   | `RouterTestingHarness` for route integration; `createComponent` + `provideRouter([])` for smoke tests | `expect(routeNativeElement?.<query>(...)).<assert>`         |
| PrimeNG component      | Conditional `provideAnimationsAsync()` + service stubs + MCP/docs preflight                           | Component-specific; see Angular 22 + PrimeNG v20+ companion |
