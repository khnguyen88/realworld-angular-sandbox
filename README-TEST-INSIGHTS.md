# Test Coverage & Unit Test Quality — Insights

> **Status snapshot (2026-06-07):** The test suite is comprehensive in scope and well-structured, but it is **not currently green**. 18 TypeScript compile errors prevent `pnpm run test` from producing any results. All stem from Angular 22.0's `CanActivateFn` / `CanMatchFn` signature change. Details below.

---

## TL;DR

| Question | Answer |
| --- | --- |
| How many test files? | **60 `*.spec.ts`** co-located with source. |
| How much test code? | **~5,188 lines** of test code vs. **~3,743 lines** of source. |
| Is the suite green? | **No** — `pnpm run test` fails at the TypeScript build step with **18 errors across 5 guard spec files**. |
| How does it perform on the unit-test axis? | **Strong** in pattern discipline and breadth, but **failing** in Angular version compatibility. |
| Is coverage measured? | **No** — no `vitest.config.ts`, no `@vitest/coverage-v8`, no thresholds in `package.json`. |
| Are there other test types? | **None** — no e2e, no integration, no a11y, no visual regression. |

---

## 1. Project Context (from `README.md`)

The project is a **learning / reference implementation** of a RealWorld Angular SPA (Angular 22, standalone components, signals, lazy routes, SSE). It targets a deployed API at `api.realworldangular.org` and is **explicitly a playground, not a real marketplace**.

That framing matters for the conclusions below: this is reference code whose purpose is partly to *demonstrate* testing patterns, so the quality of the *patterns* themselves matters as much as the percentage coverage.

---

## 2. Test Inventory

### File-type breakdown

| Metric | Count |
| --- | --- |
| `*.spec.ts` files | **60** |
| Implementation `.ts` files (non-spec, non-routes, non-models, non-bootstrap) | **~57** |
| Files with specs | **~57 of 60** actionable units |
| Files with **no** spec | **3** — all trivially exempt: `environment.ts`, `environment.development.ts`, `modal-footer.ts` |
| Spec-to-source line ratio | **~1.39 : 1** (more test code than production code) |

**Implementation coverage at the file level is essentially 1:1.** Every component, service, guard, directive, pipe, interceptor, and store has a co-located spec. The only exceptions are pure config / leaf-template files.

### Categorical breakdown (matches `README-TESTING.md`)

| Category | Specs |
| --- | --- |
| Services & API clients | 6 |
| Stores (signal-based) | 1 (`cart.store`) |
| HTTP interceptors | 2 |
| Route guards (functional) | 5 |
| Shared components | 16 |
| Feature pages | 17 |
| Feature components / dialogs | 9 |
| Layout components (header, footer) | 2 |
| Structural directives | 1 (`*rwRole`) |
| Pure pipes | 1 |

**Notable:** The single `auth.guard.spec.ts` covers **two** guards (`authGuard` + `guestGuard`), the only multi-guard file in the suite.

---

## 3. Current Run Status — RED

`pnpm run test` (i.e. `ng test --watch=false`) currently **fails to compile**. 18 TypeScript errors, all `TS2554` ("Expected 3 arguments, but got 2"):

| File | Errors | Root cause |
| --- | --- | --- |
| `core/guards/auth/auth.guard.spec.ts` | 4 | Angular 22.0 changed `CanActivateFn` / `CanMatchFn` to require a 3rd argument (`currentSnapshot: PartialMatchRouteSnapshot`). Guard specs call guards with only 2 args (`route`, `segments`). |
| `core/guards/role/role.guard.spec.ts` | 4 | Same — `roleGuard([...])(route, segments)` missing `currentSnapshot`. |
| `features/checkout/guards/cart-not-empty.guard.spec.ts` | 2 | Same — `cartNotEmptyGuard(route, segments)` missing `currentSnapshot`. |
| `features/checkout/guards/checkout-step.guard.spec.ts` | 5 | Same — `checkoutStepGuard(step)(route, segments)` missing `currentSnapshot`. |
| `features/pizzerias/guards/no-pizzeria.guard.spec.ts` | 3 | Same — `noPizzeriaGuard(route, segments)` missing `currentSnapshot`. |

**Pattern:** Angular 22.0 introduced a breaking change to the functional guard signature. The production guards compile fine (they match the new signature), but the test invocations pass only 2 arguments — the old Angular 21 signature. All 18 errors are in 5 guard spec files; no other test files are affected.

**Lint status (unchanged):** `pnpm run lint` produces 19 errors (19 errors, 0 warnings) across 8 files — 14 `@typescript-eslint/no-explicit-any`, 1 `no-unused-vars`, 6 `no-empty-function` (IntersectionObserver stubs). These are pre-existing upstream issues, not introduced by the sync.

> **Bottom line:** Right now you can't run the suite. The fix is mechanical: add a 3rd `{} as PartialMatchRouteSnapshot` argument to every guard invocation in the 5 affected spec files (~18 call sites). This is the single highest-priority fix — everything else in this document is a commentary on what would be true *if* the suite were green.

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

---

## 5. Unit-Test Quality — Weaknesses

### 5.1 Angular version compatibility (the red build, again)

The 18 compilation errors all stem from the Angular 21 → 22 upgrade. Angular 22.0 changed `CanActivateFn` and `CanMatchFn` to accept a 3rd `currentSnapshot: PartialMatchRouteSnapshot` argument. The production guards were updated to match, but the spec files still call guards with the old 2-argument signature.

This is a different kind of maintenance drift than the fixture-drift errors documented in the 2026-06-03 snapshot (which were `TS2739` mock-model mismatches). Those fixture-drift errors are still in the codebase but are **eclipsed** by the guard signature errors — the TypeScript compiler stops at the guard specs first, so the fixture errors don't surface until the guard errors are fixed.

Mitigations worth considering:

- A CI job that runs `pnpm run test` on every PR would have caught this immediately after the Angular upgrade.
- The guard tests could define a shared `mockRouteSnapshot` helper to reduce repetition when adding the 3rd argument.
- An `.nvmrc` or `engines` field in `package.json` would pin the Node version and prevent accidental environment drift.

### 5.2 No code-coverage measurement

There is no `vitest.config.ts`, no coverage script in `package.json`, no `coverage/` directory, no thresholds. We can talk about *test breadth* (file count) but not *test depth* (line / branch coverage). For a reference project, this is a real gap — readers can't see the actual numbers.

### 5.3 Heavy reliance on `NO_ERRORS_SCHEMA`

For shared / leaf components, this is fine — they really do have stub children. But for **page components** (e.g. `login-page.spec.ts`, `cart-page.spec.ts`) it means the test is verifying the page's own template renders the right *structural shape* (form, inputs, submit) but not that the child components actually integrate correctly. It's a deliberate trade-off (test the unit, not the tree) but worth knowing.

### 5.4 `Event('input')` and `Event('submit')` are dispatched manually

The page tests in `README-TESTING.md` set `input.value = ...` and dispatch `new Event('input')` to trigger Angular form bindings. This works but bypasses the actual value-binding pipeline. A small wrapper (or just using `DebugElement.triggerEventHandler`) would be more faithful. Minor.

### 5.5 Coverage gaps beyond unit tests

`README-TESTING.md` already calls these out, but they bear repeating in the context of "how well does it do with unit tests?":

- **No e2e** — no Playwright, Cypress, or WebdriverIO. The critical user journey "browse → add to cart → checkout → place order" has no end-to-end verification.
- **No integration tests** against the real API. Contract drift between frontend and `api.realworldangular.org` will only surface in production.
- **No accessibility tests** — no `axe-core`, no `pa11y`. Given this is a public-facing UI, a single `axe.run()` call in a page test would be cheap insurance.
- **No visual regression** — styling changes can land silently.
- **No route-integration tests** — guards are tested in isolation, but no test verifies that navigating to `/admin/pizzerias` actually wires up the guard + lazy chunk + page.

### 5.6 The pipe test imports `environment` from the file path, not the symbol

`catalog-image-url.pipe.spec.ts` imports `'../../../environments/environment'` and uses `environment.apiBaseUrl`. The test runs against the default `environment.ts` (not `.development.ts`). If those two diverge, the test will silently exercise the wrong base URL. Worth a `// intentionally using default` comment, or pinning to a test environment.

### 5.7 The test count is the metric, not the coverage

With 60 specs at ~86 lines each on average, this *looks* thorough. But without a coverage report, you can't tell whether the suite has 80% line coverage or 35%. The file count is a proxy, and a noisy one.

---

## 6. My Thoughts

### What I think of the test suite overall

**The good:** the patterns are textbook. If you sent `auth.spec.ts` or `cart.store.spec.ts` to a senior Angular dev, they would approve. The HTTP-mocking, the guard-via-`runInInjectionContext`, the signal-effect flushing, the `httpTesting.match()` predicate work — all of it is the right call. The 1:1 spec-to-source ratio is a real achievement, and a project this size is *unusual* in that respect. The test code is **larger** than the production code, which signals real commitment.

**The bad:** the suite is **red right now** due to an Angular version upgrade. The 18 `TS2554` errors are mechanical — every guard invocation needs a 3rd argument. None indicate broken behavior in production, only that the specs weren't updated when Angular 22 landed. But the practical effect is the same: the test suite is not protecting anyone today.

**The hidden:** once the 18 guard-signature errors are fixed, the original 5 fixture-drift errors from the 2026-06-03 snapshot (`TS2739` mock-model mismatches + `TS2339` `canDeactivate`) will likely re-surface. The TypeScript compiler stops at the guard specs first, so these errors are currently invisible. Fixing the guard specs will reveal the next layer of issues.

**The missing:** coverage measurement. For a reference project whose stated purpose includes being a learning resource, the absence of a coverage report is a real gap. The README says "60 spec files"; a coverage report would say "78% lines / 64% branches across 84 source files." Those are very different signals to a reader.

### Specific recommendations (in priority order)

1. **Fix the 18 guard-spec errors.** Add the 3rd `currentSnapshot` argument to every guard invocation across the 5 affected spec files. This is ~18 mechanical changes and unblocks the test suite.
2. **Fix the re-surfaced fixture-drift errors.** Once the guard errors are resolved, update the mock fixtures for `mockOrder` / `AdminOrderListItem` (add `tipAmount`, `scheduledAt`) and resolve the `canDeactivate` reference in `checkout-page.spec.ts`.
3. **Add coverage.** Install `@vitest/coverage-v8`, add a `test:coverage` script, and generate a report. Even a single run committed to the repo as an artifact answers "how well is this tested?" with data instead of vibes.
4. **Add a CI guard.** A minimal GitHub Actions job (or equivalent) that runs `pnpm install && pnpm run test` on every PR would have caught both the Angular 22 signature change and the original fixture drift. The fact that the suite is red on `main` implies this guard doesn't exist.
5. **Add 1–2 smoke e2e tests** with Playwright for the *browse → add-to-cart* flow. The project is integrated against a real API, so this is high-value and low-effort.
6. **Consider a shared `mockOrder()` / `mockPizzeria()` factory** in `src/app/core/testing/` so model additions don't require touching every spec.
7. **Add a single accessibility assertion** (`axe.run()`) to one page spec to establish the pattern; expand from there.

### One-line verdict

The unit-test *discipline* here is genuinely good — patterns, structure, and breadth are all in order — but the suite is currently **red from an Angular 22 guard-signature change (18 errors), has a hidden layer of fixture-drift errors underneath, has no coverage measurement, and is the only layer of testing**. Fix the guard specs, then the fixtures, add coverage, and the story changes from "looks committed" to "actually trustworthy."

---

## Appendix: Data Sources

- `README.md` — project description, roles, route map
- `README-TESTING.md` — author's own testing documentation
- `package.json` — scripts and dev dependencies (Angular 22.0.0, Vitest 4.1.6, TypeScript 6.0.3)
- `pnpm exec ng test --watch=false` — current run output (failed build, 18 TS2554 errors across 5 guard spec files)
- `pnpm exec ng lint` — current run output (19 errors, 0 warnings, across 8 files)
- `find src -name "*.spec.ts" | wc -l` → 60
- `find src -name "*.ts" -not -name "*.spec.ts" | wc -l` → 84
- `wc -l` of all spec files → 5,188 lines
- `wc -l` of all source files → 3,743 lines
