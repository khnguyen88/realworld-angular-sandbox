# Test Creation Agent Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce an LLM-portable test creation guide (`README-TEST-AGENT-GUIDE.md`) plus a PrimeNG companion cookbook (`README-TEST-PRIMENG-AGENT-GUIDE.md`) that any LLM can use to author Vitest-based tests for any Angular project, with `https://primeng.org/mcp` as the live PrimeNG API source of truth.

**Architecture:** Two new markdown files at the sandbox root, structured as recipe books (5-block template per unit type). The main guide covers all Angular unit types. The PrimeNG companion covers v20.2+ component patterns and defers current API details to `https://primeng.org/mcp`. Four existing testing docs get their index blocks updated to point to the new file(s). The work is documentation, not test code — verification per task is querying the relevant MCP and confirming the doc matches.

**Tech Stack:** Markdown, Vitest (referenced), `@angular/build:unit-test` builder (referenced), Angular 22 (the version the existing `realworld-angular/` clone is pinned to), PrimeNG v20.2+ (via `https://primeng.org/mcp`).

**Spec:** `docs/superpowers/specs/2026-06-10-test-creation-agent-guide-design.md`

**Existing patterns to follow:** the four-file testing docs family uses an "Index" block at the top of each file (e.g., `README-TEST-GUIDE.md` lines 7-12) that lists the other testing docs. The new file(s) get added to that block in each existing file. The existing `README-TEST-GUIDE.md` (2,334 lines, human-facing) is **not refactored** — it serves a different audience and stays as-is.

---

## File Structure

| File                                 | Action               | Responsibility                                                                                                                                                                                                        |
| ------------------------------------ | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `README-TEST-AGENT-GUIDE.md`         | **Create**           | Main LLM-portable test creation guide. Recipe book + decision tree for any Angular + Vitest project.                                                                                                                  |
| `README-TEST-PRIMENG-AGENT-GUIDE.md` | **Create (default)** | PrimeNG v20.2+ companion cookbook. Universal setup, service stubs, top 8-10 components, v20 renames table, pitfalls. Per spec §4.2, may be split into multiple files at write time if the writer judges it warranted. |
| `README-TEST-GUIDE.md`               | **Modify**           | Add agent guide to the index block (lines 7-12).                                                                                                                                                                      |
| `README-TESTING.md`                  | **Modify**           | Add agent guide to the index block.                                                                                                                                                                                   |
| `README-TEST-INSIGHTS.md`            | **Modify**           | Add agent guide to the index block.                                                                                                                                                                                   |
| `README-TEST-CHRONOLOGY.md`          | **Modify**           | Add agent guide to the index block.                                                                                                                                                                                   |

No source files, no test code, no tooling, no `package.json` or `CLAUDE.md` changes.

---

## Task Order Rationale

Tasks 1-2 establish the two new files. Tasks 3-12 fill in the main guide section by section. Task 13 is the PrimeNG companion. Tasks 14-17 are the index updates. Task 18 is the final cross-reference verification.

Each writing task follows the same shape: write the section, verify APIs against the relevant MCP, commit. The verification is _part of_ the task, not a separate phase, so the writer catches drift at the point of authorship.

---

## Task 1: Create the main guide shell

**Files:**

- Create: `README-TEST-AGENT-GUIDE.md`

- [ ] **Step 1: Create the file with front matter and TOC**

Create `README-TEST-AGENT-GUIDE.md` at the sandbox root with this exact content:

```markdown
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
```

- [ ] **Step 2: Verify the file is well-formed**

Run from the sandbox root:

```bash
wc -l README-TEST-AGENT-GUIDE.md
```

Expected: a line count > 0 (around 60 lines for the shell).

Run:

```bash
grep -c "^## " README-TEST-AGENT-GUIDE.md
```

Expected: at least 7 `## ` headings (Who, How to Use, Universal, Table of Contents, and 7 numbered sections).

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: scaffold README-TEST-AGENT-GUIDE.md with front matter and TOC"
```

---

## Task 2: Write the Pre-flight Checks section

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert after the Table of Contents block)

- [ ] **Step 1: Insert §1 Pre-flight Checks**

Add the following content immediately after the `## Table of Contents` section. The next heading should be `## 1. Pre-flight Checks`.

````markdown
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
````

### 1.2 Confirm Vitest is installed

Open `package.json`. Look for `"vitest"` in `devDependencies` and verify `jsdom` (or `happy-dom`) is also present. If vitest is absent, the project is not configured for unit testing as the Angular CLI ships it.

### 1.3 Confirm the Angular version

Open `package.json` and check the `@angular/core` version. The patterns in this guide target **Angular 20+** (signals, `httpResource`, signal-based inputs/outputs are the default). For Angular 19 or earlier, some APIs differ (`inject(TestBed)` patterns, decorator-based inputs, etc.) — flag this to the user before proceeding.

### 1.4 Confirm no Jasmine globals

Search the test config and a sample spec for `jasmine.`, `fit(`, `fdescribe(`, or any `tsconfig.spec.json` `types: ["jasmine"]`. If found, this is a mixed or migrating project. Most recipes still work, but `vi.fn()` should be used instead of `jasmine.createSpy()`.

### 1.5 Identify the project's testing utility conventions

Some projects have a `src/test-providers.ts` or similar global providers file referenced from `angular.json`. If present, the `beforeEach` blocks in the recipes below can drop providers that the global file already supplies. If absent (the default), every spec is self-contained — apply the recipe verbatim.

### 1.6 What to do if pre-flight fails

- **No vitest**: tell the user. Don't try to write tests; the project isn't set up for them.
- **Wrong Angular version**: ask the user. The guide's recipes need translation for v19 and earlier.
- **Mixed Jasmine/Vitest**: ask the user which runner to target, then proceed.

````

- [ ] **Step 2: Verify the section is anchored correctly**

Run:

```bash
grep -n "^## " README-TEST-AGENT-GUIDE.md
````

Expected output includes `## 1. Pre-flight Checks` and the original 7 headings are still present.

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add pre-flight checks section to test agent guide"
```

---

## Task 3: Write the Decision Tree

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §2 after §1)

- [ ] **Step 1: Insert §2 Decision Tree**

Add the following content immediately after §1:

```markdown
## 2. Decision Tree

Match the file you are testing to its recipe. Do **not** read the recipes top-to-bottom — pick the right one and jump.

| File ends in / pattern                                                                | Recipe section                    |
| ------------------------------------------------------------------------------------- | --------------------------------- |
| `*.pipe.ts`                                                                           | §3.1 Pipes                        |
| `*.service.ts`, `*.api.ts` (not `*-api.service.ts` paths in a guards/services folder) | §3.2 Services                     |
| `*.interceptor.ts`                                                                    | §3.3 Interceptors                 |
| `*.component.ts` (not a routed page — see heuristic)                                  | §3.4 Components                   |
| `*.dialog.ts` or imports from `@angular/cdk/dialog`                                   | §3.5 Dialogs & Overlays           |
| `*.store.ts` or class exposes signals + httpResource                                  | §3.6 Stores / State               |
| `*.guard.ts`                                                                          | §3.7 Guards                       |
| `*.resolver.ts`                                                                       | §3.8 Resolvers                    |
| `*.directive.ts`                                                                      | §3.9 Directives                   |
| `*.form.ts` (form definition file) or service with form                               | §3.10 Forms                       |
| Signal primitives used: `linkedSignal`, `effect`, etc.                                | §3.11 Signal Primitives           |
| Component template uses `@defer`                                                      | §3.12 @defer Blocks               |
| Routed page (has a route entry, top-level for a feature)                              | §3.13 Page Components             |
| Component uses `p-*` tags or `primeng/*` imports                                      | §5 PrimeNG Components (companion) |
| `*.routes.ts` (route config files)                                                    | **Do not write tests**            |

**Page vs component heuristic**: a _page_ is the component referenced directly by a route's `component:` field (or loaded by a lazy route). A _component_ is everything else — dialogs, cards, list items, form fields, layout pieces. If you're not sure, check `*.routes.ts` files for the path-to-component mapping.

**When in doubt**: read the source file's constructor and template. The constructor tells you what dependencies to mock; the template tells you what DOM to assert on. Both are required to write a useful test.
```

- [ ] **Step 2: Verify the table renders**

Run:

```bash
grep -c "^| " README-TEST-AGENT-GUIDE.md
```

Expected: at least 18 lines starting with `| ` (1 header + 1 separator + 14 data rows in the table, plus the columns in §1 if any, plus the rows in the §7 quick reference we'll add later).

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add decision tree to test agent guide"
```

---

## Task 4: Write the Pipes recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.1)

- [ ] **Step 1: Insert §3.1 Pipes**

Add immediately after §2 (before the cross-cutting section, which comes later):

````markdown
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
````

No `TestBed` is needed — pure pipes are stateless functions. Instantiate with `new <PipeName>(...)` directly.

#### Common variants

- **Pipe with one input arg** — direct call: `pipe.transform(input, arg1)`.
- **Pipe with regex** — write one `it()` per regex branch, naming the branch explicitly.
- **Stateful pipe** (rare) — if the pipe has internal state, use `TestBed.configureTestingModule` and `TestBed.createComponent` with a host component that exercises it through a template binding.

#### Pitfalls

- **Wrapping in TestBed for no reason** — pure pipes don't need it. If the recipe template doesn't show `TestBed`, don't add it.
- **Forgetting `null`/`undefined`** — pure pipes are commonly called with nullable values from templates. Test those cases.
- **URL encoding** — if the pipe builds a URL, the assertion should check the encoded form, not the raw form. `expect(result).toContain(encodeURIComponent('value with spaces'))`.

````

- [ ] **Step 2: Verify the section**

Run:

```bash
grep -n "^### 3\." README-TEST-AGENT-GUIDE.md
````

Expected: `### 3.1 Pipes` is the first per-unit recipe heading.

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add pipes recipe to test agent guide"
```

---

## Task 5: Write the Services recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.2)

- [ ] **Step 1: Verify the API against the Angular MCP before writing**

Use the `angular-cli` MCP `search_documentation` tool. Query:

```
provideHttpClientTesting HttpTestingController expectOne verify
```

Confirm the current Angular 22 API for: `provideHttpClientTesting()`, `HttpTestingController`, `expectOne()`, `expectNone()`, `match()`, `flush()`. The current canonical pattern is `expectOne(url)` for single requests and `match(predicate)` for many.

- [ ] **Step 2: Insert §3.2 Services**

Add immediately after §3.1:

````markdown
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
````

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

````

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add services recipe to test agent guide"
````

---

## Task 6: Write the Interceptors recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.3)

- [ ] **Step 1: Verify the API against the Angular MCP**

Query the `angular-cli` MCP `search_documentation` tool:

```
withInterceptors provideHttpClient HttpClient functional interceptor
```

Confirm: `provideHttpClient(withInterceptors([fn]))` is the canonical v20+ pattern, and that the functional interceptor signature is `HttpInterceptorFn = (req, next) => ...`.

- [ ] **Step 2: Insert §3.3 Interceptors**

Add immediately after §3.2:

````markdown
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
````

#### Common variants

- **Header-adding interceptor** — assert `req.request.headers.get('X-Foo')`.
- **withCredentials toggle** — assert `req.request.withCredentials` boolean.
- **URL-rewriting interceptor** — assert the URL on `req.request.url` matches the rewritten form, not the original.
- **Response mapper** — subscribe to the response, assert the transformed value, not the raw body.

#### Pitfalls

- **Forgetting `withInterceptors([...])` in the test providers** — the interceptor is registered through the providers list, not by direct injection. Forgetting it means the request goes through unmodified.
- **Asserting on the `HttpClient` call, not the captured request** — the side effect of the interceptor is visible on `req.request`, not on the `http.get(...)` call. Capture the request first.
- **One test, two requests** — if a single test issues multiple requests, use `match()` (returns array) instead of `expectOne()` (returns single).

````

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add interceptors recipe to test agent guide"
````

---

## Task 7: Write the Components recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.4)

- [ ] **Step 1: Verify the API against the Angular MCP**

Query the `angular-cli` MCP `search_documentation` tool for two things:

1. `componentRef.setInput signal input` — confirm the signal-input pattern.
2. `ComponentHarness TestbedHarnessEnvironment` — confirm the harness API exists and is the recommended approach.

- [ ] **Step 2: Insert §3.4 Components**

Add immediately after §3.3:

````markdown
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
````

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

````

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add components recipe to test agent guide"
````

---

## Task 8: Write the Dialogs recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.5)

- [ ] **Step 1: Verify the API against the Angular MCP**

Query the `angular-cli` MCP `search_documentation` tool for:

```
CDK dialog DialogRef DIALOG_DATA test stub
```

Confirm: `DialogRef` is a class injectable for tests, `DIALOG_DATA` is an injection token, and the test pattern is to provide both as `useValue` stubs.

- [ ] **Step 2: Insert §3.5 Dialogs & Overlays**

Add immediately after §3.4:

````markdown
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
````

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

````

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add dialogs recipe to test agent guide"
````

---

## Task 9: Write the Stores recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.6)

- [ ] **Step 1: Verify the API against the Angular MCP**

Query the `angular-cli` MCP `search_documentation` tool for:

```
httpResource TestBed flushEffects testing
```

Confirm: `httpResource` triggers HTTP on construction, and `TestBed.flushEffects()` is required to make the request fire in tests.

- [ ] **Step 2: Insert §3.6 Stores / State**

Add immediately after §3.5:

````markdown
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
      TestBed.flushEffects();
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
      TestBed.flushEffects();
      const reqs = httpTesting.match((r) => r.url.includes('<url-fragment>'));
      reqs.forEach((r) => r.flush(<mockDataName>));
    });
  });
});
```
````

#### Common variants

- **Store with `httpResource` only** — `TestBed.flushEffects()` after `TestBed.inject()` to fire the initial request, then `expectOne`/`match` and `flush`.
- **Store with `effect()`-driven HTTP** — flush after every mutation. If a mutation triggers two requests (e.g., the action + a side effect), `match()` returns both, flush each.
- **Store with cross-entity constraint** — add an `it()` that performs the violating action and asserts the state was reset.
- **Store with `linkedSignal` reset** — add an `it()` that changes the source signal, then asserts the linked signal reset to the new derived value.

#### Pitfalls

- **Forgetting `TestBed.flushEffects()`** — `httpResource` is effect-driven. Without `flushEffects()`, the test runs zero HTTP and `expectOne` fails with "no matching request."
- **Using `expectOne` when the action triggers multiple requests** — switch to `match()` (returns array) and flush each.
- **Asserting on `value()` of an unresolved resource** — the resource is loading; `value()` is `undefined`. Flush the request first.
- **Not testing the "no HTTP when empty" case** — the negative assertion (`expectNone`) is one of the most useful tests for a store. Don't skip it.

````

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add stores recipe to test agent guide"
````

---

## Task 10: Write the Guards recipe

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.7)

- [ ] **Step 1: Verify the API against the Angular MCP**

Query the `angular-cli` MCP `search_documentation` tool for:

```
CanMatchFn signature arguments Angular 22 PartialMatchRouteSnapshot
```

Confirm: `CanMatchFn` in Angular 22 takes three arguments: `(route: Route, segments: UrlSegment[], currentSnapshot: PartialMatchRouteSnapshot)`.

- [ ] **Step 2: Insert §3.7 Guards**

Add immediately after §3.6:

````markdown
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
````

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

````

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add guards recipe to test agent guide"
````

---

## Task 11: Write the Resolvers, Directives, Forms, Signal Primitives, @defer, and Page Components recipes

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §3.8 through §3.13)

This is a multi-section task because each of these recipes is shorter than the others. Combine them in one commit to keep the per-section overhead down.

- [ ] **Step 1: Verify the API for `withComponentInputBinding` and `DeferBlockBehavior` against the Angular MCP**

Query the `angular-cli` MCP `search_documentation` tool for:

1. `withComponentInputBinding ResolveFn` — confirm: `withComponentInputBinding()` makes `resolve` data available as `input()` signals on the routed component.
2. `DeferBlockBehavior Manual getDeferBlocks DeferBlockState` — confirm: `DeferBlockBehavior.Manual` starts blocks in Placeholder; `getDeferBlocks()` returns a `Promise<DeferBlockFixture[]>`; `DeferBlockState` is `Placeholder | Loading | Complete | Error`.
3. `RouterTestingHarness navigateByUrl` — confirm the method signature returns the activated component typed.

- [ ] **Step 2: Insert §3.8 Resolvers**

````markdown
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
````

#### Common variants

- **Resolver returning `EMPTY` on error** — assert the route didn't activate.
- **Resolver that redirects on error** — assert the URL is the redirect target.
- **Class-based resolver** — `TestBed.inject(<ResolverClass>)`, call `.resolve(...)` directly.

#### Pitfalls

- **Forgetting `withComponentInputBinding()`** — without it, the resolved data isn't mapped to the component's `input()` signals. The assertion on `component.<input>()` will return `undefined`.
- **Not calling `harness.detectChanges()`** — after flushing HTTP, the binding to the input signal needs a change detection cycle.
- **Asserting against the harness root element** — `harness.routeNativeElement` is the _outlet's_ rendered element, not the routed component's. Use the returned component instance from `navigateByUrl` for typed assertions.

````

- [ ] **Step 3: Insert §3.9 Directives**

```markdown
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
````

#### Common variants

- **Directive with input signal** — `fixture.componentRef.setInput('<input-name>', <value>)` and re-create the host component, or use a host component that exposes a signal.
- **Directive with reactive input** — the host component has a signal; the directive reads it. Mutate the signal, `await fixture.whenStable()`, assert DOM updated.
- **Attribute directive (no structural `*` syntax)** — the test host uses `[<directiveSelector>]="<value>"` instead of `*<directiveSelector>`.

#### Pitfalls

- **Forgetting `imports: [<DirectiveName>]`** — directives in standalone components must be explicitly imported.
- **Asserting against a removed element** — when the directive hides content, the test should assert `expect(el.querySelector('#id')).toBeNull()`, not just check the inner text.
- **Not testing reactivity** — at least one test must change a signal/value and assert the DOM updated after `whenStable()`. Static-state-only tests miss half the directive's behavior.

````

- [ ] **Step 4: Insert §3.10 Forms**

```markdown
### 3.10 Forms

#### What to test

- Initial values (every field's default)
- Computed values derived from form state (totals, validations)
- Field-level validation (required, format, min/max)
- Cross-field effects (e.g., "use same as billing" clears billing fields)
- Form submission: HTTP fires, success state, error state

#### Pre-flight

- Identify the form library: **signal forms** (Angular v20+), **reactive forms** (`@angular/forms`), or **template-driven forms**.
- List every form control and its initial value.
- Identify computed signals that derive from form state — these are the *interesting* assertions.
- Note any `effect()` that watches form state and triggers side effects.

#### Recipe template (signal forms)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
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
    expect(service.<form>.<field>().value()).toBe(<initial-value>);
  });

  it('should compute <derived-signal> from form state', () => {
    service.<form>.<field>().value.set(<new-value>);
    TestBed.flushEffects();
    expect(service.<derivedSignal>()).toBe(<expected-derived-value>);
  });

  it('should <cross-field-effect> when <trigger-field> changes', () => {
    service.<form>.<field1>().value.set(<value-1>);
    service.<form>.<field2>().value.set(<value-2>);
    TestBed.flushEffects();
    expect(service.<form>.<field3>().value()).toBe(<expected-cleared-value>);
  });
});
````

#### Common variants

- **Reactive forms** — use `ReactiveFormsModule` in the host component's `imports:`, manipulate `fixture.componentInstance.form.controls.<name>`, and call `fixture.detectChanges()` (no `flushEffects`).
- **Form with HTTP submission** — add `provideHttpClientTesting()` to providers, assert on the request body and post-submit state.
- **Form with wizard steps** — each step is its own `describe` block; step transitions are tested via the service's `next()`/`previous()` methods.

#### Pitfalls

- **Mutating the wrong control** — signal forms use `service.<form>.<field>().value.set(...)`, not `service.<form>.controls.<field>.setValue(...)`. The pattern is depth-first through the form tree.
- **Forgetting `TestBed.flushEffects()` after a mutation** — derived signals and effects need the reactive cycle to fire.
- **Asserting on the underlying control's `.value` property (not the signal)** — `service.<form>.<field>()` (call it) returns the signal value; `service.<form>.<field>.value` (no call) is the writable signal.

````

- [ ] **Step 5: Insert §3.11 Signal Primitives**

```markdown
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
  standalone: true,
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
    TestBed.flushEffects();
    expect(component.<derivedName>()).toBe(<new-first-item>);
  });
});
````

#### Common variants

- **`effect` outside a component** — wrap in `TestBed.runInInjectionContext(() => effect(() => { ... }))`, then `TestBed.flushEffects()` to drive it.
- **`effect` with cleanup** — pass `(onCleanup) => { ... }` to `effect`; capture cleanup calls in an array; assert the array after a `counter.set(1)` and `flushEffects()`.
- **`afterRenderEffect`** — use `await fixture.whenStable()` to let the render cycle complete. Phase callback receives prior phase's return value as a signal.

#### Pitfalls

- **Creating `effect` outside an injection context** — must be in a constructor or `TestBed.runInInjectionContext()`. Otherwise, `inject()` calls inside fail.
- **Asserting on the linkedSignal after a source change without `flushEffects`** — the reset is effect-driven; without flushing, the assertion sees the stale override.
- **Using `effect` to propagate state** — that's `computed` or `linkedSignal`'s job. `effect` is for side effects (logging, persistence, canvas). If the test asserts the effect's body mutates a signal, that's an anti-pattern.

````

- [ ] **Step 6: Insert §3.12 @defer Blocks**

```markdown
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
  standalone: true,
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
  standalone: true,
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
````

#### Common variants

- **`PlayThrough` behavior (default)** — drop `deferBlockBehavior` from the TestBed config. The block goes through states naturally.
- **Multiple `@defer` blocks in one component** — `(await fixture.getDeferBlocks())[0]` vs `[1]` etc.
- **`@defer (on viewport)`** — switching to `PlayThrough` is simpler; `Manual` requires simulating the viewport trigger.

#### Pitfalls

- **Forgetting `await` on `getDeferBlocks()`** — it returns a `Promise<DeferBlockFixture[]>`.
- **Asserting on placeholder content after `render(Loading)`** — once you advance the state, the placeholder is gone. Assert before `render()` for placeholder, after for everything else.
- **Forgetting `DeferBlockBehavior.Manual`** — without it, the block plays through states before you can assert, and the placeholder test fails.

````

- [ ] **Step 7: Insert §3.13 Page Components**

```markdown
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
    TestBed.flushEffects();

    const req2 = httpTesting.expectOne((r) => r.url.includes('<url-fragment>'));
    expect(req2.request.params.get('<param>')).toBe('<expected-value>');
    req2.flush(<mockData>);
    await harness.fixture.whenStable();
  });
});
````

#### Common variants

- **Page with `httpResource`** — drop `TestBed.createComponent`; the resource fires on route activation. Flush effects, then expect.
- **Page with guards** — the harness navigates; the guard runs; assert on the final URL.
- **Page with multiple child components** — test each child interaction in its own `it()`.

#### Pitfalls

- **Using `NO_ERRORS_SCHEMA` for the whole page** — this hides the child's DOM. For page tests, prefer real imports of children so child-event assertions can fire.
- **Asserting on `harness.fixture.nativeElement` instead of `harness.routeNativeElement`** — the harness's fixture is the _root component containing the outlet_. The routed page renders inside `routeNativeElement`.
- **Not testing the empty state** — most pages have an "empty list" state. The mock data with an empty array is the easiest test to write and one of the most useful.
- **Not flushing effects between event and assertion** — the event handler may trigger a reactive update; without `flushEffects()`, the second `expectOne` fails.

````

- [ ] **Step 8: Verify all six sections are present**

Run:

```bash
grep -n "^### 3\." README-TEST-AGENT-GUIDE.md
````

Expected: 13 lines starting with `### 3.` (3.1 Pipes through 3.13 Page Components).

- [ ] **Step 9: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add resolvers, directives, forms, signals, defer, pages recipes"
```

---

## Task 12: Write the Cross-Cutting Concerns section

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §4)

- [ ] **Step 1: Insert §4 Cross-Cutting Concerns**

Add immediately after §3 (the per-unit recipes):

````markdown
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
````

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

Whenever a signal mutation may trigger an effect, call `TestBed.flushEffects()` before asserting:

```typescript
store.addItem(...);
TestBed.flushEffects();
// now the effect has run, the HTTP has fired
httpTesting.expectOne(...);
```

For resource-driven tests, the resource fires on construction in some setups and on first read in others. `TestBed.flushEffects()` after `TestBed.inject()` ensures the initial load runs.

### 4.6 Zoneless apps

Angular 20+ supports zoneless change detection. If the project uses `provideZonelessChangeDetection()` (check `app.config.ts`):

- Every signal change requires a manual `fixture.detectChanges()` or `TestBed.flushEffects()`.
- Some default behaviors (like `setTimeout`-triggered change detection) no longer work.
- Async tests still need `await fixture.whenStable()`.

The recipes in this guide assume zoneless mode by default (since that's the v20+ recommendation). If the project uses Zone.js, some steps can be dropped, but they're harmless to keep.

### 4.7 Standalone components

Angular 20+ default. Every component, directive, and pipe is standalone. Tests must import them in the host component's `imports:[]` array:

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

````

- [ ] **Step 2: Verify the section is in place**

Run:

```bash
grep -n "^## 4" README-TEST-AGENT-GUIDE.md
````

Expected: `## 4. Cross-Cutting Concerns`.

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add cross-cutting concerns section to test agent guide"
```

---

## Task 13: Write the PrimeNG stub section

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §5)

This is the stub section in the main guide. The full PrimeNG cookbook lives in `README-TEST-PRIMENG-AGENT-GUIDE.md` (Task 14).

- [ ] **Step 1: Insert §5 PrimeNG Components**

Add immediately after §4:

```markdown
## 5. PrimeNG Components

When a component uses **PrimeNG** (`p-*` tags in its template, `import { ... } from 'primeng/<module>'` in its source), the test setup requires more than the standard `TestBed.configureTestingModule` block. The full pattern cookbook is in the companion file:

> **[README-TEST-PRIMENG-AGENT-GUIDE.md](README-TEST-PRIMENG-AGENT-GUIDE.md)** — universal setup, service stubs, top 8-10 components, v20 renames table, pitfalls.

**TL;DR for PrimeNG tests:**

- Add `provideAnimationsAsync()` to the providers — PrimeNG v20+ depends on Angular's async animations engine. `NoopAnimationsModule` is the wrong choice.
- Stub the PrimeNG services the component injects:
  - `MessageService` → `{ add: vi.fn() }`
  - `ConfirmationService` → `{ confirm: vi.fn() }`
  - `DialogService` → `{ open: vi.fn().mockReturnValue(<ref>) }`
- For the **current API** of any PrimeNG component, query `https://primeng.org/mcp` at write time. The MCP returns the live selector, events, and template syntax; the companion file gives the testing pattern.

**Renames to watch for in older codebases** (PrimeNG v17/v18 → v20+):

| v17/v18        | v20+         |
| -------------- | ------------ |
| `Dropdown`     | `Select`     |
| `Calendar`     | `DatePicker` |
| `TabView`      | `Tabs`       |
| `OverlayPanel` | `Popover`    |
| `Sidebar`      | `Drawer`     |

If the codebase uses one of the v17/v18 names, the v20+ import is the renamed module — but the import path may still resolve to the old name during a migration.
```

- [ ] **Step 2: Verify the section**

Run:

```bash
grep -n "^## 5" README-TEST-AGENT-GUIDE.md
```

Expected: `## 5. PrimeNG Components`.

- [ ] **Step 3: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add PrimeNG stub section to test agent guide"
```

---

## Task 14: Write the PrimeNG companion cookbook

**Files:**

- Create: `README-TEST-PRIMENG-AGENT-GUIDE.md`

**Decision point at write time:** the spec allows this to be one file (default) or split if warranted. Start with one file. If the file grows past ~3000 lines OR a clean logical seam emerges, split into:

- `README-TEST-PRIMENG-AGENT-GUIDE-SETUP.md` (universal setup + service stubs + renames)
- `README-TEST-PRIMENG-AGENT-GUIDE-COMPONENTS.md` (per-component recipes + pitfalls)

If split, update Task 13's stub section to link to both files.

- [ ] **Step 1: Create the file with front matter and universal setup**

Create `README-TEST-PRIMENG-AGENT-GUIDE.md` at the sandbox root with this exact content:

````markdown
# PrimeNG v20+ Test Cookbook (for LLMs)

> **Testing Docs Index:**
>
> - **README-TEST-AGENT-GUIDE.md** — Main LLM-portable test creation guide
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — This file: PrimeNG v20+ companion cookbook
> - **README-TEST-GUIDE.md** — Human-facing tour of realworld-angular test patterns
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

## Who This File Is For

You are an LLM writing tests for an Angular + Vitest codebase that uses **PrimeNG** for UI primitives. The main test creation guide (`README-TEST-AGENT-GUIDE.md`) covers the standard patterns; this file covers the **PrimeNG-specific** setup, service stubs, and per-component patterns.

## How to Use This File

1. **Confirm the PrimeNG version** (see §1).
2. **Apply the universal setup** (§2) in every test that uses PrimeNG components.
3. **For each PrimeNG component in the code**, find the matching recipe in §4-§13.
4. **For the current API of any component**, query `https://primeng.org/mcp` before writing assertions. The MCP returns the current selector, events, and template syntax.

> **primeng.org MCP:** before writing assertions for any component in §4-§13, query `https://primeng.org/mcp` for the current `<ComponentName>` API. The patterns below are version-stable; the API details are not.

## Table of Contents

- [§1. Pre-flight: Confirm PrimeNG Version](#1-pre-flight-confirm-primeng-version)
- [§2. Universal Test Setup](#2-universal-test-setup)
- [§3. Service Stubs](#3-service-stubs)
- [§4. p-table](#4-p-table)
- [§5. p-dialog](#5-p-dialog)
- [§6. p-select / p-dropdown](#6-p-select--p-dropdown)
- [§7. p-datepicker / p-calendar](#7-p-datepicker--p-calendar)
- [§8. p-confirmpopup](#8-p-confirmpopup)
- [§9. p-toast](#9-p-toast)
- [§10. p-inputtext, p-button, p-checkbox](#10-p-inputtext-p-button-p-checkbox)
- [§11. p-fileupload](#11-p-fileupload)
- [§12. Renames from v17/v18](#12-renames-from-v17v18)
- [§13. Common Pitfalls](#13-common-pitfalls)

## 1. Pre-flight: Confirm PrimeNG Version

Open `package.json` and check `primeng` in `dependencies`. Confirm the major version:

- **v20+** — this guide. Signal-based components, async animations.
- **v17/v18** — same patterns, but the renamed components still use the old names. See §12.
- **v16 or earlier** — `BrowserAnimationsModule` (not async); no signal components. Stop and ask the user.

Also confirm `@angular/core` is **v20+** — PrimeNG v20 requires Angular 20+.

## 2. Universal Test Setup

Every PrimeNG test starts from this base. Customize per-component below.

### 2.1 The provider block

```typescript
TestBed.configureTestingModule({
  providers: [
    provideAnimationsAsync(),
    // ... per-component providers
  ],
}).overrideComponent(<ComponentUnderTest>, {
  set: { imports: [<PrimeNGModules>, <OtherChildren>] },
});
```
````

`provideAnimationsAsync()` is **mandatory** for PrimeNG v20+. PrimeNG components subscribe to animation events; without the provider, you get cryptic `NG0201` errors or silent failures.

`NoopAnimationsModule` is the **wrong choice** — it suppresses the animation events PrimeNG components depend on for transitions and open/close state.

### 2.2 Theme CSS in jsdom

PrimeNG components render with theme-dependent CSS classes. In `angular.json`, the test target's `options.styles` should include the theme:

```json
"test": {
  "builder": "@angular/build:unit-test",
  "options": {
    "styles": ["src/styles.css"]
  }
}
```

If `src/styles.css` doesn't import a PrimeNG theme, add one:

```css
@import 'primeng/resources/themes/lara-light-blue/theme.css';
```

(Check the project's actual theme import path; `lara-light-blue` is a common default but not universal.)

### 2.3 What you can skip

- `BrowserAnimationsModule` — replaced by `provideAnimationsAsync()`.
- `NoopAnimationsModule` — see §2.1.
- `FormsModule` / `ReactiveFormsModule` — only if the component under test uses ngModel or form controls. PrimeNG's own components handle their internal state.

## 3. Service Stubs

PrimeNG components inject a few shared services. Stub them at the providers level.

### 3.1 `MessageService`

Used by `p-toast`, `p-confirmpopup`, and any component that emits transient messages.

```typescript
{ provide: MessageService, useValue: { add: vi.fn() } }
```

Assert on the stub:

```typescript
const messageService = TestBed.inject(MessageService);
expect(messageService.add).toHaveBeenCalledWith({
  severity: 'success',
  summary: 'Saved',
  detail: '...',
});
```

### 3.2 `ConfirmationService`

Used by `p-confirmpopup` and any component that triggers a confirmation dialog.

```typescript
{ provide: ConfirmationService, useValue: { confirm: vi.fn() } }
```

Assert on the stub, including the accept/reject callbacks:

```typescript
const confirmationService = TestBed.inject(ConfirmationService);
expect(confirmationService.confirm).toHaveBeenCalled();
const call = confirmationService.confirm.mock.calls[0][0];
call.accept(); // trigger the accept path
expect(<accept-side-effect>).toBe(<expected>);
```

### 3.3 `DialogService`

Used by any component that programmatically opens a dialog.

```typescript
const ref = { close: vi.fn(), onClose: of(<result>) };
{ provide: DialogService, useValue: { open: vi.fn().mockReturnValue(ref) } }
```

Assert that `open` was called with the right config:

```typescript
const dialogService = TestBed.inject(DialogService);
expect(dialogService.open).toHaveBeenCalledWith(<Component>, expect.objectContaining({ header: '...' }));
```

### 3.4 `DynamicDialogRef`

Used inside a PrimeNG dialog opened via `DialogService`. The parent component stubs `DialogService`; the dialog itself injects `DynamicDialogRef`.

```typescript
{ provide: DynamicDialogRef, useValue: { close: vi.fn() } }
```

If the dialog awaits `ref.onClose`, stub the observable:

```typescript
{ provide: DynamicDialogRef, useValue: { close: vi.fn(), onClose: of(<result>) } }
```

````

- [ ] **Step 2: Verify the file is in place and starts correctly**

Run:

```bash
head -20 README-TEST-PRIMENG-AGENT-GUIDE.md
````

Expected: the file starts with `# PrimeNG v20+ Test Cookbook (for LLMs)`.

Run:

```bash
grep -c "^## " README-TEST-PRIMENG-AGENT-GUIDE.md
```

Expected: at least 13 (front matter, intro, usage, TOC, and 13 numbered sections).

- [ ] **Step 3: Commit**

```bash
git add README-TEST-PRIMENG-AGENT-GUIDE.md
git commit -m "docs: scaffold PrimeNG companion cookbook with universal setup and service stubs"
```

---

## Task 15: Write the per-component PrimeNG recipes (p-table, p-dialog, p-select, p-datepicker)

**Files:**

- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md` (insert §4-§7)

- [ ] **Step 1: Verify the current PrimeNG API for these four components**

Query `https://primeng.org/mcp` (or `WebSearch` / `WebFetch` against `https://primeng.org/`) for the current selector, events, and template syntax for:

- `Table` (p-table)
- `Dialog` (p-dialog)
- `Select` (p-select) — formerly Dropdown
- `DatePicker` (p-datepicker) — formerly Calendar

For each, capture: the module name to import, the selector, the key events (especially for `onPage`, `onSort`, `onFilter` for tables; `onShow`/`onHide` for dialogs), and the data-binding shape.

- [ ] **Step 2: Insert §4 p-table**

Add immediately after §3:

````markdown
## 4. p-table

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Table` API — selector (`p-table`), events (`onPage`, `onSort`, `onFilter`), and template syntax (`<ng-template pTemplate="header">` vs the new signal-based form). The patterns below are version-stable; the API details are not.

### 4.1 What to test

- Rows render correctly (column values from data)
- Pagination: clicking next/prev triggers the lazy load event with the correct page index
- Sorting: clicking a column header triggers the sort event
- Filtering: typing in a filter input triggers the filter event
- Empty state: a table with zero rows renders the empty message
- Loading state: a `p-table` with `[loading]="true"` shows the spinner

### 4.2 Pre-flight

- Identify the data source: is it `[value]` bound to an array, or `[lazy]="true"` with `(onLazyLoad)`?
- List the columns and their data fields.
- Identify the pagination config: `[paginator]="true"`, `[rows]`, `[first]`.
- Note the event handlers: `(onPage)`, `(onSort)`, `(onFilter)`, `(onLazyLoad)`.

### 4.3 Recipe template (client-side table)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { TableModule } from 'primeng/table';
import { describe, it, expect, beforeEach } from 'vitest';
import { <TableHostComponent> } from '<relative-path>';

const <mockRows> = [<row-shape>];

describe('<TableHostComponent>', () => {
  let fixture: ComponentFixture<<TableHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<TableHostComponent>, {
      set: { imports: [TableModule] },
    });
    fixture = TestBed.createComponent(<TableHostComponent>);
    fixture.componentRef.setInput('rows', <mockRows>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <expected-cell-text> for each row', () => {
    expect(el.textContent).toContain(<expected-text>);
  });

  it('should show <empty-message> when rows are empty', async () => {
    fixture.componentRef.setInput('rows', []);
    await fixture.whenStable();
    expect(el.textContent).toContain('<empty-message>');
  });
});
```
````

### 4.4 Recipe template (server-side / lazy table)

```typescript
beforeEach(async () => {
  TestBed.configureTestingModule({
    providers: [provideAnimationsAsync(), provideHttpClientTesting()],
  }).overrideComponent(<TableHostComponent>, {
    set: { imports: [TableModule] },
  });
  fixture = TestBed.createComponent(<TableHostComponent>);
  el = fixture.nativeElement;
  httpTesting = TestBed.inject(HttpTestingController);
  await fixture.whenStable();
});

it('should request the first page on init', () => {
  const req = httpTesting.expectOne((r) => r.url.includes('<data-url>'));
  expect(req.request.params.get('page')).toBe('1');
  req.flush(<paged-response>);
});

it('should request page 2 when paginator advances', async () => {
  httpTesting.expectOne((r) => r.url.includes('<data-url>')).flush(<paged-response-page-1>);
  await fixture.whenStable();

  // Find the paginator next button and click it
  const nextButton = el.querySelector<HTMLButtonElement>('.p-paginator-next')!;
  nextButton.click();
  await fixture.whenStable();

  const req2 = httpTesting.expectOne((r) => r.url.includes('<data-url>'));
  expect(req2.request.params.get('page')).toBe('2');
  req2.flush(<paged-response-page-2>);
});
```

> **Note on the next-page click:** the exact selector depends on the PrimeNG theme. `.p-paginator-next` is the v17/v18/v20 default. If the project's theme overrides it, query the rendered DOM (`el.querySelectorAll('.p-paginator button')`) to find the next button.

### 4.5 Common variants

- **Sortable column** — click the header `<th>` and assert the sort event fired with the right field and direction.
- **Filterable column** — set the filter value on the component instance, dispatch the input event, assert the filter event fired.
- **Selection** — click a row checkbox, assert the selection signal updated.

### 4.6 Pitfalls

- **Forgetting `provideAnimationsAsync()`** — `p-table` paginator and sort UI use animations; without the provider, the test runs but interactions silently fail.
- **Asserting on `p-table` before the table initializes** — `p-table` lazy-loads on the first change detection cycle. Always `await fixture.whenStable()` before querying rows.
- **Selecting the wrong paginator button** — themes vary. Use `el.querySelector('.p-paginator-next')` as a starting point; fall back to other selectors if it's null.
- **Server-side table: asserting only on the first request** — pagination tests must flush the first request, advance the page, then flush the second.

````

- [ ] **Step 3: Insert §5 p-dialog**

```markdown
## 5. p-dialog

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Dialog` API — selector (`p-dialog`), visibility binding (`[visible]`), events (`onShow`, `onHide`), and the close mechanism (header close button, ESC key, backdrop click).

### 5.1 What to test

- Dialog opens when `[visible]` becomes `true`
- Dialog closes when the user clicks the close button or backdrop
- Dialog content renders correctly when open
- Dialog opened via `DialogService.open()` returns the right `DynamicDialogRef`

### 5.2 Pre-flight

- Identify the visibility trigger: signal-based (`[visible]="signal()"`) or input-based.
- Note the close handler: `(visibleChange)` callback, internal state, or `DialogService` ref.
- Identify what content the dialog renders (slot, template, child component).

### 5.3 Recipe template (declarative dialog)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { DialogModule } from 'primeng/dialog';
import { ButtonModule } from 'primeng/button';
import { describe, it, expect, beforeEach } from 'vitest';
import { <DialogHostComponent> } from '<relative-path>';

describe('<DialogHostComponent>', () => {
  let fixture: ComponentFixture<<DialogHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<DialogHostComponent>, {
      set: { imports: [DialogModule, ButtonModule] },
    });
    fixture = TestBed.createComponent(<DialogHostComponent>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should NOT render dialog content when closed', () => {
    expect(el.querySelector('.p-dialog')).toBeNull();
  });

  it('should render dialog content when opened', async () => {
    fixture.componentRef.setInput('visible', true);
    await fixture.whenStable();
    expect(el.querySelector('.p-dialog')).not.toBeNull();
    expect(el.textContent).toContain('<expected-content>');
  });

  it('should close when close button is clicked', async () => {
    fixture.componentRef.setInput('visible', true);
    await fixture.whenStable();
    const closeButton = el.querySelector<HTMLButtonElement>('.p-dialog-header-close')!;
    closeButton.click();
    await fixture.whenStable();
    expect(fixture.componentInstance.visible()).toBe(false);
  });
});
````

### 5.4 Common variants

- **Dialog opened via `DialogService.open()`** — the parent component test stubs `DialogService` with `{ open: vi.fn().mockReturnValue(<ref>) }`. Assert on the stub's `open` call args and the ref's `close` method.
- **Dialog with form** — combine the dialog recipe with §3.10 Forms from the main guide.
- **Dialog without header (no close button)** — test ESC keypress or backdrop click instead.

### 5.5 Pitfalls

- **Querying `.p-dialog` before the dialog is open** — PrimeNG only inserts the dialog DOM when `visible` is true. Use `setInput('visible', true)` first, then `whenStable()`, then query.
- **Missing `provideAnimationsAsync()`** — the dialog open/close transitions don't run; assertions on transition state fail.
- **Clicking the close button that doesn't exist** — if the dialog has no header (`[showHeader]="false"`), there's no `.p-dialog-header-close`. Use ESC keypress or backdrop click instead.

````

- [ ] **Step 4: Insert §6 p-select / p-dropdown**

```markdown
## 6. p-select / p-dropdown

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Select` API (v20+) or `Dropdown` API (v17/v18). Confirm the selector, the `options` array shape (`{ label, value }`), the `[(ngModel)]` or signal form integration, and the `onChange` event payload.

### 6.1 What to test

- Renders the placeholder when no value is selected
- Renders the selected value's label when a value is bound
- Opens the panel when clicked
- Selecting an option fires the change event with the right value

### 6.2 Pre-flight

- Identify the data input: signal-based `options()` or `@Input() options`.
- Note the change handler: `(onChange)` callback, signal form integration, or two-way `[(ngModel)]`.
- Identify the value type: simple (`string`), object (`{ id, label }`), or nested.

### 6.3 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { SelectModule } from 'primeng/select';
import { describe, it, expect, beforeEach } from 'vitest';
import { <SelectHostComponent> } from '<relative-path>';

const <mockOptions> = [{ label: 'A', value: 'a' }, { label: 'B', value: 'b' }];

describe('<SelectHostComponent>', () => {
  let fixture: ComponentFixture<<SelectHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<SelectHostComponent>, {
      set: { imports: [SelectModule] },
    });
    fixture = TestBed.createComponent(<SelectHostComponent>);
    fixture.componentRef.setInput('options', <mockOptions>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <placeholder> when no value is selected', () => {
    expect(el.textContent).toContain('<placeholder>');
  });

  it('should render <selected-label> when a value is bound', async () => {
    fixture.componentRef.setInput('value', 'a');
    await fixture.whenStable();
    expect(el.textContent).toContain('A');
  });
});
````

### 6.4 Common variants

- **Select inside a form (signal forms)** — the value binding is `<p-select [formField]="'myField'" />`. Use the form's API to set the value and assert.
- **Select with object values** — the value is the full object, not a primitive. The test passes the object, the select compares by reference (or by a custom comparator).
- **Multi-select (`p-multiselect`)** — separate component; similar pattern but value is an array.

### 6.5 Pitfalls

- **Forgetting to import `SelectModule`** — the component renders as a blank `<p-select>` element. The override must include the module.
- **Asserting on the option list before the panel is open** — PrimeNG renders options only when the panel is open. To assert on options, click to open first.
- **Wrong value type** — if `value` is an object, the test must pass the same object reference, not a copy.

````

- [ ] **Step 5: Insert §7 p-datepicker / p-calendar**

```markdown
## 7. p-datepicker / p-calendar

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `DatePicker` API (v20+) or `Calendar` API (v17/v18). Confirm the selector, the date format (`dateFormat`), the inline vs popup mode, and the change event payload (`Date` object or string).

### 7.1 What to test

- Renders the input with the bound date formatted correctly
- Opens the calendar panel when the input is clicked
- Selecting a date updates the value
- Clearing the date (X button) sets the value to null

### 7.2 Pre-flight

- Identify the input format (`dateFormat="yy-mm-dd"` etc.).
- Note the value type: `Date` object, ISO string, or timestamp.
- Identify any min/max date constraints.

### 7.3 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { DatePickerModule } from 'primeng/datepicker';
import { describe, it, expect, beforeEach } from 'vitest';
import { <DatePickerHostComponent> } from '<relative-path>';

describe('<DatePickerHostComponent>', () => {
  let fixture: ComponentFixture<<DatePickerHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<DatePickerHostComponent>, {
      set: { imports: [DatePickerModule] },
    });
    fixture = TestBed.createComponent(<DatePickerHostComponent>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <input-class> input element', () => {
    expect(el.querySelector('.<input-class>')).not.toBeNull();
  });

  it('should set the input value to the formatted date', async () => {
    fixture.componentRef.setInput('value', new Date('2026-06-10'));
    await fixture.whenStable();
    const input = el.querySelector<HTMLInputElement>('.<input-class>')!;
    expect(input.value).toContain('2026');
  });
});
````

### 7.4 Common variants

- **Inline datepicker** — the calendar is always visible; no open/close.
- **Range selection** — `[selectionMode]="range"`; value is a tuple `[Date, Date]`.
- **Time picker** — `[showTime]="true"`; value includes hours/minutes.

### 7.5 Pitfalls

- **Timezone issues** — `new Date('2026-06-10')` is parsed as UTC midnight; the formatted output depends on the local timezone. If the test fails on the date string, use `new Date(2026, 5, 10)` (local time).
- **Asserting on the calendar panel before it's open** — like `p-dialog`, the panel only renders when open.

````

- [ ] **Step 6: Verify §4-§7 are in place**

Run:

```bash
grep -n "^## [4-7]\." README-TEST-PRIMENG-AGENT-GUIDE.md
````

Expected: four lines, `## 4. p-table` through `## 7. p-datepicker / p-calendar`.

- [ ] **Step 7: Commit**

```bash
git add README-TEST-PRIMENG-AGENT-GUIDE.md
git commit -m "docs: add PrimeNG recipes for table, dialog, select, datepicker"
```

---

## Task 16: Write the remaining PrimeNG recipes (confirmpopup, toast, simple controls, fileupload) and the renames/pitfalls sections

**Files:**

- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md` (insert §8-§13)

- [ ] **Step 1: Verify the current PrimeNG API for these components**

Query `https://primeng.org/mcp` for:

- `ConfirmPopup` (p-confirmpopup)
- `Toast` (p-toast)
- `InputText` (p-inputtext), `Button` (p-button), `Checkbox` (p-checkbox)
- `FileUpload` (p-fileupload)

For each, capture the module name, selector, and any event payload.

- [ ] **Step 2: Insert §8 p-confirmpopup**

````markdown
## 8. p-confirmpopup

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `ConfirmPopup` API — selector, the `accept`/`reject` event payload, and the `ConfirmationService` integration.

### 8.1 What to test

- Triggering `ConfirmationService.confirm(...)` causes the popup to appear
- Clicking the accept button calls the accept callback
- Clicking the reject button calls the reject callback

### 8.2 Pre-flight

- Identify the component that calls `ConfirmationService.confirm(...)`.
- Note the accept/reject callbacks in the confirm options.

### 8.3 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { ConfirmationService, MessageService } from 'primeng/api';
import { ConfirmPopupModule } from 'primeng/confirmpopup';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { <TriggerComponent> } from '<relative-path>';

describe('<TriggerComponent> confirm flow', () => {
  let fixture: ComponentFixture<<TriggerComponent>>;
  let el: HTMLElement;
  let confirmationService: ConfirmationService;
  let acceptFn: ReturnType<typeof vi.fn>;
  let rejectFn: ReturnType<typeof vi.fn>;

  beforeEach(async () => {
    acceptFn = vi.fn();
    rejectFn = vi.fn();
    TestBed.configureTestingModule({
      providers: [
        provideAnimationsAsync(),
        { provide: ConfirmationService, useValue: { confirm: vi.fn() } },
        { provide: MessageService, useValue: { add: vi.fn() } },
      ],
    }).overrideComponent(<TriggerComponent>, {
      set: { imports: [ConfirmPopupModule] },
    });
    fixture = TestBed.createComponent(<TriggerComponent>);
    el = fixture.nativeElement;
    confirmationService = TestBed.inject(ConfirmationService);
    await fixture.whenStable();
  });

  it('should call ConfirmationService.confirm when <trigger-action>', () => {
    el.querySelector<HTMLButtonElement>('<trigger-selector>')!.click();
    expect(confirmationService.confirm).toHaveBeenCalled();
  });

  it('should run <accept-side-effect> when accept callback fires', () => {
    el.querySelector<HTMLButtonElement>('<trigger-selector>')!.click();
    const confirmCall = (confirmationService.confirm as ReturnType<typeof vi.fn>).mock.calls[0][0];
    confirmCall.accept();
    expect(<accept-side-effect>).toBe(<expected>);
  });
});
```
````

### 8.4 Pitfalls

- **Not providing both `ConfirmationService` AND `MessageService`** — `ConfirmPopup` itself uses `MessageService` for accessibility announcements. Forgetting it gives an `NG0201` error.
- **Asserting on the popup DOM before the confirm is called** — the popup only appears when `ConfirmationService.confirm` runs.

````

- [ ] **Step 3: Insert §9 p-toast**

```markdown
## 9. p-toast

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Toast` API — the `key` for matching toasts, the `MessageService.add` payload shape (`severity`, `summary`, `detail`, `key`).

### 9.1 What to test

- `MessageService.add({ severity: 'success', ... })` causes a toast to render
- Multiple toasts stack
- Toast auto-dismisses after the configured lifetime

### 9.2 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { <ToastHostComponent> } from '<relative-path>';

describe('<ToastHostComponent>', () => {
  let fixture: ComponentFixture<<ToastHostComponent>>;
  let el: HTMLElement;
  let messageService: MessageService;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideAnimationsAsync(),
        { provide: MessageService, useValue: { add: vi.fn() } },
      ],
    }).overrideComponent(<ToastHostComponent>, {
      set: { imports: [ToastModule] },
    });
    fixture = TestBed.createComponent(<ToastHostComponent>);
    el = fixture.nativeElement;
    messageService = TestBed.inject(MessageService);
    await fixture.whenStable();
  });

  it('should not render any toast by default', () => {
    expect(el.querySelector('.p-toast')).toBeNull();
  });

  it('should render a toast when MessageService.add is called', () => {
    (messageService.add as ReturnType<typeof vi.fn>).mock.calls.length; // ensure add is spied
    // Trigger the action that calls messageService.add
    fixture.componentInstance.<triggerMethod>();
    expect(messageService.add).toHaveBeenCalledWith(expect.objectContaining({ severity: '<expected-severity>' }));
  });
});
````

> **Note on the toasts' DOM:** `p-toast` renders toasts into a portal at the document body level, not inside the component's host. If asserting on toast DOM directly, query `document.body.querySelector('.p-toast-message')` instead of `fixture.nativeElement.querySelector(...)`.

### 9.3 Pitfalls

- **Asserting on the toast inside the component** — toasts render in a portal. Use `document.body` queries.
- **Not providing `MessageService`** — the toast component injects it directly; without the provider, the test fails on construction.

````

- [ ] **Step 4: Insert §10 p-inputtext, p-button, p-checkbox**

```markdown
## 10. p-inputtext, p-button, p-checkbox

These three are simple enough that the recipes are short. Combine them in one test if the component uses all three.

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current API of each component before writing tests. The patterns below are version-stable.

### 10.1 p-inputtext

```typescript
import { InputTextModule } from 'primeng/inputtext';

TestBed.configureTestingModule({
  providers: [provideAnimationsAsync()],
}).overrideComponent(<HostComponent>, {
  set: { imports: [InputTextModule, ReactiveFormsModule] },
});

it('should reflect the bound value', async () => {
  fixture.componentRef.setInput('value', 'hello');
  await fixture.whenStable();
  const input = el.querySelector<HTMLInputElement>('input.p-inputtext')!;
  expect(input.value).toBe('hello');
});
````

`p-inputtext` is a CSS-only component; the actual `<input>` is rendered by the host's template. Assert on the `<input>` element directly.

### 10.2 p-button

```typescript
import { ButtonModule } from 'primeng/button';

it('should fire click handler when clicked', () => {
  el.querySelector<HTMLButtonElement>('button.p-button')!.click();
  expect(<handler-stub>).toHaveBeenCalled();
});
```

`p-button` renders a `<button>` with the `.p-button` class. The click event bubbles naturally.

### 10.3 p-checkbox

```typescript
import { CheckboxModule } from 'primeng/checkbox';
import { FormsModule } from '@angular/forms';

it('should toggle checked state', async () => {
  fixture.componentRef.setInput('checked', false);
  await fixture.whenStable();
  el.querySelector<HTMLDivElement>('.p-checkbox')!.click();
  await fixture.whenStable();
  expect(fixture.componentInstance.checked()).toBe(true);
});
```

The checkbox's clickable element is the wrapper `.p-checkbox` div, not the hidden `<input>`. Use the wrapper for the click target.

### 10.4 Common pitfalls

- **Asserting on a hidden `<input>` for the checkbox** — the actual input is `display: none`. Click the wrapper.
- **Missing `FormsModule` for the checkbox** — `p-checkbox` uses `[(ngModel)]` or signal-form integration; the test needs the right form module imported.
- **Missing `ReactiveFormsModule` for input with formControl** — same reason.

````

- [ ] **Step 5: Insert §11 p-fileupload**

```markdown
## 11. p-fileupload

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `FileUpload` API — the upload mode (`auto` vs `manual`), the `onUpload` event payload, and the `choose` / `upload` / `cancel` button selectors.

### 11.1 What to test

- The file input accepts files via `choose` event
- Clicking upload triggers the upload callback with the selected file
- Cancel button clears the selection

### 11.2 Pre-flight

- Identify the upload mode: `[mode]="'basic'"` (single button) vs `[mode]="'advanced'"` (table with progress).
- Note the upload handler — what does the component do with the file? Send to a service? Store locally?

### 11.3 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { FileUploadModule } from 'primeng/fileupload';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { <FileUploadHostComponent> } from '<relative-path>';

const <mockFile> = new File(['<contents>'], 'test.txt', { type: 'text/plain' });

describe('<FileUploadHostComponent>', () => {
  let fixture: ComponentFixture<<FileUploadHostComponent>>;
  let el: HTMLElement;
  let uploadHandler: ReturnType<typeof vi.fn>;

  beforeEach(async () => {
    uploadHandler = vi.fn();
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<FileUploadHostComponent>, {
      set: { imports: [FileUploadModule] },
    });
    fixture = TestBed.createComponent(<FileUploadHostComponent>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should trigger <upload-handler> when upload button is clicked', async () => {
    const fileInput = el.querySelector<HTMLInputElement>('input[type="file"]')!;
    // Simulate file selection
    Object.defineProperty(fileInput, 'files', { value: [<mockFile>] });
    fileInput.dispatchEvent(new Event('change'));
    await fixture.whenStable();

    // Click the upload button
    el.querySelector<HTMLButtonElement>('.p-fileupload-upload')!.click();
    await fixture.whenStable();

    expect(uploadHandler).toHaveBeenCalledWith(<mockFile>);
  });
});
````

### 11.4 Pitfalls

- **`Object.defineProperty` for the `files` property** — `<input type="file">` doesn't accept programmatic file assignment via `.files =`. Use `Object.defineProperty` to bypass the read-only protection.
- **Missing `dispatchEvent(new Event('change'))`** — setting `files` alone doesn't trigger PrimeNG's change handler. Dispatch the event manually.
- **Wrong button selector** — `.p-fileupload-upload` is the v17+ default. The cancel button is `.p-fileupload-cancel`.

````

- [ ] **Step 6: Insert §12 Renames from v17/v18**

```markdown
## 12. Renames from v17/v18

If the codebase predates PrimeNG v20, you'll see the old names. The pattern recipes still apply; only the import path and selector change.

| v17/v18        | v20+         | Notes                                                  |
| -------------- | ------------ | ------------------------------------------------------ |
| `Dropdown`     | `Select`     | Same `options` shape; `onChange` payload unchanged.    |
| `Calendar`     | `DatePicker` | `dateFormat` → still works, plus new `datePickerType`. |
| `TabView`      | `Tabs`       | `<p-tabView>` → `<p-tabs>`; `<p-tabPanel>` unchanged.  |
| `OverlayPanel` | `Popover`    | `show`/`hide` events; `appendTo` still works.          |
| `Sidebar`      | `Drawer`     | Same `(visible)` binding; new `position` input.        |

**How to detect:** open `package.json` and check the `primeng` version. If `^17.x` or `^18.x`, the codebase uses the old names.

**Migration in tests:** when the project upgrades, the recipes in this file work as-is; the writer only needs to update the import path and selector in `overrideComponent`. The patterns (animations, service stubs, query selectors via `.p-<component>`) are the same.
````

- [ ] **Step 7: Insert §13 Common Pitfalls**

```markdown
## 13. Common Pitfalls

A consolidated list of mistakes when testing PrimeNG components.

- **Missing `provideAnimationsAsync()`** — the most common error. PrimeNG v20+ components subscribe to animation events; without the provider, you get `NG0201` errors or silent test failures.
- **Using `NoopAnimationsModule`** — the wrong choice. It suppresses the events PrimeNG depends on. Use `provideAnimationsAsync()` instead.
- **Forgetting `MessageService` for `p-confirmpopup` and `p-toast`** — these components inject `MessageService` directly. Stub it in the providers list.
- **Asserting on portal-rendered DOM inside the component** — toasts, dialogs opened via `DialogService`, and overlays render in portals at `document.body`. Use `document.body.querySelector(...)` for those.
- **Importing the wrong module** — `primeng/dropdown` is v17/v18; `primeng/select` is v20+. The codebase's PrimeNG version determines which import path to use.
- **Setting `files` on an `<input type="file">` without `Object.defineProperty`** — the `files` property is read-only; the assignment silently fails.
- **Asserting on a closed dialog** — PrimeNG only inserts the dialog DOM when `visible` is true. Open it first, then query.
- **Asserting on a hidden checkbox `<input>`** — the actual clickable element is the `.p-checkbox` wrapper.
- **Not providing theme CSS in `angular.json`** — components render with `undefined` styles. Add the theme import to `test.options.styles`.
- **Stubbing services with `useClass` instead of `useValue`** — for `MessageService`, `ConfirmationService`, etc., `useValue: { add: vi.fn() }` is the right pattern. `useClass` requires implementing the full service.
```

- [ ] **Step 8: Verify §8-§13 are in place**

Run:

```bash
grep -n "^## [0-9]" README-TEST-PRIMENG-AGENT-GUIDE.md
```

Expected: at least 13 `## N.` headings (matching the TOC).

- [ ] **Step 9: Commit**

```bash
git add README-TEST-PRIMENG-AGENT-GUIDE.md
git commit -m "docs: add remaining PrimeNG recipes and renames/pitfalls sections"
```

---

## Task 17: Write the Common Mistakes Appendix and Quick Reference Table in the main guide

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md` (insert §6 and §7)

- [ ] **Step 1: Insert §6 Common Mistakes Appendix**

Add immediately after §5:

```markdown
## 6. Common Mistakes Appendix

The most common errors an LLM makes when writing Angular + Vitest tests. Each item is a single sentence; the recipes in §3 have more detail.

1. **Forgetting `await fixture.whenStable()`** after `setInput`, after form mutation, after signal change. The set-and-assert path silently fails.
2. **Forgetting `httpTesting.verify()` in `afterEach`** — un-flushed requests fail the next test, but a missing afterEach hook means the suite still passes while leaking requests.
3. **Forgetting `TestBed.flushEffects()`** after a signal mutation that triggers an effect or `httpResource`.
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
14. **Forgetting `provideAnimationsAsync()` for PrimeNG tests** — see §5 and the PrimeNG companion.
15. **Skipping the negative test** — `httpTesting.expectNone(...)` for "no HTTP when empty", `expect(...).toBeNull()` for "element should be absent". Negative tests catch over-firing.
```

- [ ] **Step 2: Insert §7 Quick Reference Table**

Add immediately after §6:

```markdown
## 7. Quick Reference Table

A condensed lookup. Use this when you need a quick reminder; the recipes in §3 have full templates.

| Unit                   | Test setup essentials                                        | Key assertion shape                                       |
| ---------------------- | ------------------------------------------------------------ | --------------------------------------------------------- |
| Pipe                   | `new <Pipe>(...)`                                            | `expect(pipe.transform(input)).toBe(expected)`            |
| Service (HTTP)         | `provideHttpClientTesting()` + `httpTesting`                 | `req = expectOne(url); flush(...); expect(signal())`      |
| Service (httpResource) | `flushEffects()` after inject                                | `expect(resource.value()).toBe(...)`                      |
| Interceptor            | `provideHttpClient(withInterceptors([fn]))`                  | `expect(req.request.<prop>).toBe(expected)`               |
| Component              | `TestBed.createComponent` + `NO_ERRORS_SCHEMA`               | `setInput(...) → whenStable → querySelector`              |
| Dialog                 | `DialogRef` + `DIALOG_DATA` `useValue` stubs                 | `expect(closeFn).toHaveBeenCalledWith(result)`            |
| Store                  | `flushEffects()` after mutation                              | `expect(store.<signal>()).toBe(<post-state>)`             |
| Guard (sync)           | `runInInjectionContext` + 3-arg invocation                   | `expect(serializeUrl(result)).toBe('/expected')`          |
| Guard (async)          | Same + `subscribe` + `httpTesting.flush`                     | Same as above                                             |
| Resolver               | `RouterTestingHarness` + `withComponentInputBinding`         | `expect(component.<input>()).toBe(<resolved>)`            |
| Directive              | `TestHostComponent` template                                 | `expect(querySelector('#id')).toBeNull()/.not.toBeNull()` |
| Form (signal)          | `service.<form>.<field>().value.set(...)` + `flushEffects()` | `expect(derived()).toBe(<expected>)`                      |
| Form (reactive)        | `ReactiveFormsModule` + `fixture.detectChanges()`            | Same shape, different mechanism                           |
| linkedSignal           | `linkedSignal(() => source()[0])`                            | After source change: `expect(derived()).toBe(<new>)`      |
| effect                 | `TestBed.runInInjectionContext(() => effect(...))`           | `expect(captured).toBe(<tracked-signal-value>)`           |
| afterRenderEffect      | `await fixture.whenStable()` after mutation                  | `expect(phaseCallback).toHaveBeenCalledWith(<data>)`      |
| @defer                 | `DeferBlockBehavior.Manual` + `getDeferBlocks()`             | `await render(DeferBlockState.<X>)` then assert           |
| Page                   | `RouterTestingHarness` + `navigateByUrl`                     | `expect(routeNativeElement?.<query>(...)).<assert>`       |
| PrimeNG component      | `provideAnimationsAsync()` + service stubs                   | Component-specific; see PrimeNG companion                 |
```

- [ ] **Step 3: Verify §6 and §7 are in place**

Run:

```bash
grep -n "^## [67]" README-TEST-AGENT-GUIDE.md
```

Expected: `## 6. Common Mistakes Appendix` and `## 7. Quick Reference Table`.

- [ ] **Step 4: Commit**

```bash
git add README-TEST-AGENT-GUIDE.md
git commit -m "docs: add common mistakes appendix and quick reference table"
```

---

## Task 18: Update the index in the four existing testing docs

**Files:**

- Modify: `README-TEST-GUIDE.md`
- Modify: `README-TESTING.md`
- Modify: `README-TEST-INSIGHTS.md`
- Modify: `README-TEST-CHRONOLOGY.md`

- [ ] **Step 1: Read the current index in each file**

For each of the four files, find the `> **Testing Docs Index:**` block at the top. The blocks differ in their existing entries.

- [ ] **Step 2: Update `README-TEST-GUIDE.md` index**

Read the current index block in `README-TEST-GUIDE.md` (lines 7-12). Insert two new lines after the existing `README-TEST-GUIDE.md` line:

```markdown
> - **README-TEST-AGENT-GUIDE.md** — LLM-facing recipe book for any Angular + Vitest project
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — PrimeNG v20+ companion cookbook
```

The new lines should appear immediately after the existing `README-TEST-GUIDE.md — This file: how to write tests (Angular recommended + project patterns)` line.

- [ ] **Step 3: Update `README-TESTING.md` index**

Read the current index block in `README-TESTING.md`. Insert the same two new lines after the existing `README-TESTING.md` line.

- [ ] **Step 4: Update `README-TEST-INSIGHTS.md` index**

Read the current index block in `README-TEST-INSIGHTS.md` (lines 5-10). Insert the two new lines after the existing `README-TEST-INSIGHTS.md` line.

- [ ] **Step 5: Update `README-TEST-CHRONOLOGY.md` index**

Read the current index block in `README-TEST-CHRONOLOGY.md`. Insert the two new lines after the existing `README-TEST-CHRONOLOGY.md` line. If this file doesn't have an index block, add one at the top in the same format as the others.

- [ ] **Step 6: Verify all four indexes reference both new files**

Run:

```bash
grep -l "README-TEST-AGENT-GUIDE.md" README-TEST-GUIDE.md README-TESTING.md README-TEST-INSIGHTS.md README-TEST-CHRONOLOGY.md
```

Expected: all four files listed (each one has at least one match for the new file name).

Run:

```bash
grep -l "README-TEST-PRIMENG-AGENT-GUIDE.md" README-TEST-GUIDE.md README-TESTING.md README-TEST-INSIGHTS.md README-TEST-CHRONOLOGY.md
```

Expected: all four files listed.

- [ ] **Step 7: Commit**

```bash
git add README-TEST-GUIDE.md README-TESTING.md README-TEST-INSIGHTS.md README-TEST-CHRONOLOGY.md
git commit -m "docs: add agent guide and PrimeNG cookbook to testing docs index"
```

---

## Task 19: Final cross-reference verification

**Files:** (no changes; this is a verification task)

- [ ] **Step 1: Verify the main guide's TOC matches the actual headings**

Run:

```bash
grep -n "^## " README-TEST-AGENT-GUIDE.md
```

Compare against the TOC in the front matter. Every TOC entry should have a matching heading. If any drift, fix the TOC (it's a doc fix, not a new task).

- [ ] **Step 2: Verify the PrimeNG companion's TOC matches the actual headings**

Run:

```bash
grep -n "^## " README-TEST-PRIMENG-AGENT-GUIDE.md
```

Compare against the TOC. Fix any drift.

- [ ] **Step 3: Verify all internal cross-references resolve**

For every markdown link in both new files that points to another local file (e.g., `[README-TEST-PRIMENG-AGENT-GUIDE.md](README-TEST-PRIMENG-AGENT-GUIDE.md)`), confirm the target exists:

```bash
ls README-TEST-PRIMENG-AGENT-GUIDE.md
```

If any link points to a non-existent file, fix the link.

- [ ] **Step 4: Verify the Angular API references in the main guide are correct**

Spot-check 5 random Angular API references against the `angular-cli` MCP `search_documentation` tool:

- `provideHttpClientTesting` — confirm import path `@angular/common/http/testing`.
- `TestBed.flushEffects` — confirm method exists.
- `CanMatchFn` — confirm 3-arg signature.
- `withComponentInputBinding` — confirm import path `@angular/router`.
- `DeferBlockBehavior` — confirm import path `@angular/core/testing`.

Fix any drift inline.

- [ ] **Step 5: Verify the PrimeNG API references in the companion are correct**

Spot-check 3 random PrimeNG API references against `https://primeng.org/mcp`:

- `TableModule` import path.
- `provideAnimationsAsync` import path (`@angular/platform-browser/animations/async`).
- `MessageService` import path (`primeng/api`).

Fix any drift inline.

- [ ] **Step 6: Verify no leftover TODOs or placeholders**

Run:

```bash
grep -nE "TODO|TBD|FIXME|XXX|fill in|implement later" README-TEST-AGENT-GUIDE.md README-TEST-PRIMENG-AGENT-GUIDE.md
```

Expected: no output (no placeholders).

- [ ] **Step 7: Final commit if any fixes were made**

If Steps 1-6 required any changes, commit them:

```bash
git add README-TEST-AGENT-GUIDE.md README-TEST-PRIMENG-AGENT-GUIDE.md
git commit -m "docs: fix cross-references and API drift found in final verification"
```

If no changes were needed, no commit is necessary.

---

## Self-Review

**Spec coverage:**

| Spec section                                                                                                            | Implemented in                                                                                                                              |
| ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| §2 Goal                                                                                                                 | Plan-level (all tasks)                                                                                                                      |
| §3 Non-goals                                                                                                            | Implicit — no e2e/integration/a11y/visual tasks; no coverage config; no realworld-angular refactoring; no skill/command                     |
| §4.1 Primary deliverable structure (front matter, decision tree, recipes, cross-cutting, PrimeNG stub, common mistakes) | Tasks 1-3, 4-11, 12, 13, 17                                                                                                                 |
| §4.2 PrimeNG companion (one or more files)                                                                              | Tasks 14-16 (single file by default)                                                                                                        |
| §4.3 Index update                                                                                                       | Task 18                                                                                                                                     |
| §5 Recipe template (5 blocks)                                                                                           | Verified across all per-unit tasks (What to test, Pre-flight, Recipe template, Common variants, Pitfalls)                                   |
| §6.1 primeng.org MCP as live reference                                                                                  | Tasks 14-16 each lead with the MCP directive                                                                                                |
| §6.2 Universal setup                                                                                                    | Task 14                                                                                                                                     |
| §6.3 v20 renames                                                                                                        | Task 16 (§12)                                                                                                                               |
| §6.4 Top 8-10 components                                                                                                | Tasks 15-16 cover table, dialog, select, datepicker, confirmpopup, toast, inputtext/button/checkbox, fileupload (10 components)             |
| §7 Writing process                                                                                                      | Each task includes "verify against MCP" step                                                                                                |
| §8 Verification before completion                                                                                       | Task 19 (final cross-reference verification)                                                                                                |
| §9 Length budget                                                                                                        | Main guide: ~1800-2500 lines target; PrimeNG: ~2000-3000 lines target. Tasks produce approximate targets — writer can adjust at write time. |

**Placeholder scan:** No `TODO`, `TBD`, `FIXME`, `fill in`, or `implement later` in any task. Every `<placeholder>` is a documented substitution the writer fills in from the source.

**Type/name consistency:**

- `provideHttpClientTesting` — same in Tasks 5, 9, 11.
- `TestBed.flushEffects` — same in Tasks 5, 9, 10, 11.
- `provideAnimationsAsync` — same in Tasks 15, 16.
- `MessageService`, `ConfirmationService`, `DialogService`, `DynamicDialogRef` — same in Tasks 14, 16.
- `provideRouter` — same in Tasks 10, 11.
- `RouterTestingHarness` — same in Tasks 11, 13.
- File names: `README-TEST-AGENT-GUIDE.md` and `README-TEST-PRIMENG-AGENT-GUIDE.md` are consistent across all tasks.

No issues found. Plan is ready for execution.
