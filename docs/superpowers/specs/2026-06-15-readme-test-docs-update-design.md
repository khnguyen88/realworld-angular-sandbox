# Design: Update README Test Documentation

## Date

2026-06-15

## Context

The realworld-angular test suite has changed since the README test documentation files were last written. The latest local run (2026-06-15) now passes completely:

- **59/59 spec files pass**
- **350/350 tests pass**
- No remaining failures

The existing README test files still report a failing Photon test and stale counts. They also contain code examples that no longer match the current specs. This document defines the scope and rules for updating all README test documentation files so they are factually accurate and aligned with current Angular 22 + Vitest best practices.

## Goals

1. Make every README test doc factually accurate with the current test suite state.
2. Refresh code examples in README-TEST-GUIDE.md and README-TESTING.md to match the actual `.spec.ts` files.
3. Keep README-TEST-AGENT-GUIDE.md and README-TEST-PRIMENG-AGENT-GUIDE.md focused on current Angular 22 + Vitest best-practice recipes.
4. Preserve the distinction between factual project examples and [Illustrative] examples derived from Angular/PrimeNG docs.
5. Use Angular MCP/skills and the PrimeNG MCP as authoritative sources for API and testing guidance.

## Files and Update Rules

| File                                 | Update Type                      | Rules                                                                                                                                                                                             |
| ------------------------------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `README-TEST-INSIGHTS.md`            | Purely factual                   | Update counts, pass/fail status, failure table, lint status, alignment scores, and improvement roadmap based on current run.                                                                      |
| `README-TESTING.md`                  | Purely factual                   | Update test runner section, latest run result, spec/test counts, inventory tables, and code snippets extracted from real specs.                                                                   |
| `README-TEST-CHRONOLOGY.md`          | Purely factual                   | Add Phase 8/9 for the latest green run, correct spec/test totals, and refresh cross-reference tables.                                                                                             |
| `README-TEST-GUIDE.md`               | Factual + best-practice guidance | Refresh real-world examples from current specs. Add [Illustrative] sections only when backed by Angular 22 official docs/skills. Keep Angular Recommended and Project Pattern columns accurate.   |
| `README-TEST-AGENT-GUIDE.md`         | Best-practice recipes            | Update recipes to current Angular 22 + Vitest conventions. Use real-world-angular examples only when they align with official recommendations; otherwise keep the recipes generic and principled. |
| `README-TEST-PRIMENG-AGENT-GUIDE.md` | Best-practice + PrimeNG recipes  | Update to current PrimeNG v20+ patterns. Use Angular MCP/skills and PrimeNG MCP as sources. Keep real-world-angular mentions minimal and only when they demonstrate correct current usage.        |

## Source of Truth Priority

When a fact or example is in doubt, use this priority:

1. The current `realworld-angular/` source and `.spec.ts` files.
2. Angular 22 official documentation (via MCP `search_documentation`).
3. Angular best-practices from `get_best_practices` (workspace already loaded).
4. PrimeNG v20+ documentation (via PrimeNG MCP when available).
5. Existing README files only for structure and prose, not for factual claims.

## Proposed Approach

1. **Run a parallel read pass** over all 59 spec files and group them by category (services, stores, interceptors, guards, shared components, feature pages, feature components, layout, directives, pipes).
2. **Extract representative snippets** for README-TESTING.md and README-TEST-GUIDE.md from real specs.
3. **Update factual docs** (INSIGHTS, TESTING, CHRONOLOGY) with current numbers and remove all references to the Photon failure.
4. **Refresh README-TEST-GUIDE.md** with current real-world examples and clearly mark any new illustrative sections with `[Illustrative]`.
5. **Verify README-TEST-AGENT-GUIDE.md** recipes against Angular 22 docs/skills; update only where conventions have drifted.
6. **Verify README-TEST-PRIMENG-AGENT-GUIDE.md** against PrimeNG MCP/docs; update service stubs, selectors, and animation advice.
7. **Run `pnpm run test` again** after any doc changes to confirm the suite still passes and no docs accidentally reference removed files.

## Out of Scope

- Fixing production code or the test suite itself (it is already green).
- Adding new tests, harnesses, coverage, e2e, or CI.
- Rewriting history or commit attributions.
- Removing the `[Illustrative]` marker from sections that are genuinely illustrative.

## Approval Gate

After this design is approved, the implementation plan will be written and executed. Updates to the README files will be made by subagents per file, with the factual docs updated first and the guide/cookbook files updated second.
