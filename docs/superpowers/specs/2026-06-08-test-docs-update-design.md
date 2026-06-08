# Test Documentation Update — Design Spec

**Date:** 2026-06-08
**Status:** Approved

## Goal

Update three testing documentation files using Angular skill references and MCP tools to
produce the truest and most correct testing guidance. No changes to the realworld-angular
project itself.

## File Map

| File | Role | Action |
|------|------|--------|
| `README-TEST-GUIDE.md` | Actionable "how to test" reference | Major rewrite — dual-pattern sections |
| `README-TEST-INSIGHTS.md` | Quality evaluation & improvement roadmap | Restructure around MCP/skill cross-check |
| `README-TESTING.md` | Factual inventory of what exists | Refine with alignment badges & cross-links |

---

## README-TEST-GUIDE.md — Full Design

### Structure (new, 11 sections)

1. Decision Flow — which test type + which approach?
2. Pipes (moved first — simplest, no controversy)
3. Services
4. Interceptors
5. Stores / State
6. Components (presentational)
7. Page Components (smart / container)
8. Guards
9. Directives
10. Forms & Wizard Services
11. Quick Reference Table (dual-column)

### Section 1: Decision Flow

Add a second branch: "Angular recommended or project pattern?"
- Refer to the decision rules in each section
- Cross-reference: use Angular recommended for new code, project pattern for
  maintaining existing code

### Section 2: Pipes

- No structural change. Pure pipes are uncontroversial — both Angular docs and
  project agree: `new Pipe()`, no TestBed.
- Keep current code examples.

### Section 3: Services

Two subsections:

**Angular Recommended:** Same as current (HttpTestingController).
**Project Pattern:** Same code.
Callout: "✓ This project pattern matches Angular recommendations."

Add: Reference to Angular skill's `resource.md` for testing services that use
`httpResource` (the skill documents async reactivity patterns).

### Section 4: Interceptors

Two subsections:

**Angular Recommended:** Same as current (real HttpClient + withInterceptors).
**Project Pattern:** Same code.
Callout: "✓ No gap."

### Section 5: Stores / State

Two subsections:

**Angular Recommended:** Add `httpResource` testing patterns from skill references.
**Project Pattern:** Current code plus note that `httpTesting.match()` is a project
innovation for multi-request scenarios.

Add references to Angular skill: `resource.md`, `linked-signal.md`.

### Section 6: Components (Presentational)

**This is the biggest change.** Two subsections:

**Angular Recommended — Component Harnesses:**
```
- Use TestbedHarnessEnvironment.loader(fixture) + HarnessLoader
- Create a custom harness class for the component
- Interact via harness methods (click, getText, isDisabled)
- Reference: angular-developer skill component-harnesses.md
```

**Project Pattern — querySelector + NO_ERRORS_SCHEMA:**
```
- Keep current code examples
- fixture.componentRef.setInput() + await whenStable() + querySelector
```

**Decision rule:**
- Use harnesses for shared component libraries and components consumed by many tests
- Use querySelector for one-off page components where harness overhead isn't justified
- Replace "querySelector is simpler and just as correct" with "querySelector works
  but harnesses are more robust against template refactors"

**NO_ERRORS_SCHEMA guidance:**
- Appropriate for leaf components tested in isolation
- Prefer real `imports` when testing component integration
- Angular docs warn against blanket use

### Section 7: Page Components

Two subsections:

**Angular Recommended — RouterTestingHarness + real imports:**
```
- TestBed with provideRouter([...]) containing actual routes
- RouterTestingHarness.create() then navigateByUrl()
- No NO_ERRORS_SCHEMA — use real child component imports
- Reference: angular-developer skill router-testing.md
```

**Project Pattern — provideRouter + NO_ERRORS_SCHEMA + querySelector:**
```
- Keep current code examples
- Note: this tests the page in isolation, not the integration with its child routes
```

**Decision rule:**
- Use RouterTestingHarness when you want to verify the full routing context
- Use current pattern for quick smoke tests of page-level DOM structure

### Section 8: Guards

**Second biggest change.** Two subsections:

**Angular Recommended — RouterTestingHarness:**
```
- provideRouter([{path: 'admin', component: AdminPage, canActivate: [authGuard]}])
- harness.navigateByUrl('/admin') — if guard blocks, expect harness.router.url to stay at /login
- Tests the full pipeline: guard + redirect + component activation
```

**Project Pattern — runInInjectionContext + vi.fn():**
```
- Keep current code examples
- CRITICAL FIX: All examples must use 3-argument signature for Angular 22:
  (route, segments, {} as PartialMatchRouteSnapshot)
- Include async guard pattern (Observable return type) with subscribe + flush
```

**Decision rule:**
- Use RouterTestingHarness for integration-style guard tests
- Use runInInjectionContext for unit-testing guard logic in isolation

### Section 9: Directives

- No structural change. Host component pattern is canonical for both Angular
  recommended and project. No gap.
- Keep current code and key rules.

### Section 10: Forms & Wizard Services

Two subsections:

**Angular Recommended:** Add signal-forms testing patterns from skill references.
**Project Pattern:** Keep current code (real service + stubbed deps).

Add references: Angular skill `signal-forms.md`, `effects.md` (for effect-driven
form validation).

### Section 11: Quick Reference Table

Expand to dual-column format:

| Unit | Angular Recommended | Project Pattern | Key Difference |
|------|-------------------|-----------------|----------------|
| Service | HttpTestingController | HttpTestingController | ✓ Same |
| Component | Component Harnesses | querySelector + NO_ERRORS_SCHEMA | Harness vs raw DOM |
| Page | RouterTestingHarness + real imports | provideRouter + NO_ERRORS_SCHEMA | Integration vs isolation |
| Guard | RouterTestingHarness | runInInjectionContext + vi.fn() | Full pipeline vs unit |
| Interceptor | withInterceptors + real HttpClient | withInterceptors + real HttpClient | ✓ Same |
| Pipe | new Pipe() | new Pipe() | ✓ Same |
| Directive | Host component | Host component | ✓ Same |
| Store | httpResource patterns | httpTesting.match() | ✓ Mostly same |
| Wizard | Real service + stubs | Real service + stubs | ✓ Same |

---

## README-TEST-INSIGHTS.md — Full Design

### Structure (7 sections)

1. **TL;DR** — Add MCP/skill cross-check status line
2. **Current Run Status** — RED (18 guard errors + hidden fixture errors)
3. **Angular Skill/MCP Cross-Check** (NEW — core addition)
4. **Strengths** — Add "validated against official docs" note
5. **Weaknesses** — Split into Blocking vs Structural
6. **Improvement Roadmap** — Tiers 1/2/3
7. **Appendix** — Data sources

### Section 3: Cross-Check Table

| Category | Project Pattern | Angular Recommendation | Alignment | Priority |
|----------|----------------|----------------------|-----------|----------|
| Services | HttpTestingController | HttpTestingController | ✓ Aligned | — |
| Interceptors | withInterceptors + HttpClient | withInterceptors + HttpClient | ✓ Aligned | — |
| Pipes | new Pipe() | new Pipe() | ✓ Aligned | — |
| Directives | Host component | Host component | ✓ Aligned | — |
| Stores | TestBed.flushEffects + httpTesting.match | httpResource testing | ✓ Mostly aligned | Low |
| Forms | Real service + stubs | Signal forms + real service | ✓ Mostly aligned | Low |
| Components | querySelector + NO_ERRORS_SCHEMA | Component Harnesses | ⚠ Misaligned | Medium |
| Pages | NO_ERRORS_SCHEMA + provideRouter | RouterTestingHarness + real imports | ⚠ Misaligned | Medium |
| Guards | runInInjectionContext (2-arg, outdated) | RouterTestingHarness (3-arg for v22) | ✗ Blocked | High |

**Score: 7/10 categories aligned, 2 with actionable gaps, 1 blocked.**

### Section 5: Weaknesses — Two Groups

**Blocking (must fix to run tests):**
1. 18 guard signature errors (TS2554) — Angular 22 3rd argument
2. Hidden fixture-drift errors (5 errors, currently masked)

**Structural (design improvements):**
3. No component harnesses — shared component tests vulnerable to template refactors
4. No RouterTestingHarness — guards tested in isolation, not in routing context
5. No coverage measurement — can't quantify test depth
6. NO_ERRORS_SCHEMA on pages — tests verify structure, not integration

### Section 6: Improvement Roadmap

**Tier 1 — Unblock:**
1. Fix 18 guard signature errors (add 3rd argument to all guard invocations)
2. Fix re-surfaced fixture-drift errors

**Tier 2 — Align with Angular:**
3. Add component harnesses to high-value shared components (Button, Input, Modal)
4. Add RouterTestingHarness examples for guard integration tests
5. Add signal-forms testing patterns

**Tier 3 — Measure & Protect:**
6. Add @vitest/coverage-v8 with coverage thresholds
7. Add CI job (GitHub Actions: pnpm install && pnpm test)
8. Add 1-2 smoke e2e tests with Playwright

---

## README-TESTING.md — Full Design

### Structure (5 sections, refined)

1. **Infrastructure** — unchanged
2. **Running Tests** — unchanged
3. **Test Inventory** — unchanged, add cross-reference header
4. **Testing Patterns** — add alignment badges per subsection
5. **Coverage Gap Analysis** — updated

### Cross-Reference Header (top of file)

> **Testing Docs Index:**
> - **README-TEST-GUIDE.md** — How to write tests (Angular recommended + project patterns)
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — This file: factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

(Same header appears on all three documents.)

### Section 4: Pattern Alignment Badges

Each subsection gets a badge:

- **Services & APIs** → `✓ Aligned with Angular`
- **Stores** → `✓ Aligned` + note about httpResource
- **Interceptors** → `✓ Aligned`
- **Functional Guards** → `⚠ Works but has better alternative` — note about Angular 22 3-arg signature + RouterTestingHarness. Link to guide.
- **Components** → `⚠ Works but has better alternative` — note about harness alternative. Link to guide.
- **Dialogs & Overlays** → `✓ Aligned`
- **Directives** → `✓ Aligned`
- **Pipes** → `✓ Aligned`

### Section 5: Coverage Gap Analysis

Update:
- "Route integration" — now partially addressed (guide documents RouterTestingHarness)
- "Component harnesses" — now on the roadmap (guide documents pattern, insights prioritizes)
- Add: Link to insights for prioritized improvement roadmap

---

## Implementation Order

1. README-TEST-GUIDE.md (largest change, ~3 hours)
2. README-TEST-INSIGHTS.md (restructure + new section, ~2 hours)
3. README-TESTING.md (refinements only, ~1 hour)
4. Cross-link all three documents
5. Self-review against spec
6. User review
