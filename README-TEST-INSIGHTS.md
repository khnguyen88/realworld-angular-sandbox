# Test Coverage & Unit Test Quality — Insights

> **Testing Docs Index:**
>
> - **README-TEST-GUIDE.md** — How to write tests (Angular recommended + project patterns)
> - **README-TEST-AGENT-GUIDE.md** — LLM-facing recipe book for any Angular + Vitest project
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — PrimeNG v20+ companion cookbook
> - **README-TEST-INSIGHTS.md** — This file: quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists (59 specs, categories, patterns; latest run 59/59 specs pass)
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

> **Status snapshot (2026-06-15):** Upstream realworld-angular was synced to GitHub HEAD `f1593bffe76e89c906afcaf7a9a2f1c45fdcebef`. The suite compiles and passes completely. The latest local run is fully green: **59/59 specs pass, 350/350 tests pass**. No remaining failures. This document evaluates the suite against two external standards: Angular official docs (via MCP `search_documentation`) and Angular skill references.

---

## TL;DR

| Question                                   | Answer                                                                                            |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| How many test files?                       | **59 `*.spec.ts`** co-located with source.                                                        |
| How much test code?                        | **~5,175 lines** of test code vs. **~3,820 lines** of source.                                     |
| Is the suite green?                        | **Yes** — `pnpm run test` exits 0: **59/59 specs pass, 350/350 tests pass**.                      |
| Angular Skill/MCP Cross-Check              | **7/10 categories aligned** with official recommendations. 3 categories have gaps.                |
| How does it perform on the unit-test axis? | **Strong** in pattern discipline and breadth, with known gaps in harnesses and route integration. |
| Is coverage measured?                      | **No** — no `vitest.config.ts`, no `@vitest/coverage-v8`, no thresholds.                          |
| Are there other test types?                | **None** — no e2e, integration, a11y, or visual regression tests.                                 |

---

## 1. Project Context (from `README.md`)

The project is a **learning / reference implementation** of a RealWorld Angular SPA (Angular 22, standalone components, signals, lazy routes, SSE). It targets a deployed API at `api.realworldangular.org` and is **explicitly a playground, not a real marketplace**.

That framing matters for the conclusions below: this is reference code whose purpose is partly to _demonstrate_ testing patterns, so the quality of the _patterns_ themselves matters as much as the percentage coverage.

---

## 2. Current Run Status — GREEN

`pnpm run test` (i.e. `ng test`) compiles, runs, and exits 0. Results from the latest local run:

| Metric     | Value                   |
| ---------- | ----------------------- |
| Spec files | **59**                  |
| Passed     | **59 specs, 350 tests** |
| Failed     | **0 specs, 0 tests**    |
| Duration   | ~19.1s                  |

The earlier Photon request isolation failure and broad `TestBed` cascade failures have been resolved upstream. The suite is fully green.

**Lint status:** `pnpm exec ng lint` reports **All files pass linting** (0 errors, 0 warnings).

---

## 3. Angular Skill/MCP Cross-Check

The following table compares each test category against Angular official recommendations
(sourced from `angular-developer` skill references and `search_documentation` MCP tool).

| Category     | Project Pattern                                                     | Angular Recommendation                | Alignment        | Priority |
| ------------ | ------------------------------------------------------------------- | ------------------------------------- | ---------------- | -------- |
| Services     | `HttpTestingController` + `provideHttpClientTesting()`              | `HttpTestingController`               | ✓ Aligned        | —        |
| Interceptors | `provideHttpClient(withInterceptors([...]))` + real `HttpClient`    | Same                                  | ✓ Aligned        | —        |
| Pipes        | `new Pipe()` no TestBed                                             | `new Pipe()` no TestBed               | ✓ Aligned        | —        |
| Directives   | Host component with `signal()` stub                                 | Host component                        | ✓ Aligned        | —        |
| Stores       | `TestBed.flushEffects()` + `httpTesting.match()`                    | `httpResource` testing                | ✓ Mostly aligned | Low      |
| Forms        | Real service + plain stubs                                          | Signal forms + real service           | ✓ Mostly aligned | Low      |
| Components   | `querySelector` + `NO_ERRORS_SCHEMA`                                | Component Harnesses                   | ⚠ Misaligned     | Medium   |
| Pages        | `provideRouter([])` + `NO_ERRORS_SCHEMA`                            | `RouterTestingHarness` + real imports | ⚠ Misaligned     | Medium   |
| Guards       | `runInInjectionContext()` + `vi.fn()` (3-arg signature now correct) | `RouterTestingHarness`                | ⚠ Misaligned     | Medium   |
| Route Config | No tests                                                            | No tests                              | ✓ Aligned        | —        |

**Score: 7/10 categories aligned, 3 with actionable gaps.**

### Detail on Misaligned Categories

**Components (⚠):** Angular recommends Component Harnesses (`TestbedHarnessEnvironment`) as the standard way to interact with components in tests. The project uses raw `querySelector` and sets inputs via `componentRef.setInput()`. Harnesses provide better refactoring resilience — template changes don't break tests. Mitigation: add harnesses to high-value shared components (Button, Input, Modal) consumed by many tests.

**Pages (⚠):** Angular recommends `RouterTestingHarness` with real child component imports for page tests. The project uses `provideRouter([])` and `NO_ERRORS_SCHEMA`, which verifies page structure but not child component integration. Mitigation: adopt `RouterTestingHarness` for critical page flows.

**Guards (⚠):** The project uses `runInInjectionContext()` where `RouterTestingHarness` is recommended for integration-testing guards with their routes. The Angular 22 3-argument signature issue has been resolved (upstream `8684732`). Remaining gap: testing guards through the routing pipeline rather than in isolation.

---

## 4. Unit-Test Quality — Strengths

What the spec files _do_ well (sampled across `cart.store.spec.ts`, `auth.spec.ts`, `auth.guard.spec.ts`, `modal.spec.ts`):

### 4.1 Patterns are consistent and idiomatic

- **HTTP services** uniformly use `HttpTestingController` + `provideHttpClientTesting()`, with `httpTesting.verify()` in `afterEach` to catch leaked requests. This is the right pattern and it's used everywhere.
- **Guards** are tested as functional units via `TestBed.runInInjectionContext()` with `vi.fn()`-stubbed dependencies. They assert both the truthy and `UrlTree` branches and even assert the _serialized_ URL (e.g. `/auth/login`), which catches routing regressions.
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
- `credentials.interceptor.spec.ts` covers the negative case (Photon API requests should _not_ receive `withCredentials`).

### 4.5 Reactive primitives are well exercised

The `cart.store.spec.ts` is the standout here — it tests the `httpResource` cart-sync effect under `addItem`, `updateQuantity`, `removeItem`, `clear`, and the cross-pizzeria reset case. That's the kind of behavior that's easy to leave uncovered, and it's covered.

### 4.6 Validated against official Angular docs

Cross-checked all 10 test categories against `angular-developer` skill references and MCP `search_documentation`. 7 of 10 categories are fully aligned with official recommendations. See Section 3 for the detailed breakdown.

---

## 5. Unit-Test Quality — Weaknesses

There are no blocking test failures. The items below are structural design improvements and measurement gaps.

**5.1 No component harnesses**
The project uses `querySelector` for DOM interaction across all 44 component/page specs. Angular recommends Component Harnesses as the standard approach. Harnesses insulate tests from internal template refactors — changing a CSS class or element structure in the component doesn't break tests using harnesses. The highest-value targets for harness adoption are Button, Input, and Modal (the most widely consumed shared components).

**5.2 No RouterTestingHarness**
Guard and page tests don't use `RouterTestingHarness`, which Angular recommends as the standard tool for testing routing behavior. The project's `runInInjectionContext()` approach tests guards in isolation but doesn't verify that guards actually protect routes in a real navigation flow.

**5.3 No code-coverage measurement**
There is no `vitest.config.ts`, no coverage script in `package.json`, no `coverage/` directory, no thresholds. For a reference project, this is a real gap — readers can't see the actual numbers.

**5.4 Heavy reliance on `NO_ERRORS_SCHEMA`**
For shared / leaf components, this is fine — they really do have stub children. But for **page components** (e.g. `login-page.spec.ts`, `cart-page.spec.ts`) it means the test is verifying the page's own template renders the right _structural shape_ (form, inputs, submit) but not that the child components actually integrate correctly.

**5.5 Coverage gaps beyond unit tests**
`README-TESTING.md` already calls these out, but they bear repeating: no e2e, no integration tests against real API, no accessibility tests, no visual regression, no route-integration tests.

**5.6 The pipe test imports `environment` from the file path, not the symbol**
`catalog-image-url.pipe.spec.ts` imports `'../../../environments/environment'` and uses `environment.apiBaseUrl`. The test runs against the default `environment.ts` (not `.development.ts`). If those two diverge, the test will silently exercise the wrong base URL.

**5.7 The test count is the metric, not the coverage**
With 59 specs averaging ~88 lines each, this _looks_ thorough. But without a coverage report, you can't tell whether the suite has 80% line coverage or 35%. The file count is a proxy, and a noisy one.

---

## 6. Improvement Roadmap

### Tier 1 — Maintain green suite

1. **Keep `pnpm run test` passing on every upstream sync.** Verify the suite before committing documentation updates or pulling upstream changes.

### Tier 2 — Align with Angular recommendations

3. **Add component harnesses to high-value shared components.** Start with Button, Input, and Modal — the components consumed by the most tests. Create harness files in `testing/` subdirectories. See `README-TEST-GUIDE.md` for the pattern.
4. **Add RouterTestingHarness examples for guard integration tests.** Demonstrate the full routing pipeline for at least one guard to establish the pattern. See `README-TEST-GUIDE.md` for the reference implementation.
5. **Add signal-forms testing patterns** for new form tests. Reference the `angular-developer` skill's `signal-forms.md`.

### Tier 3 — Measure and protect

6. **Add coverage.** Install `@vitest/coverage-v8`, add a `test:coverage` script, and generate a report. Even a single run committed to the repo as an artifact answers "how well is this tested?" with data instead of vibes.
7. **Add a CI guard.** A minimal GitHub Actions job (or equivalent) that runs `pnpm install && pnpm run test` on every PR would have caught both the Angular 22 signature change and the original fixture drift.
8. **Add 1–2 smoke e2e tests** with Playwright for the _browse → add-to-cart_ flow. The project is integrated against a real API, so this is high-value and low-effort.
9. **Consider a shared test-fixture library** in `src/app/core/testing/` so model additions don't require touching every spec.
10. **Add a single accessibility assertion** (`axe.run()`) to one page spec to establish the pattern; expand from there.

---

## 7. One-line verdict

The unit-test _discipline_ here is genuinely good — patterns, structure, and breadth are all in order — and the latest local suite is **fully green (59/59 specs pass, 350/350 tests pass)**. The MCP/skill cross-check reveals 7/10 categories are aligned with Angular recommendations, with 3 categories (components, pages, guards) having actionable gaps. The remaining work is no longer about fixing failures; it is about adding coverage measurement, component harnesses, route-integration tests, and broader test types so the story changes from "committed and green" to "actually trustworthy."

---

## Appendix: Data Sources

- `README.md` — project description, roles, route map
- `README-TESTING.md` — author's own testing documentation
- `README-TEST-GUIDE.md` — Angular recommended + project pattern guide
- `package.json` — scripts and dev dependencies (Angular 22.0.0, Vitest 4.1.6, TypeScript 6.0.3)
- `pnpm run test` — latest local upstream HEAD `f1593bffe76e89c906afcaf7a9a2f1c45fdcebef` run output (59/59 specs pass, 350/350 tests pass; exit code 0)
- `pnpm exec ng lint` — current run output (0 errors, 0 warnings; all files pass linting)
- `angular-developer` skill references: `testing-fundamentals.md`, `component-harnesses.md`, `router-testing.md`, `resource.md`, `signal-forms.md`
- MCP `search_documentation` — Angular 22 official testing documentation (testing fundamentals, @defer testing, data resolvers, router testing)
- `find src -name "*.spec.ts" | wc -l` → 59
- `find src -name "*.ts" -not -name "*.spec.ts" | wc -l` → 83
- `wc -l` of all spec files → ~5,175 lines
- `wc -l` of all source files → ~3,820 lines
