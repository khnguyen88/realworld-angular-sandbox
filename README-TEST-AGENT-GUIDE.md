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
