# Test Creation Agent Guide — Design

**Date:** 2026-06-10
**Status:** Approved (pending user spec review)
**Owner:** TBD

## 1. Problem

The sandbox has a 2,334-line `README-TEST-GUIDE.md` written as a **human-facing** tour of test patterns observed in the `realworld-angular` reference project. It is excellent for human readers who want to learn what the project does, but it is poorly suited as a reference for an **LLM** that has been asked to _create_ a test suite for a different Angular + Vitest codebase.

Specific gaps for LLM consumption:

- **"Tour" framing** — reads top to bottom; an LLM mid-task needs a recipe lookup, not a narrative.
- **Project-specific content** — "Project Pattern" sections are full reproductions of real `*.spec.ts` files in `realworld-angular/`. An LLM asked to test a different codebase will get the wrong imports, the wrong entity names (`Pizza Roma`, `Margherita`, `p1`), and the wrong API endpoints.
- **`[Illustrative]` labeling is misleading** for the LLM use case — the LLM doesn't need to know what's illustrated vs. real; it needs recipes for whatever the codebase actually has.
- **PrimeNG absent** — Angular apps frequently use PrimeNG for UI primitives. The current guide covers CDK dialogs but nothing about PrimeNG's component library, theming requirements, animation providers, or service stubs.

## 2. Goal

Produce an **LLM-portable test creation guide** that any LLM (any vendor) can load as a reference when given the task "write tests for this Angular + Vitest codebase." The guide must work without modification for any Angular project using Vitest, regardless of whether the project uses CDK, PrimeNG, signal forms, lazy routes, httpResource, etc.

## 3. Non-goals (YAGNI)

- E2E, integration, accessibility, visual regression — different tooling, different docs.
- Coverage measurement configuration.
- Real-world-angular project patterns (the existing `README-TEST-GUIDE.md` already covers those for humans).
- PrimeNG v17/v18 specifics — v20.2+ only, with a renames table for cross-version lookup.
- Refactoring `README-TEST-GUIDE.md` — it serves a different (human) audience and stays as-is.
- A custom slash command or skill — the user wants a README.

## 4. Deliverables

### 4.1 Primary (always)

**`README-TEST-AGENT-GUIDE.md`** at the sandbox root, added to the testing docs family.

Sections, in order:

1. **Front matter** — "you are an LLM writing tests for an Angular + Vitest project. This guide is your reference." Usage instructions, the universal "always" list (Vitest imports, `await fixture.whenStable()`, `httpTesting.verify()`, `TestBed.flushEffects()`), and pre-flight checks (Angular version, builder, no Jasmine globals).
2. **Decision tree** — file-extension → recipe mapping. Mechanical lookup so the LLM doesn't have to read the whole guide.
3. **Per-unit recipes** — pipes, services, interceptors, components, dialogs, stores, guards, resolvers, directives, forms, signal primitives, @defer, page components. Each follows the template in §5.
4. **Cross-cutting concerns** — async testing with Vitest (`vi.waitFor`, `vi.useFakeTimers`), provider strategies, signal-based inputs/outputs, `TestBed.flushEffects()`, zoneless testing, standalone components.
5. **PrimeNG section (stub)** — 30-50 lines that say "if the component uses PrimeNG, see the companion file(s)." The companion file(s) are the pattern authority; `https://primeng.org/mcp` is the live API reference.
6. **Common mistakes appendix** — anti-patterns an LLM commonly produces (missing `whenStable`, asserting wrong redirect URL shape, not flushing effects, etc.).

### 4.2 PrimeNG content (flexible)

Default: one file `README-TEST-PRIMENG-AGENT-GUIDE.md`.

Permitted to split into multiple files (e.g., separate universal-setup + per-component cookbook) if either:

- The single file would exceed ~3000 lines, **or**
- A clean logical seam emerges at write time (e.g., "this is setup, this is per-component").

Decision is the writer's judgment at write time, not pre-decided.

If split, the files share the same naming convention (`README-TEST-PRIMENG-AGENT-GUIDE-*.md`) and the main guide's PrimeNG stub links to all of them.

### 4.3 Index update

Add the new file(s) to the index block in all four existing testing docs:

- `README-TEST-GUIDE.md` (the human guide — gets a "see also" link to the agent guide)
- `README-TESTING.md` (factual inventory)
- `README-TEST-INSIGHTS.md` (quality evaluation)
- `README-TEST-CHRONOLOGY.md` (creation history)

## 5. Recipe template (the load-bearing design decision)

Every per-unit recipe in the main guide, and every per-component recipe in the PrimeNG companion, follows the **same five-block template**:

### Block 1: What to test

A bullet list of behaviors to assert, in order of priority. Examples:

- **Pipes**: valid input, edge cases (empty, null, special characters), encoding/escaping
- **Services**: initial state, every public method (URL, method, body, post-response state), error handling
- **Guards**: true when condition met, `UrlTree` (with the **specific** redirect path) when not

### Block 2: Pre-flight

Tells the LLM what to read in the source file **before** writing the test:

- Public method names (used to drive `it()` test names)
- Constructor dependencies (drives the `providers` array)
- Signals and computed signals (drives what to assert on state)
- Lifecycle hooks that affect test setup

### Block 3: Recipe template

An importable code block with `<substitution>` placeholders. Example shape:

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { <ServiceClassName> } from '<relative-path-to-service>';

describe('<ServiceClassName>', () => {
  let service: <ServiceClassName>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      // <providers-needed>
    });
    service = TestBed.inject(<ServiceClassName>);
  });

  it('should <expected-behavior>', () => {
    // <test-body>
  });
});
```

No hardcoded project names, no `Pizza Roma`, no `/api/pizzerias` — those are realworld-angular specifics. The LLM substitutes from the source.

### Block 4: Common variants

3-5 short variations on the template for the most common cases:

- Variant: HTTP service
- Variant: service with `httpResource`
- Variant: service with effects
- Variant: service with form integration
- Variant: async service returning Observable

### Block 5: Pitfalls

The 2-4 mistakes an LLM most commonly makes for this unit type. Examples:

- **Guards**: asserting the `UrlTree` instance but not the specific redirect URL
- **Stores**: not calling `TestBed.flushEffects()` after mutation
- **Dialogs**: not stubbing `DialogRef.close` so the test hangs on `await dialogRef.closed`

## 6. PrimeNG integration (the design choice that prevents drift)

PrimeNG ships a major version roughly annually. Per-component selectors, events, and template syntax can change between versions. The guide must not go stale.

### 6.1 The MCP is the API source of truth

Every per-component recipe in the PrimeNG companion file(s) begins with a directive:

> **primeng.org MCP:** before writing assertions for this component, query `https://primeng.org/mcp` for the current `<ComponentName>` API — selector, events, template syntax. The patterns below are version-stable; the API details are not.

This means the cookbook is the _pattern_ (setup, service stubs, animation provider, theme CSS in jsdom), and the MCP fills in the _current API_ at runtime. The cookbook never needs to be rewritten for a new PrimeNG version; only the MCP needs to be queried.

### 6.2 Universal setup (version-stable)

- `provideAnimationsAsync()` (PrimeNG v20+ uses async animations)
- `NoopAnimationsModule` is the wrong choice — it suppresses animation events PrimeNG depends on
- Theme CSS in `angular.json` `test.options.styles`
- Service stubs for `MessageService`, `ConfirmationService`, `DialogService`, `DynamicDialogRef`

### 6.3 v20 renames table (helps with older codebases)

| v17/v18        | v20+         |
| -------------- | ------------ |
| `Dropdown`     | `Select`     |
| `Calendar`     | `DatePicker` |
| `TabView`      | `Tabs`       |
| `OverlayPanel` | `Popover`    |
| `Sidebar`      | `Drawer`     |

### 6.4 Components to cover (top 8-10 by common use)

In priority order:

1. `p-table` (most complex; server-side pagination, sort, filter)
2. `p-dialog` (and `DialogService`-opened dialogs)
3. `p-select` / `p-dropdown` (both names valid depending on version)
4. `p-datepicker` / `p-calendar`
5. `p-confirmpopup`
6. `p-toast`
7. `p-inputtext`
8. `p-button`
9. `p-checkbox`
10. `p-fileupload`

## 7. Writing process

1. **Write `README-TEST-AGENT-GUIDE.md` first** as a single coherent document. The existing `README-TEST-GUIDE.md` is the human reference; the new file is the LLM reference. They share a knowledge base but are not derived from each other.
2. **Write the PrimeNG companion file(s) second.** Decide at write time whether to split.
3. **Update the index in all four existing testing docs.**
4. **Verify before claiming done** (§8).
5. **Commit per `CLAUDE.md`** — no AI attribution in commit messages, no `--no-verify`, no force-push.

## 8. Verification before completion

Before claiming either file is "done":

### 8.1 Generic recipes (main guide)

For every API referenced (e.g., `provideHttpClientTesting`, `TestBed.flushEffects`, `DeferBlockState`, `CanMatchFn`, `withComponentInputBinding`, `RouterTestingHarness`):

- Query the `angular-cli` MCP `search_documentation` tool with the Angular version in use.
- Cross-check the API name, signature, and import path against the search result.
- Fix any drift inline.

### 8.2 PrimeNG content

For every component covered:

- Query `https://primeng.org/mcp` for the current component selector, events, and template syntax.
- Confirm the rename status in the renames table.
- Fix any drift inline.

### 8.3 Cross-references

- The main guide's PrimeNG stub links to the companion file(s).
- The four existing testing docs' index blocks list the new file(s).
- The TOC in each new file is consistent with its section structure.
- No broken internal links.

### 8.4 Quality bar

A recipe is "done" when:

- An LLM reading the recipe alone can write a passing test for a representative example without further lookups beyond the primeng.org MCP for PrimeNG APIs.
- The recipe's pre-flight block tells the LLM exactly which signals/methods/dependencies to look up in the source.
- The recipe's template uses `<substitution>` placeholders consistently (no hardcoded realworld-angular specifics).
- The recipe's "common variants" covers the most common variations without bloating.
- The recipe's "pitfalls" lists the 2-4 most common LLM errors for that unit type.

## 9. Length budget

- **Main guide: ~1800-2500 lines.** Recipes are dense; the structure carries the load.
- **PrimeNG content: ~2000-3000 lines total**, distributed across one or more files at writer's discretion.
- Both well under typical LLM context windows so a single file can be loaded at once.

## 10. Audience and non-audience

**Audience:** an LLM (any vendor) that has been told to write tests for a given Angular + Vitest codebase. The guide is the LLM's reference; the codebase under test provides the actual code.

**Non-audience:** humans learning what the realworld-angular project tests. That audience is served by the existing `README-TEST-GUIDE.md`. If a human wants a tour, they read the human guide. If an LLM wants a recipe, it reads the agent guide.

## 11. Out-of-scope clarifications

- **No new test code is being written in this project.** The guide is documentation, not implementation.
- **No realworld-angular source files are modified.** Only the testing docs family is updated.
- **No changes to `CLAUDE.md`, `package.json`, or any tooling.**
- **No CI changes.**

## 12. Open questions

None. All design decisions resolved during the brainstorming session.

## 13. Next step

Invoke the `superpowers:writing-plans` skill to break the spec into ordered implementation tasks.
