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

Open `package.json` and check the `@angular/core` version. The patterns in this guide target **Angular 20+** (signals, `httpResource`, signal-based inputs/outputs are the default). For Angular 19 or earlier, some APIs differ (`inject(TestBed)` patterns, decorator-based inputs, etc.) — flag this to the user before proceeding.

### 1.4 Confirm no Jasmine globals

Search the test config and a sample spec for `jasmine.`, `fit(`, `fdescribe(`, or any `tsconfig.spec.json` `types: ["jasmine"]`. If found, this is a mixed or migrating project. Most recipes still work, but `vi.fn()` should be used instead of `jasmine.createSpy()`.

### 1.5 Identify the project's testing utility conventions

Some projects have a `src/test-providers.ts` or similar global providers file referenced from `angular.json`. If present, the `beforeEach` blocks in the recipes below can drop providers that the global file already supplies. If absent (the default), every spec is self-contained — apply the recipe verbatim.

### 1.6 What to do if pre-flight fails

- **No vitest**: tell the user. Don't try to write tests; the project isn't set up for them.
- **Wrong Angular version**: ask the user. The guide's recipes need translation for v19 and earlier.
- **Mixed Jasmine/Vitest**: ask the user which runner to target, then proceed.
