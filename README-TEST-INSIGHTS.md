# Test Coverage & Unit Test Quality — Insights

> **Status snapshot (2026-06-03):** The test suite is comprehensive in scope and well-structured, but it is **not currently green**. Five TypeScript compile errors prevent `pnpm run test` from producing any results. Details below.

---

## TL;DR

| Question | Answer |
| --- | --- |
| How many test files? | **60 `*.spec.ts`** co-located with source. |
| How much test code? | **~5,188 lines** of test code vs. **~3,743 lines** of source. |
| Is the suite green? | **No** — `pnpm run test` fails at the TypeScript build step with **5 errors across 5 spec files**. |
| How does it perform on the unit-test axis? | **Strong** in pattern discipline and breadth, but **failing** in maintenance hygiene. |
| Is coverage measured? | **No** — no `vitest.config.ts`, no `@vitest/coverage-v8`, no thresholds in `package.json`. |
| Are there other test types? | **None** — no e2e, no integration, no a11y, no visual regression. |

---

## 1. Project Context (from `README.md`)

The project is a **learning / reference implementation** of a RealWorld Angular SPA (Angular 21, standalone components, signals, lazy routes, SSE). It targets a deployed API at `api.realworldangular.org` and is **explicitly a playground, not a real marketplace**.

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

`pnpm run test` (i.e. `ng test --watch=false`) currently **fails to compile**. Five TypeScript errors:

| # | File | Error | Root cause |
| --- | --- | --- | --- |
| 1 | `features/orders/order-api.spec.ts:7` | `TS2739` — `mockOrder` missing `tipAmount`, `scheduledAt` | Production `Order` model added fields; mock wasn't updated. |
| 2 | `features/orders/pages/order-list-page/order-list-page.spec.ts:12` | `TS2739` — same as above | Same model drift. |
| 3 | `features/orders/pages/order-details-page/order-details-page.spec.ts:9` | `TS2739` — same as above | Same model drift. |
| 4 | `features/orders/pages/admin-order-list-page/admin-order-list-page.spec.ts:14` | `TS2739` — `AdminOrderListItem` missing `tipAmount`, `scheduledAt` | Same model drift. |
| 5 | `features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.spec.ts:10` | `TS2739` — same as above | Same model drift. |
| 6 | `features/checkout/pages/checkout-page/checkout-page.spec.ts:67` | `TS2339` — `canDeactivate` does not exist on `CheckoutPage` | Test references a method that was either renamed or never existed. |

**Pattern:** The "orders" feature added `tipAmount` / `scheduledAt` to its domain models and the test fixtures were never updated. The `canDeactivate` case is more concerning — it suggests a refactor (or a planned guard) was abandoned mid-flight and the test wasn't cleaned up.

> **Bottom line:** Right now you can't run the suite. Anyone reviewing "is this project tested?" via `pnpm test` will see a red build. This is the single highest-priority fix — everything else in this document is a commentary on what would be true *if* the suite were green.

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

### 5.1 Maintenance drift (the red build, again)

The 5 compilation errors are all the same kind of failure: **fixtures weren't updated when models evolved**. Mitigations worth considering:

- A shared `mockOrderFactory()` helper so a new field is added in one place.
- A lint rule that warns when a `mockX: X` annotation is missing a required field (Angular's `strict` TS config + `exactOptionalPropertyTypes`).
- A CI job that runs `pnpm run test` on every PR — which apparently isn't happening (see §6).

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

**The bad:** the suite is **red right now**. That's the first thing anyone running `pnpm test` will see, and it overshadows everything else. The cause is purely fixture drift — none of the errors indicate broken behavior in production, only stale mocks. But the practical effect is the same: the test suite is not protecting anyone today.

**The missing:** coverage measurement. For a reference project whose stated purpose includes being a learning resource, the absence of `vitest run --coverage` (or equivalent) is a real gap. The README says "60 spec files"; a coverage report would say "78% lines / 64% branches across 84 source files." Those are very different signals to a reader.

### Specific recommendations (in priority order)

1. **Fix the red build first.** Update the 5 mock fixtures to include `tipAmount` / `scheduledAt`; resolve the `canDeactivate` reference in `checkout-page.spec.ts` (either implement the method or remove the test). This is ~10 lines of changes and unblocks everything else.
2. **Add coverage.** Install `@vitest/coverage-v8`, add a `test:coverage` script, and generate a report. Even a single run committed to the repo as an artifact answers "how well is this tested?" with data instead of vibes.
3. **Add a CI guard.** A minimal GitHub Actions job (or equivalent) that runs `pnpm install && pnpm run test` on every PR would have caught the current red build. The fact that the suite is red on `main` implies this guard doesn't exist.
4. **Add 1–2 smoke e2e tests** with Playwright for the *browse → add-to-cart* flow. The project is integrated against a real API, so this is high-value and low-effort.
5. **Consider a shared `mockOrder()` / `mockPizzeria()` factory** in `src/app/core/testing/` so model additions don't require touching every spec.
6. **Add a single accessibility assertion** (`axe.run()`) to one page spec to establish the pattern; expand from there.

### One-line verdict

The unit-test *discipline* here is genuinely good — patterns, structure, and breadth are all in order — but the suite is currently **red from fixture drift, has no coverage measurement, and is the only layer of testing**. Fix the build, add coverage, and the story changes from "looks committed" to "actually trustworthy."

---

## Appendix: Data Sources

- `README.md` — project description, roles, route map
- `README-TESTING.md` — author's own testing documentation
- `package.json` — scripts and dev dependencies
- `pnpm exec ng test --watch=false` — current run output (failed build, 5 TS errors)
- `find src -name "*.spec.ts" | wc -l` → 60
- `find src -name "*.ts" -not -name "*.spec.ts" | wc -l` → 84
- `wc -l` of all spec files → 5,188 lines
- `wc -l` of all source files → 3,743 lines
