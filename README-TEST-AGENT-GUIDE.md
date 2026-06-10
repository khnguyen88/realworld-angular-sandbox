# Angular + Vitest Test Creation Guide (for LLMs)

> **Testing Docs Index:**
>
> - **README-TEST-AGENT-GUIDE.md** — This file: recipe book for LLMs writing tests
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — PrimeNG v20+ companion cookbook
> - **README-TEST-GUIDE.md** — Human-facing tour of realworld-angular test patterns
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

## Who This Guide Is For

You are an LLM that has been given a task like: "write tests for this Angular + Vitest codebase." This guide is your reference. It does **not** assume any specific project — every recipe is a template with `<substitution>` placeholders. The codebase under test provides the actual code.

This guide does **not** serve humans learning what the realworld-angular project tests. Humans should read `README-TEST-GUIDE.md` instead.

## How to Use This Guide

1. **Pre-flight** — confirm the project setup (see §1).
2. **Identify the file under test** — match its type to the decision tree (§2).
3. **Jump to the recipe** — each per-unit section in §3 follows the same 5-block template.
4. **Substitute placeholders** — `<ServiceClassName>`, `<relative-path>`, etc. are replaced from the source.
5. **Verify** — every recipe's "Common Variants" and "Pitfalls" sections list the most common LLM errors. Read them before writing.

## Universal "Always" List

Every test in this guide assumes these conventions:

- **Vitest globals**: `import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'`. Never use Jasmine's `jasmine.*` or globals.
- **TestBed + signal inputs**: after `fixture.componentRef.setInput(...)`, call `await fixture.whenStable()` before asserting on the DOM.
- **HTTP tests**: `httpTesting.verify()` in `afterEach` to catch un-flushed requests.
- **Reactive graphs**: `TestBed.flushEffects()` after every signal mutation that may trigger an effect.
- **Substitutions**: this guide uses `<placeholder>` syntax. Replace with values from the source file.

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

### 1.2 Confirm Vitest is installed

Open `package.json`. Look for `"vitest"` in `devDependencies` and verify `jsdom` (or `happy-dom`) is also present. If vitest is absent, the project is not configured for unit testing as the Angular CLI ships it.

### 1.3 Confirm the Angular version

Open `package.json` and check the `@angular/core` version. The patterns in this guide target **Angular 20+** (signals, `httpResource`, signal-based inputs/outputs are the default). For Angular 19 or earlier, some APIs differ (field-initializer `inject()` patterns, decorator-based inputs, etc.) — flag this to the user before proceeding.

### 1.4 Confirm no Jasmine globals

Search the test config and a sample spec for `jasmine.`, `fit(`, `fdescribe(`, or any `tsconfig.spec.json` `types: ["jasmine"]`. If found, this is a mixed or migrating project. Most recipes still work, but `vi.fn()` should be used instead of `jasmine.createSpy()`.

### 1.5 Identify the project's testing utility conventions

Some projects have a `src/test-providers.ts` or similar global providers file referenced from `angular.json`. If present, the `beforeEach` blocks in the recipes below can drop providers that the global file already supplies. If absent (the default), every spec is self-contained — apply the recipe verbatim.

### 1.6 What to do if pre-flight fails

- **No vitest**: tell the user. Don't try to write tests; the project isn't set up for them.
- **Wrong Angular version**: ask the user. The guide's recipes need translation for v19 and earlier.
- **Mixed Jasmine/Vitest**: ask the user which runner to target, then proceed.

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
- `effect()`-driven HTTP (if the service uses `linkedSignal` or `effect` to trigger calls): flush with `TestBed.flushEffects()`

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

- **httpResource-based service** — the resource fires automatically; use `TestBed.flushEffects()` to drive it, then `httpTesting.expectOne(...).flush(...)`, then assert `service.<resourceName>.value()`.
- **Service with `effect()` calling another method** — flush twice: once to trigger the resource, once after the effect-driven call.
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

`NO_ERRORS_SCHEMA` lets the test ignore child component selectors. Each child has its own tests. Use it when the test is about _this_ component, not the integration with its children.

#### Common variants

- **Component with harness (recommended for shared components)** — replace the `el.querySelector(...)` block with `loader.getHarness(<HarnessClass>)`. Use harnesses when the component is shared (Button, Input, Modal) because template refactors cascade.
- **Component with form** — see §3.10 Forms.
- **Component with router outlet** — see §3.13 Page Components.
- **Component that uses `output()`** — subscribe to `componentInstance.<outputName>` and assert the captured emissions. Unsubscribe in cleanup or use a `takeUntil(destroyed)` pattern.
- **Component with host bindings** — assert on `fixture.nativeElement` directly (`el.getAttribute('role')`, `el.classList.contains(...)`, `el.style.<property>`).

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

- **Dialog with form + HTTP** — add `provideHttpClientTesting()`, use `TestBed.resetTestingModule()` to reconfigure per test if the form data changes, and use `TestBed.flushEffects()` after form mutations.
- **Dialog opened by `DialogService.open()`** — the parent component test stubs `DialogService` with `{ open: vi.fn().mockReturnValue(<ref>) }` and asserts `open` was called with the right config.
- **Reconfiguring `DIALOG_DATA` mid-suite** — use `TestBed.resetTestingModule()` followed by a fresh `TestBed.configureTestingModule(...)` in a new `it()` block.
- **Dialog with `inject(DialogRef)` (newer pattern)** — same stub, but the component doesn't take it via constructor; the test provides it through `providers:` and DI resolves it.

#### Pitfalls

- **Stubbing `DialogRef` as a class** — the simplest stub is `{ close: vi.fn() }` as a `useValue`. Don't use `useClass` or a real instance.
- **Forgetting `TestBed.resetTestingModule()`** — `DIALOG_DATA` is a single value per `configureTestingModule` call. Reusing a configured module for a test that needs different data silently uses the old data.
- **Not asserting the close result** — `closeFn` should be called with the form value (or whatever the dialog returns). `expect(closeFn).toHaveBeenCalledWith(...)` is the test.
- **Hanging on `await dialogRef.closed`** — if the test awaits the closed promise, it will hang forever because the stubbed `close` is a `vi.fn()` that doesn't return an observable. Stub the close, don't await the closed promise.
