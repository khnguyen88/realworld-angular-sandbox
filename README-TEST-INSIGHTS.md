# Test Coverage & Unit Test Quality — Insights

> **Testing Docs Index:**
> - **README-TEST-GUIDE.md** — How to write tests (Angular recommended + project patterns)
> - **README-TEST-INSIGHTS.md** — This file: quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists (60 specs, categories, patterns)
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

> **Status snapshot (2026-06-08):** The test suite is comprehensive in scope and well-structured, but it is **not currently green**. 18 TypeScript compile errors prevent `pnpm run test` from producing any results. All stem from Angular 22.0's `CanActivateFn` / `CanMatchFn` signature change. This document evaluates the suite against two external standards: Angular official docs (via MCP `search_documentation`) and Angular skill references.

---

## TL;DR

| Question | Answer |
| --- | --- |
| How many test files? | **60 `*.spec.ts`** co-located with source. |
| How much test code? | **~5,188 lines** of test code vs. **~3,743 lines** of source. |
| Is the suite green? | **No** — `pnpm run test` fails at the TypeScript build step with **18 errors across 5 guard spec files**. |
| Angular Skill/MCP Cross-Check | **7/10 categories aligned** with official recommendations. 2 categories have actionable gaps (components, pages), 1 category blocked (guard signatures outdated). |
| How does it perform on the unit-test axis? | **Strong** in pattern discipline and breadth, but **failing** in Angular version compatibility and alignment with modern practices. |
| Is coverage measured? | **No** — no `vitest.config.ts`, no `@vitest/coverage-v8`, no thresholds in `package.json`. |
| Are there other test types? | **None** — no e2e, no integration, no a11y, no visual regression. |

---

## 1. Project Context (from `README.md`)

The project is a **learning / reference implementation** of a RealWorld Angular SPA (Angular 22, standalone components, signals, lazy routes, SSE). It targets a deployed API at `api.realworldangular.org` and is **explicitly a playground, not a real marketplace**.

That framing matters for the conclusions below: this is reference code whose purpose is partly to *demonstrate* testing patterns, so the quality of the *patterns* themselves matters as much as the percentage coverage.

---

## 2. Current Run Status — RED

`pnpm run test` (i.e. `ng test --watch=false`) currently **fails to compile**. 18 TypeScript errors, all `TS2554` ("Expected 3 arguments, but got 2"):

| File | Errors | Root cause |
| --- | --- | --- |
| `core/guards/auth/auth.guard.spec.ts` | 4 | Angular 22.0 changed `CanActivateFn` / `CanMatchFn` to require a 3rd argument (`currentSnapshot: PartialMatchRouteSnapshot`). Guard specs call guards with only 2 args (`route`, `segments`). |
| `core/guards/role/role.guard.spec.ts` | 4 | Same — `roleGuard([...])(route, segments)` missing `currentSnapshot`. |
| `features/checkout/guards/cart-not-empty.guard.spec.ts` | 2 | Same — `cartNotEmptyGuard(route, segments)` missing `currentSnapshot`. |
| `features/checkout/guards/checkout-step.guard.spec.ts` | 5 | Same — `checkoutStepGuard(step)(route, segments)` missing `currentSnapshot`. |
| `features/pizzerias/guards/no-pizzeria.guard.spec.ts` | 3 | Same — `noPizzeriaGuard(route, segments)` missing `currentSnapshot`. |

**Pattern:** Angular 22.0 introduced a breaking change to the functional guard signature. The production guards compile fine (they match the new signature), but the test invocations pass only 2 arguments — the old Angular 21 signature. All 18 errors are in 5 guard spec files; no other test files are affected.

**Hidden errors:** Once the 18 guard-signature errors are fixed, the original fixture-drift errors from the 2026-06-03 snapshot (`TS2739` mock-model mismatches + `TS2339` `canDeactivate`) will likely re-surface. The TypeScript compiler stops at the guard specs first, so these errors are currently invisible.

**Lint status (unchanged):** `pnpm run lint` produces 19 errors (19 errors, 0 warnings) across 8 files — 14 `@typescript-eslint/no-explicit-any`, 1 `no-unused-vars`, 6 `no-empty-function` (IntersectionObserver stubs). These are pre-existing upstream issues, not introduced by the sync.

> **Bottom line:** Right now you can't run the suite. The fix is mechanical: add a 3rd `{} as PartialMatchRouteSnapshot` argument to every guard invocation in the 5 affected spec files (~18 call sites).

---

## 3. Angular Skill/MCP Cross-Check

The following table compares each test category against Angular official recommendations
(sourced from `angular-developer` skill references and `search_documentation` MCP tool).

| Category | Project Pattern | Angular Recommendation | Alignment | Priority |
|----------|----------------|----------------------|-----------|----------|
| Services | `HttpTestingController` + `provideHttpClientTesting()` | `HttpTestingController` | ✓ Aligned | — |
| Interceptors | `provideHttpClient(withInterceptors([...]))` + real `HttpClient` | Same | ✓ Aligned | — |
| Pipes | `new Pipe()` no TestBed | `new Pipe()` no TestBed | ✓ Aligned | — |
| Directives | Host component with `signal()` stub | Host component | ✓ Aligned | — |
| Stores | `TestBed.flushEffects()` + `httpTesting.match()` | `httpResource` testing | ✓ Mostly aligned | Low |
| Forms | Real service + plain stubs | Signal forms + real service | ✓ Mostly aligned | Low |
| Components | `querySelector` + `NO_ERRORS_SCHEMA` | Component Harnesses | ⚠ Misaligned | Medium |
| Pages | `provideRouter([])` + `NO_ERRORS_SCHEMA` | `RouterTestingHarness` + real imports | ⚠ Misaligned | Medium |
| Guards | `runInInjectionContext()` with 2 args (outdated) | `RouterTestingHarness` with 3 args (Angular 22) | ✗ Blocked | High |
| Route Config | No tests | No tests | ✓ Aligned | — |

**Score: 7/10 categories aligned, 2 with actionable gaps, 1 blocked.**

### Detail on Misaligned Categories

**Components (⚠):** Angular recommends Component Harnesses (`TestbedHarnessEnvironment`) as the standard way to interact with components in tests. The project uses raw `querySelector` and sets inputs via `componentRef.setInput()`. Harnesses provide better refactoring resilience — template changes don't break tests. Mitigation: add harnesses to high-value shared components (Button, Input, Modal) consumed by many tests.

**Pages (⚠):** Angular recommends `RouterTestingHarness` with real child component imports for page tests. The project uses `provideRouter([])` and `NO_ERRORS_SCHEMA`, which verifies page structure but not child component integration. Mitigation: adopt `RouterTestingHarness` for critical page flows.

**Guards (✗):** Two issues: (1) the project uses `runInInjectionContext()` where `RouterTestingHarness` is recommended for integration-testing guards with their routes, and (2) the 2-argument calls are incompatible with Angular 22's 3-argument signature. This is the highest-priority fix.

---

## 4. Unit-Test Quality — Strengths

What the spec files *do* well (sampled across `cart.store.spec.ts`, `auth.spec.ts`, `auth.guard.spec.ts`, `modal.spec.ts`):

### 4.1 Patterns are consistent and idiomatic

- **HTTP services** uniformly use `HttpTestingController` + `provideHttpClientTesting()`, with `httpTesting.verify()` in `afterEach` to catch leaked requests. This is the right pattern and it's used everywhere.
- **Guards** are tested as functional units via `TestBed.runInInjectionContext()` with `vi.fn()`-stubbed dependencies. They assert both the truthy and `UrlTree` branches and even assert the *serialized* URL (e.g. `/auth/login`), which catches routing regressions.
- **Stores** use `TestBed.flushEffects()` to deterministically trigger signal effects, and `httpTesting.match()` with a predicate to handle the multi-request cases that arise from reactive cart sync.
- **Components** default to `NO_ERRORS_SCHEMA` for shallow rendering, with selective override of `imports` when a test needs the real child tree (e.g. `PizzaOrderFormDialog`).
- **Directives** use the classic host-component pattern with a stubbed `Auth` signal, so reactivity to `signal.set()` is exercised.
- **Pipes** are unit-tested without `TestBed` (just `new Pipe()`) — appropriately minimal.

### 4.2 Assertions test behavior, not implementation

- Service tests assert on **request method, URL, body, and resulting signal state** — not on private fields.
- Component tests assert on **DOM output and dispatched events** rather than internal property reads.
- Guard tests assert on **return values and serialized URLs**, not on which conditionals ran.

### 4.3 Mock data is named and centralized

`mockUser`, `mockAdmin`, `mockCartData`, etc. are defined at the top of each file. This is a small thing but it pays off in readability and reduces drift between tests.

### 4.4 Error paths are not forgotten

Examples worth calling out:
- `auth.spec.ts` flushes a 401 on `/api/auth/me` and asserts the user signal stays null.
- `cart.store.spec.ts` asserts `httpTesting.expectNone(...)` when the cart is empty — a non-trivial "no request" assertion.
- `credentials.interceptor.spec.ts` covers the negative case (Photon API requests should *not* receive `withCredentials`).

### 4.5 Reactive primitives are well exercised

The `cart.store.spec.ts` is the standout here — it tests the `httpResource` cart-sync effect under `addItem`, `updateQuantity`, `removeItem`, `clear`, and the cross-pizzeria reset case. That's the kind of behavior that's easy to leave uncovered, and it's covered.

### 4.6 Validated against official Angular docs

Cross-checked all 10 test categories against `angular-developer` skill references and MCP `search_documentation`. 7 of 10 categories are fully aligned with official recommendations. See Section 3 for the detailed breakdown.

---

## 5. Unit-Test Quality — Weaknesses

### Blocking (must fix to run tests)

**5.1 Angular version compatibility — 18 guard signature errors**
The 18 `TS2554` errors all stem from the Angular 21 → 22 upgrade. Angular 22.0 changed `CanActivateFn` and `CanMatchFn` to accept a 3rd `currentSnapshot: PartialMatchRouteSnapshot` argument. The production guards were updated to match, but the spec files still call guards with the old 2-argument signature.

**5.2 Hidden fixture-drift errors**
Once the guard errors are fixed, 5 additional TypeScript errors will re-surface: `TS2739` mock-model mismatches (mock objects missing `tipAmount`, `scheduledAt` fields) and `TS2339` `canDeactivate` reference in `checkout-page.spec.ts`. These are currently masked because the compiler stops at the guard specs first.

### Structural (design improvements)

**5.3 No component harnesses**
The project uses `querySelector` for DOM interaction across all 34 component specs. Angular recommends Component Harnesses as the standard approach. Harnesses insulate tests from internal template refactors — changing a CSS class or element structure in the component doesn't break tests using harnesses. The highest-value targets for harness adoption are Button, Input, and Modal (the most widely consumed shared components).

**5.4 No RouterTestingHarness**
Guard and page tests don't use `RouterTestingHarness`, which Angular recommends as the standard tool for testing routing behavior. The project's `runInInjectionContext()` approach tests guards in isolation but doesn't verify that guards actually protect routes in a real navigation flow.

**5.5 No code-coverage measurement**
There is no `vitest.config.ts`, no coverage script in `package.json`, no `coverage/` directory, no thresholds. For a reference project, this is a real gap — readers can't see the actual numbers.

**5.6 Heavy reliance on `NO_ERRORS_SCHEMA`**
For shared / leaf components, this is fine — they really do have stub children. But for **page components** (e.g. `login-page.spec.ts`, `cart-page.spec.ts`) it means the test is verifying the page's own template renders the right *structural shape* (form, inputs, submit) but not that the child components actually integrate correctly.

**5.7 Coverage gaps beyond unit tests**
`README-TESTING.md` already calls these out, but they bear repeating: no e2e, no integration tests against real API, no accessibility tests, no visual regression, no route-integration tests.

**5.8 The pipe test imports `environment` from the file path, not the symbol**
`catalog-image-url.pipe.spec.ts` imports `'../../../environments/environment'` and uses `environment.apiBaseUrl`. The test runs against the default `environment.ts` (not `.development.ts`). If those two diverge, the test will silently exercise the wrong base URL.

**5.9 The test count is the metric, not the coverage**
With 60 specs at ~86 lines each on average, this *looks* thorough. But without a coverage report, you can't tell whether the suite has 80% line coverage or 35%. The file count is a proxy, and a noisy one.

---

## 6. Improvement Roadmap

### Tier 1 — Unblock the test suite

1. **Fix the 18 guard-spec errors.** Add the 3rd `currentSnapshot` argument to every guard invocation across the 5 affected spec files. This is ~18 mechanical changes and unblocks the test suite.
2. **Fix the re-surfaced fixture-drift errors.** Once the guard errors are resolved, update the mock fixtures for `mockOrder` / `AdminOrderListItem` (add `tipAmount`, `scheduledAt`) and resolve the `canDeactivate` reference in `checkout-page.spec.ts`.

### Tier 2 — Align with Angular recommendations

3. **Add component harnesses to high-value shared components.** Start with Button, Input, and Modal — the components consumed by the most tests. Create harness files in `testing/` subdirectories. See `README-TEST-GUIDE.md` for the pattern.
4. **Add RouterTestingHarness examples for guard integration tests.** Demonstrate the full routing pipeline for at least one guard to establish the pattern. See `README-TEST-GUIDE.md` for the reference implementation.
5. **Add signal-forms testing patterns** for new form tests. Reference the `angular-developer` skill's `signal-forms.md`.

### Tier 3 — Measure and protect

6. **Add coverage.** Install `@vitest/coverage-v8`, add a `test:coverage` script, and generate a report. Even a single run committed to the repo as an artifact answers "how well is this tested?" with data instead of vibes.
7. **Add a CI guard.** A minimal GitHub Actions job (or equivalent) that runs `pnpm install && pnpm run test` on every PR would have caught both the Angular 22 signature change and the original fixture drift.
8. **Add 1–2 smoke e2e tests** with Playwright for the *browse → add-to-cart* flow. The project is integrated against a real API, so this is high-value and low-effort.
9. **Consider a shared test-fixture library** in `src/app/core/testing/` so model additions don't require touching every spec.
10. **Add a single accessibility assertion** (`axe.run()`) to one page spec to establish the pattern; expand from there.

---

## 7. One-line verdict

The unit-test *discipline* here is genuinely good — patterns, structure, and breadth are all in order — but the suite is currently **red from an Angular 22 guard-signature change (18 errors), has a hidden layer of fixture-drift errors underneath, has no coverage measurement, and is the only layer of testing**. The MCP/skill cross-check reveals 7/10 categories are aligned with Angular recommendations, with 2 categories (components, pages) having actionable gaps and 1 (guards) blocked. Fix the guard specs, then the fixtures, add coverage, and the story changes from "looks committed" to "actually trustworthy."

---

## Appendix: Data Sources

- `README.md` — project description, roles, route map
- `README-TESTING.md` — author's own testing documentation
- `README-TEST-GUIDE.md` — Angular recommended + project pattern guide
- `package.json` — scripts and dev dependencies (Angular 22.0.0, Vitest 4.1.6, TypeScript 6.0.3)
- `pnpm exec ng test --watch=false` — current run output (failed build, 18 TS2554 errors across 5 guard spec files)
- `pnpm exec ng lint` — current run output (19 errors, 0 warnings, across 8 files)
- `angular-developer` skill references: `testing-fundamentals.md`, `component-harnesses.md`, `router-testing.md`, `resource.md`, `signal-forms.md`
- MCP `search_documentation` — Angular 22 official testing documentation (testing fundamentals, @defer testing, data resolvers, router testing)
- `angular-developer` skill references: `signal-forms.md`
- `find src -name "*.spec.ts" | wc -l` → 60
- `find src -name "*.ts" -not -name "*.spec.ts" | wc -l` → 84
- `wc -l` of all spec files → 5,188 lines
- `wc -l` of all source files → 3,743 lines
