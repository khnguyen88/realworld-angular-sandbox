# System Design & Architecture

> **Analysis date:** 2026-06-07
> **Source:** [realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular)
> **Pinned upstream SHA:** `3322c2d498f82bb00fd0e56fd048a23288c95ce1`
> **Total commits analyzed:** 91 (May 14 – Jun 5, 2026)

High-level overview of the system design, architecture, and the implementation order derived from the upstream commit history. The goal is to understand how the developer approached building this application — what was built first, what was deferred, and what architectural decisions shaped the codebase.

---

## 1. Architecture Overview

The application follows Angular's recommended **standalone component architecture** with three top-level directories:

```
src/app/
├── core/          # Singleton services, guards, interceptors, layout components, shared models
├── features/      # Lazy-loaded feature modules (auth, cart, checkout, orders, pizzerias, etc.)
├── shared/        # Reusable UI components, directives, pipes
```

### 1.1 Technology Stack

| Layer            | Choice                                                | Version       |
| ---------------- | ----------------------------------------------------- | ------------- |
| Framework        | Angular (standalone, signals, OnPush)                 | 22.0.0        |
| Language         | TypeScript                                            | 6.0.3         |
| State management | Angular signals + `httpResource` / `rxResource`       | —             |
| Forms            | Angular signal-based forms (`@angular/forms/signals`) | —             |
| HTTP             | `provideHttpClient(withFetch())`                      | —             |
| Routing          | Lazy-loaded feature routes with `CanMatchFn` guards   | —             |
| UI               | Custom component library (no Angular Material)        | —             |
| CSS              | Plain CSS, per-component stylesheets                  | —             |
| Testing          | Vitest + jsdom via `@angular/build:unit-test`         | Vitest 4.1.6  |
| Linting          | ESLint with `angular-eslint` + `typescript-eslint`    | ESLint 10.4.0 |
| Package manager  | pnpm                                                  | 11.3.0        |
| Git hooks        | Husky                                                 | 9.1.7         |

### 1.2 Routing Topology

All routes use **lazy loading** via `loadChildren` pointing to per-feature `*.routes.ts` files. Pages within features use `loadComponent` for further code splitting.

```
/                               → redirect (admin → /pizzerias/admin, customer → /pizzerias)
├── /pizzerias                  → Pizzeria feature (public list + admin sub-tree)
│   ├── /admin/new              → Create pizzeria (roleGuard: PIZZERIA_ADMIN + noPizzeriaGuard)
│   ├── /admin                  → Admin shell (pizzas, configuration child routes)
│   └── /:id                    → Public detail
├── /auth                       → Auth feature (guestGuard)
│   ├── /login
│   ├── /register
│   └── /register-pizzeria      → Reuses RegisterPage with route data flag
├── /cart                       → Cart feature (always accessible)
├── /checkout                   → Checkout wizard (authGuard + cartNotEmptyGuard)
├── /orders                     → Orders feature (authGuard)
│   ├── /admin                  → Admin order list (roleGuard: PIZZERIA_ADMIN)
│   └── /:id                    → Order detail
├── /profile                    → Profile (authGuard)
├── /unauthorized               → Static access-denied page
├── /terms-and-conditions       → Static legal page
└── **                          → 404 catch-all
```

Key routing decisions:

- **`canMatch` over `canActivate`** — guards prevent the lazy chunk from loading at all, not just the navigation. This is more efficient for unauthorized users.
- **`withComponentInputBinding()`** — route params and query params are bound as component `@Input()` signals, avoiding imperative `ActivatedRoute` subscription.
- **Functional guards** — all guards are `CanMatchFn` functions (not class-based `@Injectable()` guards), tested via `TestBed.runInInjectionContext()`.

### 1.3 State Management

No external state library (no NgRx, Akita, Elf, etc.). The app uses three tiers of Angular primitives:

| Tier          | Mechanism                                 | Example                                        |
| ------------- | ----------------------------------------- | ---------------------------------------------- |
| Global state  | `providedIn: 'root'` service with signals | `Auth.user` signal, `CartStore`                |
| Scoped state  | Route-level provider                      | `CheckoutWizard` (scoped to checkout subtree)  |
| Derived state | `computed()` signals                      | `Auth.isAuthenticated`, `CartStore.totalPrice` |
| Reactive HTTP | `httpResource` / `rxResource`             | Cart auto-sync, coupon validation              |

### 1.4 Component Design

Every component uses `ChangeDetectionStrategy.OnPush`. There are 16 shared components forming a custom design system — no third-party UI library. Shared components that integrate with signal-based forms implement the `FormValueControl<T>` interface from `@angular/forms/signals`.

### 1.5 Security Model

Two-tier role system (`CUSTOMER` | `PIZZERIA_ADMIN`) enforced at two levels:

1. **Route level** — `roleGuard()` returns a `CanMatchFn` that redirects to `/auth/login` (no user), `/unauthorized` (wrong role), or allows.
2. **Template level** — `RoleDirective` (`*rwRole`) conditionally renders DOM based on role, with an `else` template for fallback content. Supports a `'GUEST'` sentinel for unauthenticated-only content.

HTTP credentials (`withCredentials: true`) are added globally by `credentialsInterceptor` for all API requests except the third-party Photon geocoding service.

---

## 2. Implementation Timeline (Strategic Phases)

91 commits over 22 days (May 14 – Jun 5, 2026) by a single developer (geromegrignon), with one co-author (cursoragent) on a later commit.

### Phase 1: Foundation — Features First (May 14–15, 2026)

**15 commits.** The developer started from `ng new` and immediately built outward from the data model.

**Order of construction:**

1. **`init`** — Angular CLI scaffold (`a1eb73e`)
2. **Pizzeria management** — API endpoints standardized, `noPizzeriaGuard` added, admin pizzeria form page with routing and styling. This was the first real feature built — the data-owner registration flow.
3. **Checkout flow** — enhanced and cleaned up in a single large commit
4. **Auth polish** — removed post-registration redirect, cleaned up imports, styled password visibility toggle
5. **Cart management** — refactored cart reconstruction logic
6. **Configuration** — Angular security settings (CSP experimentation, later removed), README updates

**Pattern:** The developer built the core business flows (pizzeria admin → checkout → cart → auth) in their entirety before refining any individual piece. Guards, routes, pages, and services were built together per feature, not layer-by-layer.

### Phase 2: Core Architecture Refinement (May 17–18, 2026)

**~36 commits (May 17–18).** This is the largest phase by commit count. The developer went back through the entire codebase refactoring and consolidating.

**Key architectural work:**

1. **Base URL interceptor** — centralized API URL construction. Eliminated proxy configuration. This was a significant architectural decision made _after_ features were built.
2. **Shared component consolidation** — `Badge` merged into `StatusBadge`, `Callout` restructured, `EmptyState` streamlined, `ImagePicker` improved, form components refactored for accessibility.
3. **`PhotonLocationField`** — refactored for functionality and accessibility (keyboard navigation, ARIA)
4. **Subscription management** — `DestroyRef` + `takeUntilDestroyed` integrated across pizzeria and checkout pages. This was a systematic pass to prevent memory leaks.
5. **`httpResource` adoption** — `CartStore` migrated to `httpResource` for reactive cart sync. `AdminPizzaFormDialog` refactored to use `httpResource` for toppings.
6. **Navigation handling** — routing titles, page title management, navigation refactoring in auth and checkout pages.
7. **`canMatch` migration** — profile route updated to use `canMatch` (from `canActivate`).
8. **Component extraction** — `AdminPizzaRow` component extracted for pizza management.
9. **Obsolete spec deletion** — `cdbf77a` removes spec files that had become outdated during the rapid feature buildout. This is evidence that auto-generated tests were discarded rather than maintained during Phase 1.

**Pattern:** The developer built fast in Phase 1, then did a disciplined architecture pass. The sequence "features first, then interceptors, then shared component cleanup, then resource layer upgrade" shows a willingness to defer infrastructure until the shape of the features was clear.

### Phase 3: Testing & Documentation (May 19, 2026)

**18 commits.** A focused day of adding tests, documentation, and tooling.

1. **First test batch** — `70dae9c` "Add unit tests for core components and services." Tests were added as a dedicated phase after all features were complete.
2. **README polish** — five README commits clarifying purpose, features, contribution guidelines, API docs, and project name.
3. **Environment config** — development environment configuration cleaned up.
4. **CI & tooling** — husky installed, pnpm workspace config, test CI workflow simplified, linting pass, prettier applied.

**Pattern:** Documentation and testing were a single concentrated effort after the code was stable. The developer treated these as a "ship preparation" phase.

### Phase 4: Test Refactoring (May 20–22, 2026)

**7 commits.** A dedicated test quality pass.

1. `293373a` — Updated tests and enhanced pizzeria details page
2. `ba04b9d` — Refactored unit tests for guards and components
3. `26e0388` — Updated component tests for change detection and type safety
4. `6cdda60` — Enhanced test structure and formatting across components
5. `0d66ee7` — Replaced mock components with actual implementations in tests
6. `ca63022` — Removed standalone flag from mock components
7. `70725e2` — Cleaned up imports in pizza order form dialog tests

**Pattern:** The test refactoring moved tests from shallow (mock components via `NO_ERRORS_SCHEMA`) toward deeper integration (real child components imported). This is a maturation step — the tests existed, but the developer raised their quality bar.

### Phase 5: Feature Enhancements (May 22 – Jun 5, 2026)

**15 commits.** New capabilities added to existing features.

1. **Pizzeria details** — pagination and loading states (`bd72c32`)
2. **Checkout** — new components and guards (`b7f434b`)
3. **Registration** — email availability validation (`77c09fc`)
4. **Coupon codes** — three commits adding coupon functionality to checkout review step (`7d23826`, `ecd87f8`, `d5a7229`, `3322c2d`)
5. **Footer** — placeholder with deferred loading (`8fa08a5`)
6. **Error handling** — improved login/registration form errors (`059e7fc`)
7. **Angular upgrade** — dependencies updated to Angular 22 + TypeScript 6.0.3 (`f3f1700`). This broke 18 guard spec signatures (not fixed — out of scope for the sync).
8. **Minor fixes** — switch statement refactoring, accessibility fixes, icon additions

**Pattern:** After the testing/documentation phase, the developer returned to feature work. The enhancements were incremental — no new features from scratch, all additions to existing flows.

---

## 3. Implementation Order Analysis

### What was built first?

```
Priority order (from commit history):

1. Pizzeria admin (data-owner registration, pizzeria CRUD)
2. Checkout flow (multi-step wizard)
3. Cart management
4. Authentication (login, register, password toggle)
5. Infrastructure (interceptors, environment config)
6. Shared component refinement
7. Tests
8. CI / Tooling
9. Documentation
10. Feature enhancements (coupon, pagination, email validation)
```

### What does this reveal about the developer's approach?

**Business flow over infrastructure.** The developer built the pizzeria admin → checkout → cart → auth flows first, wiring them directly to the API. The `baseUrlInterceptor` — which centralized API URL construction — came _after_ the features. This is a "discover the pattern, then extract" approach rather than "design the abstraction upfront."

**Vertical slices, not horizontal layers.** Each feature was built with its routes, pages, services, and models together. The developer didn't build all services first, then all pages, then all routes. They built pizzeria end-to-end, then checkout end-to-end, then cart end-to-end.

**Refactoring is a distinct phase.** Phase 2 (29 commits) is purely refactoring — no new features. The developer allocated dedicated time to go back and consolidate. This is disciplined: build working code fast, then clean it up in a focused pass.

**Tests are a separate concern.** Tests were not interleaved with feature development. The first test commit appears 5 days after `init` and after all features are built. Tests then received their own dedicated refactoring phase. This is "test-after" development, not TDD.

**Documentation last.** README, contribution guidelines, and project description were written after the code was complete and tested. The developer treated docs as a "ship" activity, not a design activity.

**Shared components emerge from duplication.** The 16 shared components weren't all designed upfront. Many were extracted during Phase 2 refactoring (Badge → StatusBadge consolidation, Callout restructuring, EmptyState streamlining). The developer built features with inline solutions, then extracted the reusable parts.

**Architectural decisions are deferred.** Key infrastructure decisions happened in Phase 2, not Phase 1:

- Base URL interceptor: Phase 2
- `httpResource` adoption: Phase 2
- `canMatch` migration: Phase 2
- `DestroyRef` / `takeUntilDestroyed`: Phase 2

The developer was comfortable building with "good enough" patterns first and upgrading to best practices later.

---

## 4. TDD Assessment

**Was this test-driven development? No.**

**Evidence:**

1. **The first test commit (`70dae9c`) appears on May 19** — 5 days after `init` (May 14) and after all major features (pizzerias, checkout, cart, auth) were already built. In TDD, test commits would be interleaved with (or precede) feature commits from day one.

2. **Obsolete specs were deleted during Phase 2** (`cdbf77a`, May 18). This commit removed spec files that had become outdated during the rapid feature buildout. In TDD, specs drive the implementation and would be updated continuously, not deleted in bulk.

3. **Tests were a dedicated phase, not a development practice.** Phases 3–4 (May 19–22) are a concentrated "add tests, then refactor tests" effort. This is "test-after" — write the code, verify it works manually, then add tests for regression protection.

4. **The Angular 22 upgrade broke 18 guard specs** (Jun 3, `f3f1700`), and those specs were never fixed. In a TDD culture, the test suite would be green before and after any dependency upgrade — the broken tests would block the upgrade commit.

5. **The commit timeline shows the sequence:**
   ```
   May 14–15: Build features (15 commits)
   May 17–18: Refactor architecture (~36 commits)
   May 19:     Add tests + docs + CI (18 commits)
   May 20–22: Refactor tests (7 commits)
   May 22+:    Enhance features (15 commits)
   ```
   Test commits cluster in a narrow window _after_ feature development, not spread throughout.

**What the developer did instead:** "Build → Refactor → Test → Document." This is a pragmatic approach for a solo developer building a reference application. The features were built and validated manually against a live API (`api.realworldangular.org`), then tests were added afterward for regression protection and as a demonstration of testing patterns.

**The test quality is good** (see `README-TEST-INSIGHTS.md`) — the patterns are idiomatic, the coverage is comprehensive at 60 spec files, and the test-to-source ratio is 1.39:1. It's just not TDD.

---

## 5. Key Architectural Decisions

### 5.1 Signal-based forms over ReactiveForms

The developer chose Angular's newer signal-based forms (`form()`, `required()`, `validateAsync()`) over the traditional `FormBuilder` / `FormGroup` API. This is forward-looking — signal-based forms are the future of Angular forms — but it means the codebase requires Angular 21+.

### 5.2 Functional guards over class-based guards

All 6 guards are `CanMatchFn` functions, not `@Injectable()` classes. This eliminates DI boilerplate and makes guards testable via `TestBed.runInInjectionContext()`. The tradeoff is that guards can't have their own injected dependencies beyond what's available in the injection context.

### 5.3 `httpResource` over manual HttpClient subscriptions

`CartStore` and coupon validation use `httpResource` / `rxResource` — Angular 19's reactive HTTP primitives. These automatically re-fetch when signals change and integrate with `DestroyRef` for cleanup. This is a clean pattern but ties the codebase to Angular 21+.

### 5.4 Scoped service providers over global singletons

`CheckoutWizard` is provided in the checkout route's `providers` array, not `providedIn: 'root'`. This scopes its lifecycle to the checkout flow — when the user navigates away, the service is destroyed. This is the right call for wizard-style state that shouldn't persist across navigations.

### 5.5 No third-party UI library

The 16 shared components are all custom-built. No Angular Material, no PrimeNG, no Tailwind. This gives full control over the design but means the team maintains their own button, modal, form field, pagination, and dialog implementations.

### 5.6 `withFetch()` over XHR

The app uses `provideHttpClient(withFetch())` which switches Angular's HTTP backend from `XMLHttpRequest` to the Fetch API. This is the modern default but can have subtle differences in error handling and streaming.

### 5.7 Vitest over Karma/Jasmine

The test runner is Vitest (via `@angular/build:unit-test`) instead of the traditional Karma/Jasmine setup. This aligns with the Angular ecosystem's migration away from Karma and provides faster test execution.

---

## 6. Code Organization Patterns

### Feature structure

Each feature follows a consistent internal structure:

```
features/<name>/
├── <name>.routes.ts      # Lazy-loaded route definitions
├── <name>.models.ts      # Feature-specific types/interfaces
├── <name>-api.ts         # API service (if feature has backend calls)
├── guards/               # Feature-specific guards
├── services/             # Feature-specific services
├── components/           # Feature-specific components (not shared)
├── pages/                # Routed page components
```

### Co-located tests

Every `.ts` file has a co-located `*.spec.ts`. No separate `__tests__` or `tests/` directory. This keeps tests discoverable and makes it obvious when a file lacks test coverage.

### Selector naming convention

Shared components use the `rw-` prefix (e.g., `rw-button`, `rw-modal`, `rw-spinner`), establishing a clear boundary between shared design-system components and feature-specific components.

---

## Appendix A: Future Deep-Dive

A commit-by-commit timeline (Option A) mapping all 91 commits to specific files and architectural layers can be produced as a follow-up document. This would provide granular detail on exactly which files were touched in what order — useful for understanding the micro-level development cadence (e.g., "did the developer build the service before the page, or the page first and extract the service?").

To produce this, request a `README-SYSTEM-DESIGN-DEEP-DIVE.md` with the full commit-to-file mapping.

---

## Appendix B: Data Sources

- [Upstream commit history](https://github.com/realworld-angular/realworld-angular/commits/main) — 91 commits across 3 pages
- `realworld-angular/src/app/` — current file tree and source code
- `SYNC-NOTES.md` — pinned upstream SHA and sync history
- `README-TEST-INSIGHTS.md` — current test suite status
- `README-TESTING.md` — testing patterns and infrastructure
