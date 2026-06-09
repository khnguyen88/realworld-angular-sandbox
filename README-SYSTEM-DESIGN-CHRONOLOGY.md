# Realworld Angular — Feature Construction Chronology

> **Analysis date:** 2026-06-07
> **Source:** 91 commits from [realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular)
> **Period:** May 14 – Jun 5, 2026 (23 days)

This document traces each feature's life cycle — when it was born, how its
routes, guards, and tests evolved, and what modifications happened across the
91 commits. It's the narrative companion to the file-inventory documents
(`README-SYSTEM-DESIGN-DETAILS.md`, `README-SYSTEM-DESIGN-DETAILS-COMMITS.md`).

---

## 1. Overall Timeline

| Date      | Phase      | Commits | What Happened                                                                                                                                                                                                                                                                                                                       |
| --------- | ---------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| May 14    | P1 (early) | 4       | **Everything created.** Init commit (`a1eb73e`) lays down 217 files — all features, all 16 shared components, all guards, all services, all routes, all models. **Not a stub: full working app** with signal-based forms, lazy loading, computed cart state, full checkout flow with deactivation guard.                            |
| May 15    | P1 (late)  | 11      | **Polish and refinement.** Checkout enhanced (`1ecf2a3`), cart refactored (`c281624`), auth password toggle polished (`cf005d0`, `8f7148f`), README updated (4 commits), CSP experimentation (`b08df5c`, `95ffec9`).                                                                                                                |
| May 17    | P2 (start) | 10      | **Small fixes, admin route consistency.** Image format update, asset cleanup, footer link, admin routes refactored (`1f623fe`), orders tab removed (`fd7f4dd`).                                                                                                                                                                     |
| May 18    | P2 (main)  | 26      | **Massive refactoring day.** Base URL interceptor added (`43a4c77`), shared components consolidated (Badge→StatusBadge at `4e53703`, Callout, EmptyState, form components), `httpResource` adopted, `DestroyRef`/`takeUntilDestroyed` integrated, route titles across all features (`bca0306`), obsolete specs deleted (`cdbf77a`). |
| May 19    | P3         | 18      | **Testing blitz + ship prep.** 54 spec files added in one commit (`70dae9c`) covering every component, guard, service, page. README finalized (5 commits). CI, husky, prettier, pnpm workspace configured.                                                                                                                          |
| May 20–22 | P4         | 7       | **Test quality refinement.** Mock components replaced with real implementations (`0d66ee7`), type safety improved (`26e0388`), formatting standardized (`6cdda60`), standalone flags removed (`ca63022`). Zero new files — pure quality work.                                                                                       |
| May 22–26 | P5 (early) | 4       | **Feature expansion.** Pizzeria details pagination + load-more component (`bd72c32`). Checkout completely rebuilt as multi-step wizard (`b7f434b`). Email validation (`77c09fc`). Linting pass (`2c91bea`).                                                                                                                         |
| Jun 1–5   | P5 (late)  | 11      | **Coupon codes + polish.** Coupon functionality across 3 commits (`7d23826`, `ecd87f8`, `d5a7229`, `3322c2d`). Angular 22 upgrade (`f3f1700`). Error handling improved (`059e7fc`). Footer defer loading (`8fa08a5`).                                                                                                               |

---

## 2. Feature: Pizzerias

The largest and most complex feature — 30 files at birth, growing through every phase.
**Every commit was a full implementation or refactoring of working code — zero stubs.**

### Birth (May 14, P1)

Created in `a1eb73e` (init) as a **fully-implemented feature, not a stub**:

- **Routes:** `pizzeria.routes.ts`
- **6 pages:** `pizzeria-list-page`, `pizzeria-details-page`, `admin-pizza-list-page`, `admin-pizzeria-configuration-page`, `admin-pizzeria-details-page`, `admin-pizzeria-new-page`
- **1 component:** `admin-pizza-form-dialog`
- **3 model files:** `pizza.models.ts`, `pizzeria.models.ts`, `staff.models.ts`
- **2 services:** `pizza-api.ts`, `pizzeria-api.ts` (plus `pizzeria-api.spec.ts`)
- **1 guard:** `no-pizzeria.guard.ts` (initially in `core/guards/pizzeria/`)

### Immediate Restructuring (May 14, same day)

- `9bade76` — **Guard relocated.** `no-pizzeria.guard.ts` moved from `core/guards/pizzeria/` to `features/pizzerias/guards/`. This is a pattern: feature-specific guards belong with their feature, not in core.
- `b69db9f` — **Page renamed.** `admin-pizzeria-new-page` → `admin-pizzeria-form-page` (3 files renamed). A duplicate `admin-pizzeria-configuration/` page that was auto-generated was cleaned up. Route file updated.

### Phase 1 Polish (May 15)

- `1ecf2a3` — Admin pizzeria configuration page touched during checkout enhancement. The duplicate `admin-pizzeria-configuration/admin-pizzeria-configuration-page.html` deleted.

### Phase 2: Admin Route Consistency (May 17)

- `1f623fe` — Admin routes and links refactored for consistency across header, register page, pizza form dialog, no-pizzeria guard, admin configuration, admin details, admin form, and pizzeria routes. 9 files touched.
- `fd7f4dd` — Orders tab removed from admin pizzeria details page for streamlined navigation.

### Phase 2: Deep Refactoring (May 18)

Heaviest refactoring day for pizzerias — 12 commits touched pizzeria files:

- `552299f` — Pizzeria API service methods refactored
- `edbca41` — Pizzeria details page layout and button integration refactored
- `a34ed14` — Pizzeria details page event handling enhanced with `takeUntilDestroyed`
- `6dfdac0` — Admin pizza list page integrated `DestroyRef` and `takeUntilDestroyed`
- `4235429` — Pizzeria details page banner visibility management improved
- `396cfd7` — Admin pizzeria configuration page delete functionality improved
- `d90296c` — **New component: `AdminPizzaRow`** (3 files: ts/html/css). Admin pizza list page refactored to use it.
- `dd7eebd` — Admin pizza form dialog migrated to `httpResource` for toppings management
- `bca0306` — Route titles added to pizzeria routes and pages
- `bfeb289` — Pizza form dialogs updated for form component accessibility improvements
- `21d74dd` — Typo fix in admin pizza form dialog (`styleUrls` property)

### Phase 2/3 Transition (May 19)

- `db82d83` — Pizza order form dialog enhanced with loading and error states for toppings. Admin pizza form dialog also touched.
- `61bdfc7` — Pizza API methods refactored for consistency. Admin pizza form dialog, admin pizza row, no-pizzeria guard, pizzeria API, shared input and status-badge all updated.
- `771430c` (CartStore refactoring) — Touched header (which links to pizzeria pages).

### Phase 3: Tests Arrive (May 19)

`70dae9c` — **11 pizzeria spec files added in one commit:**

- `admin-pizza-form-dialog.spec.ts`
- `admin-pizza-row.spec.ts`
- `no-pizzeria.guard.spec.ts` (with guard source modified)
- `admin-pizza-list-page.spec.ts`
- `admin-pizzeria-configuration-page.spec.ts` (source also modified)
- `admin-pizzeria-details-page.spec.ts` (source also modified)
- `admin-pizzeria-form-page.spec.ts`
- `pizzeria-details-page.spec.ts` (source also modified)
- `pizzeria-list-page.spec.ts`
- `pizza-api.spec.ts`
- `pizzeria-api.spec.ts` (re-created; was deleted in P2)

Also `debb2fd` (prettier) reformatted nearly every pizzeria file.

### Phase 4: Test Refactoring (May 20–22)

Pizzeria specs touched in every P4 commit:

- `293373a` — Pizzeria details page spec + source updated
- `ba04b9d` — Admin pizza form dialog, admin pizza row, no-pizzeria guard, admin pizza list, admin pizzeria configuration, admin pizzeria form, pizzeria details, pizzeria list specs refactored
- `26e0388` — Admin pizza form dialog, admin pizza row, admin pizza list, admin pizzeria configuration, admin pizzeria details, admin pizzeria form, pizzeria details specs updated for change detection
- `6cdda60` — Admin pizza form dialog, admin pizzeria configuration, admin pizzeria form, pizzeria details specs + pizzeria details source restructured
- `0d66ee7` — Admin pizza form dialog, admin pizza list, admin pizzeria configuration, admin pizzeria form specs — mock components replaced with real implementations
- `ca63022` — Standalone flags removed from mock components in admin pizza form dialog, admin pizzeria configuration, admin pizzeria form specs

### Phase 5: Enhancement (May 22–26)

- `bd72c32` — Pizzeria details page enhanced with **pagination and loading states**. Also introduced the `load-more` shared component (4 new files). Full implementation, not a stub.
- `2c91bea` — Linting fixes to admin pizza list page, admin pizzeria configuration, pizzeria list page.
- `f3f1700` — Angular 22 upgrade (indirect impact — broke the no-pizzeria guard spec).

---

## 3. Feature: Auth

### Birth (May 14, P1)

Created in `a1eb73e` as a **fully-implemented feature, not a stub**:

- **Routes:** `auth.routes.ts`
- **Pages:** `login-page` (ts/html/css), `register-page` (ts/html/css)
- **Model:** `role.model.ts` (Role type, shared with core guard)

### Phase 1 Polish (May 15)

- `17565f4` — **Navigation simplified.** `postRegisterRedirect` removed from auth routes and register page. Pizzeria owner registration flow now relies on route data rather than hardcoded redirect logic.
- `157f436` — Unused import removed from login page.
- `cf005d0` — Password visibility toggle styled on both login and register pages.
- `8f7148f` — Password visibility toggle functionality enhanced on both pages.

### Phase 2: Navigation & Titles (May 17–18)

- `1f623fe` — Register page navigation refactored for admin route consistency.
- `9622b8e` — Navigation handling refactored in both login and register pages.
- `bca0306` — Route titles added to auth routes.

### Phase 3: Tests & Prettier (May 19)

- `70dae9c` — `login-page.spec.ts` and `register-page.spec.ts` added.
- `debb2fd` — Prettier pass reformatted both pages and their specs.

### Phase 5: Feature Additions (May 26 – Jun 5)

- `77c09fc` — **Email availability validation** added to registration form. Full implementation — new feature, not a stub.
- `059e7fc` — **Error handling improved** in both login and registration forms. Better user feedback on failed submissions.

Auth was one of the most **stable** features — created in init, polished in P1, and only substantially modified twice in P5.

---

## 4. Feature: Cart

### Birth (May 14, P1)

Created in `a1eb73e` as a **fully-implemented feature, not a stub**:

- **Routes:** `cart.routes.ts`
- **Store:** `cart.store.ts` (with `cart.store.spec.ts`)
- **Page:** `cart-page` (ts/html/css)

### Phase 1: Major Refactoring (May 15)

`c281624` — **Cart management and reconstruction logic enhanced.** A significant refactoring that touched the store, store spec, page HTML, and page TS. Also touched the checkout page and pizza order form dialog — the cart is cross-cutting.

### Phase 2: UI Tweaks (May 17–18)

- `0b950b3` — Full-width button class added to login link on cart page.
- `bca0306` — Page title management added to cart page.

### Phase 2/3: Store Architecture Upgrade (May 19)

- `771430c` — **CartStore refactored for improved naming and functionality.** Touched header, cart store, cart page, checkout guard, checkout page, and pizza order form dialog. This was a broad API change — method renames and signature updates cascaded across consumers.
- `76ec4cc` — **CartStore migrated to `httpResource`.** This was a significant architectural decision — the store now uses Angular 19's reactive HTTP primitive instead of manual `HttpClient` subscriptions. Cart detail fetching becomes automatic and reactive to signal changes.

### Phase 3: Tests (May 19)

- `70dae9c` — `cart.store.spec.ts` re-created (was deleted in P2), `cart-page.spec.ts` added.
- `debb2fd` — Prettier pass reformatted cart files.

### Phase 4: Test Quality (May 20–22)

- `26e0388` — Cart page spec updated for change detection and type safety.
- `6cdda60` — Cart page spec structure enhanced and formatted.

The cart feature is notable for having its **entire state management approach changed mid-development** — from manual HttpClient to httpResource. This happened in Phase 2, after the initial features were built, which is consistent with the developer's pattern of "build first, upgrade infrastructure later."

---

## 5. Feature: Checkout

The checkout feature underwent the **most dramatic evolution** of any feature — from a simple single-page checkout to a multi-step wizard with guards, form validation, and coupon codes.

### Birth (May 14, P1)

Created in `a1eb73e` as a **fully-implemented single-page checkout, not a stub**:

- **Routes:** `checkout.routes.ts`
- **Page:** `checkout-page` (ts/html/css)
- No dedicated components, no step guards, no wizard service.

### Phase 1: First Enhancement (May 15)

`1ecf2a3` — **Checkout flow enhanced.** `cart-not-empty.guard.ts` added to `features/checkout/guards/`. This is the first checkout-specific guard — it redirects to `/pizzerias` if the cart is empty. The checkout page was modified alongside changes to app routes, header, auth guard, auth service, and photon API.

### Phase 2: Incremental Improvements (May 17–18)

- `bca0306` — Page title management added.
- `9622b8e` — Navigation handling refactored in checkout page.
- `771430c` (CartStore rename) — Checkout guard and checkout page updated for new CartStore API.

### Phase 3: Tests (May 19)

- `70dae9c` — `cart-not-empty.guard.spec.ts` and `checkout-page.spec.ts` added.
- `debb2fd` — Prettier pass — checkout page heavily reformatted.
- `9795b46` — Linting fixes to cart-not-empty guard spec and checkout page spec.

### Phase 4 (May 20)

- `293373a` — Checkout-deactivate guard spec (in core) refactored.
- `ba04b9d` — Checkout-deactivate guard spec refactored further.

### Phase 5: COMPLETE REBUILD (May 26)

`b7f434b` — **The checkout page is torn down and rebuilt as a multi-step wizard.** Full implementation, not a stub. This single commit touches 24 files:

**Deleted:**

- `checkout-deactivate.guard.ts` and `.spec.ts` — the old deactivation guard removed from core

**Added (20 new files):**

- `checkout-delivery-step/` (ts, html, css, spec.ts) — 4 files
- `checkout-progress-stepper/` (ts, html, css, spec.ts) — 4 files
- `checkout-review-step/` (ts, html, css, spec.ts) — 4 files
- `checkout-schedule-step/` (ts, html, css, spec.ts) — 4 files
- `checkout-step.guard.ts` and `checkout-step.guard.spec.ts` — ensures sequential step completion
- `checkout-wizard.ts` and `checkout-wizard.spec.ts` — scoped wizard state machine

**Modified:**

- `checkout.routes.ts` — restructured for nested step routes
- `checkout-page.ts/html/css` — rewired for wizard pattern
- `order-api.ts`, `order.models.ts`, `order-details-page` — updated for new order flow
- `shared/button` — enhanced with error vibration animation
- `app.config.ts` — updated for new checkout providers

This is the single largest feature-creation event after the init commit. The developer went from a flat checkout page to a full wizard architecture with scoped service, step guards, and four dedicated step components — all with co-located specs.

### Phase 5: Coupon Codes (Jun 3–5)

- `7d23826` — **Coupon code functionality added** to checkout review step. Full implementation — new feature with specs.
- `f3f1700` — Angular 22 + TypeScript 6 upgrade (same day) — broke all guard specs including the new checkout-step guard spec.
- `ecd87f8` — **Debounce added** to coupon code validation in checkout wizard.
- `d5a7229` — **Discount reset on coupon validation error** — order-api also touched.
- `3322c2d` — Coupon code functionality further enhanced in review step and checkout wizard.

### Phase 5: Minor Fixes

- `fdd7553` — Checkout progress stepper refactored to use switch statement.

---

## 6. Feature: Orders

### Birth (May 14, P1)

Created in `a1eb73e` as a **fully-implemented feature, not a stub**:

- **Routes:** `order.routes.ts`
- **Models:** `order.models.ts`
- **API:** `order-api.ts`
- **3 pages:** `order-list-page`, `order-details-page`, `admin-order-list-page` (with `admin-order-row` sub-component)
- **2 components:** `pizza-order-form-dialog`, `pizza-size-option-field`

### Phase 1 (May 15)

- `c281624` — Pizza order form dialog touched during cart refactoring.

### Phase 2: Refactoring (May 18)

- `2c4dfbf` — Order status handling refactored in order details page.
- `31a691b` — Order row event handling and feedback display refactored. Touched admin order list page, admin order row, and order details page — a focused improvement on the admin order management UX.
- `bca0306` — Route titles added.

### Phase 2/3: Component Enhancement (May 19)

- `db82d83` — Pizza order form dialog enhanced with **loading and error states** for toppings. Also touched admin pizza form dialog and admin pizza list page — the topping loading pattern was applied across both order and admin contexts.
- `771430c` — Pizza order form dialog touched during CartStore refactoring.

### Phase 3: Tests (May 19)

`70dae9c` — **7 order spec files added:**

- `order-api.spec.ts`
- `admin-order-list-page.spec.ts`
- `admin-order-row.spec.ts`
- `order-details-page.spec.ts`
- `order-list-page.spec.ts`
- `pizza-order-form-dialog.spec.ts`
- `pizza-size-option-field.spec.ts`

`debb2fd` — Prettier pass reformatted all order files.

### Phase 4: Heavy Test Refactoring (May 20–22)

Orders specs were among the most refactored in P4:

- `9795b46` — Linting fix to pizza-order-form-dialog spec
- `293373a` — Pizza-order-form-dialog spec refactored
- `ba04b9d` — Pizza-order-form-dialog, pizza-size-option-field, admin-order-list-page, order-details-page specs refactored
- `26e0388` — Pizza-order-form-dialog, admin-order-list-page, admin-order-row specs updated for change detection
- `6cdda60` — Pizza-order-form-dialog spec structure enhanced
- `0d66ee7` — Pizza-order-form-dialog, admin-order-list-page specs — mocks replaced with real implementations
- `70725e2` — Pizza-order-form-dialog spec imports cleaned up

The pizza-order-form-dialog spec was touched in **all 7 P4 commits** — it was the most iterated-on spec in the entire test suite.

### Phase 5: Coupon Integration (May 26 – Jun 5)

- `b7f434b` (checkout rebuild) — Modified `order-api.ts`, `order.models.ts`, and order-details-page to support the new wizard flow.
- `2c91bea` — Linting fix to order-list-page.
- `7d23826` (coupon codes) — `order-api` gained `validateCoupon()` method. `order.models` gained `CouponValidation` type. Order-api spec, admin-order-list-page spec, admin-order-row spec, order-details-page spec, order-list-page spec all updated.
- `d5a7229` — Order-api touched for discount reset fix.
- `f3f1700` — Angular 22 upgrade affected order specs indirectly (compiler changes).

---

## 7. Core Layer

The core layer consists of guards, interceptors, services, layout components, and models shared across features.

### Birth (May 14, P1)

Created in `a1eb73e` as **fully-implemented code, not stubs**:

- **Guards:** `auth.guard.ts` + `.spec.ts`, `checkout-deactivate.guard.ts` + `.spec.ts`, `no-pizzeria.guard.ts` (in `core/guards/pizzeria/`), `role.guard.ts` + `.spec.ts`
- **Interceptors:** `credentials.interceptor.ts` + `.spec.ts`
- **Services:** `auth.ts` + `.spec.ts`, `photon-api.ts` + `.spec.ts`
- **Layout:** `footer/` (ts/html/css), `header/` (ts/html/css)
- **Models:** `pagination.model.ts`, `user.model.ts`

### Phase 1: Guard Relocation & Service Modifications (May 14–15)

- `9bade76` — `no-pizzeria.guard` moved from `core/guards/pizzeria/` to `features/pizzerias/guards/`. This established the pattern: feature-specific guards live with their feature.
- `1ecf2a3` — Auth guard, auth service, photon-api modified during checkout enhancement. Header modified.
- `c281624` — Auth guard spec and checkout-deactivate guard spec touched during cart refactoring. `app.spec.ts` also modified.

### Phase 2: Infrastructure & Mass Deletion (May 17–18)

- `dfd03e7` — Footer link updated to GitHub Sponsors.
- `1f623fe` — Header HTML updated for new admin routes.
- `43a4c77` — **Base URL interceptor added** (`base-url.interceptor.ts` + `.spec.ts`). Full implementation — centralized API URL construction, eliminated the proxy configuration. Environment files created (`environment.ts`, `environment.development.ts`).
- `6367050` — Base URL interceptor enhanced to handle image requests.
- `3199805` — Base URL handling refactored in both interceptor and image URL pipe.
- `bca0306` — Route titles added across all features (including profile, legal, not-found, unauthorized).
- **`cdbf77a` — MASS DELETION of 10 spec files:**
  - `app.spec.ts`
  - `auth.guard.spec.ts`
  - `checkout-deactivate.guard.spec.ts`
  - `role.guard.spec.ts`
  - `base-url.interceptor.spec.ts`
  - `credentials.interceptor.spec.ts`
  - `auth.spec.ts`
  - `photon-api.spec.ts`
  - `cart.store.spec.ts`
  - `pizzeria-api.spec.ts`

  This is a critical moment — the developer decided the initial auto-generated specs were not worth maintaining and should be replaced from scratch.

### Phase 3: Tests Reborn (May 19)

`70dae9c` — **All 9 core specs re-created from scratch:**

- `footer.spec.ts` (new — didn't exist before)
- `header.spec.ts` (new — didn't exist before)
- `auth.guard.spec.ts` (re-created)
- `checkout-deactivate.guard.spec.ts` (re-created)
- `role.guard.spec.ts` (re-created)
- `base-url.interceptor.spec.ts` (re-created)
- `credentials.interceptor.spec.ts` (re-created)
- `auth.spec.ts` (re-created)
- `photon-api.spec.ts` (re-created)

Plus header/cart store modifications for CartStore refactoring (`771430c`) and ngSrc image handling (`922d723`).

`debb2fd` — Prettier pass touched header css, footer, auth guard spec, role guard spec, role guard, auth spec, photon-api.

### Phase 4: Test Refinement (May 20–22)

- `9795b46` — Linting fixes to header spec, auth guard spec, checkout-deactivate guard spec, photon-api spec.
- `ba04b9d` — Auth guard spec, checkout-deactivate guard spec, role guard spec refactored.
- `6cdda60` — Auth guard spec, role guard spec structure enhanced.
- `293373a` — Checkout-deactivate guard spec refactored.

### Phase 5: Guard Deletion & Footer Addition (May 26 – Jun 5)

- `b7f434b` (checkout rebuild) — **Checkout-deactivate guard permanently removed** (both `.ts` and `.spec.ts`). The old monolithic guard was replaced by the new `checkout-step.guard` in the checkout feature. Shared button component enhanced.
- `81abd79` — Header profile link accessibility fixed.
- `8fa08a5` — **Footer placeholder added** with `@defer` loading.

---

## 8. Shared Components

### Birth (May 14, P1)

All 16 shared components created in `a1eb73e` as **fully-implemented components, not stubs**:

| Component               | Files                          |
| ----------------------- | ------------------------------ |
| `avatar`                | ts, html, css                  |
| `badge`                 | ts, html, css                  |
| `button`                | ts, html, css                  |
| `callout`               | ts, html, css                  |
| `confirm-dialog`        | ts, html, css                  |
| `empty-state`           | ts, html, css                  |
| `hero-banner`           | ts, html, css                  |
| `image-picker`          | ts, html, css                  |
| `input`                 | ts, html, css                  |
| `modal`                 | ts, html, css, modal-footer.ts |
| `pagination`            | ts, html, css                  |
| `photon-location-field` | ts, html, css                  |
| `pizza-logo`            | ts, html, css                  |
| `spinner`               | ts, html, css                  |
| `status-badge`          | ts, html                       |
| `textarea`              | ts, html, css                  |

Plus: `role.directive.ts`, `address.model.ts`, `catalog-image-url.pipe.ts`

### Phase 2: Consolidation & Accessibility (May 18)

This is where the shared component library matured:

- `3199805` — Catalog image URL pipe refactored to work with the new base URL interceptor.
- `b962582` — Confirm dialog imports cleaned up.
- **`4e53703` — Badge component merged into StatusBadge.** `badge.ts` and `badge.html` deleted. `badge.css` renamed to `status-badge.css`. This reduced the component count from 16 to 15 and eliminated a redundant component.
- `700957e` — Callout restructured for improved clarity.
- `7cf6ccc` — EmptyState streamlined — message handling simplified.
- `bb9d261` — Image picker category handling improved.
- `bfeb289` — **Form components accessibility pass.** Input, textarea, image-picker, photon-location-field, pagination all updated. Pizza order form dialog and admin pizza form dialog also touched.
- `d94e072` — PhotonLocationField further enhanced for functionality and keyboard accessibility.
- `61bdfc7` — Input and status-badge touched during pizza API consistency refactoring.

### Phase 3: Tests & ngSrc Migration (May 19)

- `70dae9c` — **18 shared specs added** — every component, directive, and pipe got a spec file.
- `922d723` — Image handling updated to use `ngSrc` for optimized loading. Callout, hero-banner, pagination, modal all updated.
- `debb2fd` — Prettier pass touched nearly every shared component.

### Phase 4: Test Refinement (May 20–22)

- `9795b46` — Linting fixes to confirm-dialog spec, textarea, role directive spec.
- `ba04b9d` — Photon-location-field spec refactored.
- `26e0388` — Input spec, photon-location-field spec, textarea spec updated. Modal.ts updated.
- `6cdda60` — Input spec, photon-location-field spec, textarea spec structure enhanced. Pizza-logo, spinner, status-badge, input, pagination all formatted.
- `0d66ee7` — Photon-location-field had mock components replaced with real implementations.

### Phase 5: New Component & Button Enhancement (May 22–26)

- `bd72c32` — **`load-more` component added** (4 files: ts/html/css/spec.ts). Full implementation — first new shared component since init, an infinite scroll trigger using scroll + ResizeObserver.
- `b7f434b` — Button enhanced with error vibration animation for the checkout rebuild.

The shared component layer was remarkably **stable** — all 15 (originally 16) components were created in the first commit, one was merged away in Phase 2, and only one new component was added in Phase 5.

---

## 9. Simple Features

Four features had minimal evolution after creation. Each was a **fully-implemented feature from birth** — no stubs:

### Profile

- **P1 (`a1eb73e`):** `profile.routes.ts`, `profile-page` (ts/html/css) — full implementation
- **P2 (`bca0306`):** Route title added
- **P2 (`7166c62`):** Route migrated from `canActivate` to `canMatch`
- **P3 (`70dae9c`):** `profile-page.spec.ts` added
- **P3 (`debb2fd`):** Prettier
- **P4 (`26e0388`, `6cdda60`):** Spec updated for change detection and formatting

### Legal (Terms & Conditions)

- **P1 (`a1eb73e`):** `legal.routes.ts`, `terms-and-conditions-page` (ts/html/css)
- **P2 (`bca0306`):** Route title added
- **P2 (`eb25082`):** Redundant text removed
- **P3 (`02b8d04`):** FAQ section added
- **P3 (`70dae9c`):** `terms-and-conditions-page.spec.ts` added
- **P3 (`debb2fd`):** Prettier

### Not-Found (404)

- **P1 (`a1eb73e`):** `not-found.routes.ts`, `not-found-page` (ts/html/css)
- **P2 (`bca0306`):** Route title added
- **P3 (`70dae9c`):** `not-found-page.spec.ts` added
- **P3 (`debb2fd`):** Prettier

### Unauthorized

- **P1 (`a1eb73e`):** `unauthorized.routes.ts`, `unauthorized-page` (ts/html/css)
- **P2 (`bca0306`):** Route title added
- **P3 (`70dae9c`):** `unauthorized-page.spec.ts` added
- **P3 (`debb2fd`):** Prettier

---

## 10. Cross-Cutting Timelines

### 10.1 Guards: Birth, Death, and Rebirth

| Guard                       | Created              | Spec Deleted   | Spec Re-created | Final Fate                             |
| --------------------------- | -------------------- | -------------- | --------------- | -------------------------------------- |
| `auth.guard`                | P1 (core)            | P2 (`cdbf77a`) | P3 (`70dae9c`)  | Active, spec refined P4                |
| `guestGuard`                | P1 (same file)       | P2             | P3              | Active                                 |
| `role.guard`                | P1 (core)            | P2 (`cdbf77a`) | P3 (`70dae9c`)  | Active, spec refined P4                |
| `no-pizzeria.guard`         | P1 (core) → moved P1 | Never deleted  | P3 (`70dae9c`)  | Active                                 |
| `checkout-deactivate.guard` | P1 (core)            | P2 (`cdbf77a`) | P3 (`70dae9c`)  | **Deleted entirely in P5** (`b7f434b`) |
| `cart-not-empty.guard`      | P1 (checkout)        | Never deleted  | P3 (`70dae9c`)  | Active                                 |
| `checkout-step.guard`       | —                    | —              | —               | **Created P5** (`b7f434b`), active     |

The pattern is striking: **7 initial guards, 6 had their specs thrown away, 5 were re-created, 1 was permanently deleted, 1 was newly created.** The guard spec lifecycle (create → delete → re-create → refine → some deleted) maps exactly to the developer's "build → refactor → test → refine → enhance" rhythm.

### 10.2 Test Suite: From Zero to 60

| Phase  | Spec Files | Net Change | Key Event                                                                                                                                                                                                                                                                                             |
| ------ | ---------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **P1** | 10         | +10        | Initial auto-generated specs (auth.guard, checkout-deactivate, role.guard, credentials.interceptor, auth, photon-api, pizzeria-api, cart.store, app)                                                                                                                                                  |
| **P2** | 0          | −10        | All 10 specs deleted (`cdbf77a`)                                                                                                                                                                                                                                                                      |
| **P3** | 54         | +54        | Complete test suite written (`70dae9c`) — 45 new + 9 re-created                                                                                                                                                                                                                                       |
| **P4** | 54         | 0          | ~40 specs refactored for quality                                                                                                                                                                                                                                                                      |
| **P5** | 60         | +6         | New specs for checkout wizard components, checkout-step guard, checkout-wizard, load-more. (Also: checkout-deactivate spec permanently removed, net +4 to 58, plus app.spec never re-created = 57... but the suite is at 60 because some features had specs that never went through the delete cycle) |

### 10.3 Routes: Progressive Refinement

| Phase  | What Changed                                                                                                                  |
| ------ | ----------------------------------------------------------------------------------------------------------------------------- |
| **P1** | All 11 route files created: `app.routes.ts` + 10 feature route files                                                          |
| **P1** | App routes modified for checkout enhancement (`1ecf2a3`)                                                                      |
| **P1** | Auth routes simplified — postRegisterRedirect removed (`17565f4`)                                                             |
| **P2** | Pizzeria admin routes refactored for consistency (`1f623fe`, `fd7f4dd`)                                                       |
| **P2** | **Route titles added globally** — every feature route file updated with title metadata (`bca0306`)                            |
| **P2** | Profile route migrated from `canActivate` to `canMatch` (`7166c62`)                                                           |
| **P5** | **Checkout routes completely restructured** — from flat single-page to nested multi-step wizard with child routes (`b7f434b`) |

### 10.4 Interceptors: Built Late, Tested Late

| Event                                      | Commit    | Phase |
| ------------------------------------------ | --------- | ----- |
| `credentials.interceptor` created          | `a1eb73e` | P1    |
| `credentials.interceptor` spec created     | `a1eb73e` | P1    |
| `credentials.interceptor` spec deleted     | `cdbf77a` | P2    |
| `base-url.interceptor` created             | `43a4c77` | P2    |
| `base-url.interceptor` spec created        | `43a4c77` | P2    |
| `base-url.interceptor` spec deleted        | `cdbf77a` | P2    |
| `base-url.interceptor` enhanced for images | `6367050` | P2    |
| Both interceptors refactored with pipe     | `3199805` | P2    |
| Both specs re-created                      | `70dae9c` | P3    |

The `baseUrlInterceptor` is the only architectural component that was **not present in the init commit** — it was introduced in Phase 2 after the developer realized the need to centralize API URL construction.

---

## 11. Summary: The Developer's Rhythm

| Day    | Commits | Dominant Activity                                                                                                                                            |
| ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| May 14 | 4       | **Scaffold everything.** 264 files across all layers. Every feature, component, guard, service in one burst.                                                 |
| May 15 | 11      | **Polish what exists.** No new features. Refinement of checkout, cart, auth, README.                                                                         |
| May 17 | 10      | **Prepare for refactoring.** Small admin UI fixes, asset cleanup.                                                                                            |
| May 18 | 26      | **Architecture hardening.** Interceptor added. Components consolidated. httpResource adopted. DestroyRef integrated. Old specs purged. The most intense day. |
| May 19 | 18      | **Ship preparation.** 54 specs written. README finalized. CI, husky, prettier, linting configured.                                                           |
| May 20 | 3       | **Linting + test refinement begins.**                                                                                                                        |
| May 21 | 6       | **Test quality overhaul.** Mocks → real components. Type safety. Structure.                                                                                  |
| May 22 | 1       | **Feature expansion starts again.** Pagination + load-more.                                                                                                  |
| May 26 | 3       | **Checkout rebuilt.** Email validation.                                                                                                                      |
| Jun 1  | 2       | **Engine pinning.** Switch refactoring.                                                                                                                      |
| Jun 2  | 1       | **Accessibility fix.**                                                                                                                                       |
| Jun 3  | 2       | **Coupon codes + Angular 22 upgrade.**                                                                                                                       |
| Jun 5  | 6       | **Coupon polish + error handling + icons + footer.**                                                                                                         |

### The Pattern in One Sentence

**Build everything fast (2 days) → Refactor architecture (2 days) → Write all tests + docs + CI (1 day) → Refine test quality (2 days) → Add new features incrementally (spread over 2 weeks).**

## This is a disciplined solo-developer workflow: get it working, make it right, prove it works, then extend. The 48-hour "build everything" burst at the start is particularly notable — the developer had a clear vision of the full architecture from the beginning and executed it rapidly, then spent the remaining 3 weeks hardening and extending.

## 12. Unified Project Timeline (All Features)

This section pulls every feature's lifecycle into a single chronological view,
organized by commit. Each entry shows which feature was touched, the type of
change (birth, refactor, test, enhancement), and whether it was a stub.

### May 14 — Birth (4 commits)

| Commit    | Feature                                                                                            | Type      | What Happened                                                                                                                                |
| --------- | -------------------------------------------------------------------------------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `a1eb73e` | **All** (Pizzerias, Auth, Cart, Checkout, Orders, Core, Shared, Profile, Legal, 404, Unauthorized) | **Birth** | 217 files. Full working app — not a stub. Signal-based forms, lazy loading, computed cart state, 16 shared components, 7 guards, all routes. |
| `072a8c6` | Pizzerias                                                                                          | Refactor  | API route paths standardized.                                                                                                                |
| `9bade76` | Pizzerias                                                                                          | Refactor  | `noPizzeriaGuard` moved from core to feature.                                                                                                |
| `b69db9f` | Pizzerias                                                                                          | Birth     | Admin pizzeria form page + route. Duplicate auto-generated page cleaned up.                                                                  |

### May 15 — Polish (11 commits)

| Commit    | Feature                   | Type        | What Happened                                                                                |
| --------- | ------------------------- | ----------- | -------------------------------------------------------------------------------------------- |
| `1ecf2a3` | Checkout, Core, Pizzerias | Enhancement | `cart-not-empty.guard` added. Checkout flow enhanced. Auth guard/service/photon-api updated. |
| `17565f4` | Auth                      | Refactor    | `postRegisterRedirect` removed from auth routes + register page.                             |
| `157f436` | Auth                      | Cleanup     | Unused import removed from login page.                                                       |
| `a6d584d` | Config                    | Docs        | README + app config updates.                                                                 |
| `489895d` | Config                    | Docs        | README checklist item removed.                                                               |
| `cf005d0` | Auth                      | Polish      | Password visibility toggle styled (login + register).                                        |
| `8f7148f` | Auth                      | Enhancement | Password visibility toggle functionality enhanced.                                           |
| `2f47ea5` | Config                    | Docs        | README updated.                                                                              |
| `b08df5c` | Config                    | Config      | CSP configuration added.                                                                     |
| `95ffec9` | Config                    | Config      | CSP meta tag removed (reverted).                                                             |
| `c281624` | Cart, Checkout            | Refactor    | Cart management + reconstruction logic refactored.                                           |

### May 17 — Admin Consistency (10 commits)

| Commit    | Feature                        | Type        | What Happened                                                              |
| --------- | ------------------------------ | ----------- | -------------------------------------------------------------------------- |
| `bde53e1` | Pizzerias                      | Fix         | Image format updated.                                                      |
| `08317f7` | Assets                         | Cleanup     | Pizza image removed from public assets.                                    |
| `0b950b3` | Cart                           | Polish      | Full-width button class on login link.                                     |
| `dfd03e7` | Core (Footer)                  | Fix         | Footer link → GitHub Sponsors.                                             |
| `1f623fe` | Pizzerias, Auth, Core (Header) | Refactor    | Admin routes + links refactored for consistency (9 files).                 |
| `fd7f4dd` | Pizzerias                      | Polish      | Orders tab removed from admin pizzeria details.                            |
| `43a4c77` | Core (Interceptor)             | **Birth**   | `base-url.interceptor.ts` + spec + environment files. Full implementation. |
| `6367050` | Core (Interceptor)             | Enhancement | Base URL interceptor extended for image requests.                          |
| `cd435fb` | Config                         | Cleanup     | Proxy config removed from angular.json.                                    |
| `1f7eb63` | Deps                           | Deps        | Angular deps updated in lockfile.                                          |

### May 18 — Architecture Hardening (26 commits)

| Commit    | Feature                    | Type          | What Happened                                                 |
| --------- | -------------------------- | ------------- | ------------------------------------------------------------- |
| `3199805` | Core (Interceptor), Shared | Refactor      | Base URL handling refactored in interceptor + image pipe.     |
| `7ee7518` | Config                     | Docs          | MIT License added.                                            |
| `2c4dfbf` | Orders                     | Refactor      | Order status handling refactored.                             |
| `bca0306` | **All features**           | Enhancement   | Route titles added globally — every route file updated.       |
| `31a691b` | Orders                     | Refactor      | Order row event handling + feedback display.                  |
| `552299f` | Pizzerias                  | Refactor      | Pizzeria API methods refactored.                              |
| `edbca41` | Pizzerias                  | Refactor      | Pizzeria details page layout + button integration.            |
| `9622b8e` | Auth, Checkout             | Refactor      | Navigation handling refactored.                               |
| `a34ed14` | Pizzerias                  | Refactor      | `takeUntilDestroyed` integrated in pizzeria details.          |
| `6dfdac0` | Pizzerias                  | Refactor      | `DestroyRef` + `takeUntilDestroyed` in admin pizza list.      |
| `7166c62` | Profile                    | Refactor      | `canActivate` → `canMatch`.                                   |
| `b962582` | Shared                     | Cleanup       | Confirm dialog imports cleaned.                               |
| `21d74dd` | Pizzerias                  | Fix           | Typo: `styleUrls` property.                                   |
| `4e53703` | Shared                     | Consolidation | Badge merged into StatusBadge (2 files deleted).              |
| `700957e` | Shared                     | Refactor      | Callout restructured.                                         |
| `7cf6ccc` | Shared                     | Refactor      | EmptyState streamlined.                                       |
| `bb9d261` | Shared                     | Refactor      | Image picker category handling.                               |
| `bfeb289` | Shared, Pizzerias          | Enhancement   | Form components accessibility pass.                           |
| `d94e072` | Shared                     | Enhancement   | PhotonLocationField: functionality + keyboard a11y.           |
| `4235429` | Pizzerias                  | Refactor      | Banner visibility management.                                 |
| `396cfd7` | Pizzerias                  | Refactor      | Delete functionality improved.                                |
| `d90296c` | Pizzerias                  | **Birth**     | `AdminPizzaRow` component (3 files). Full implementation.     |
| `dd7eebd` | Pizzerias                  | Upgrade       | `httpResource` for toppings management.                       |
| `db82d83` | Orders, Pizzerias          | Enhancement   | Pizza order form dialog: loading + error states for toppings. |
| `61bdfc7` | Pizzerias, Shared          | Refactor      | Pizza API methods consistency refactoring.                    |
| `cdbf77a` | Core                       | Cleanup       | 10 obsolete spec files deleted (all re-created in P3).        |

### May 19 (early) — Store Upgrade (2 commits)

| Commit    | Feature                           | Type     | What Happened                                |
| --------- | --------------------------------- | -------- | -------------------------------------------- |
| `771430c` | Cart, Checkout, Orders, Pizzerias | Refactor | CartStore naming + functionality refactored. |
| `76ec4cc` | Cart                              | Upgrade  | CartStore → `httpResource`.                  |

### May 19 (late) — Tests + Ship Prep (18 commits)

| Commit    | Feature | Type        | What Happened                                                                      |
| --------- | ------- | ----------- | ---------------------------------------------------------------------------------- |
| `70dae9c` | **All** | **Test**    | 54 spec files — every component, guard, service, page. Full test suite, not stubs. |
| `922d723` | Shared  | Enhancement | Image handling → `ngSrc`.                                                          |
| `eb25082` | Legal   | Cleanup     | Redundant text removed from T&C.                                                   |
| `02b8d04` | Legal   | Enhancement | FAQ section added to T&C.                                                          |
| `944d810` | Config  | Docs        | README: project purpose + features.                                                |
| `2114d67` | Config  | Config      | Environment dev configuration.                                                     |
| `cd764d5` | Config  | Cleanup     | Comment removed from environment file.                                             |
| `f385a09` | Config  | Docs        | README: project name change.                                                       |
| `49de7ab` | Config  | Docs        | README: contribution guidelines.                                                   |
| `e2ac29a` | Config  | Docs        | README: API documentation link.                                                    |
| `debb2fd` | **All** | Formatting  | Prettier pass across entire codebase.                                              |
| `e267022` | Tooling | Config      | Husky for Git hooks.                                                               |
| `5df43a6` | Tooling | Config      | `packageManager` field removed.                                                    |
| `0f8aff4` | Tooling | Config      | PNPM workspace + build permissions.                                                |
| `0f8aff4` | Tooling | CI          | Test command simplified in CI workflow.                                            |

### May 20–22 — Test Quality (7 commits)

| Commit    | Feature                         | Type     | What Happened                                  |
| --------- | ------------------------------- | -------- | ---------------------------------------------- |
| `9795b46` | **All**                         | Fix      | Linting fixes across ~10 specs.                |
| `293373a` | Pizzerias                       | Refactor | Tests + pizzeria details page refactored.      |
| `ba04b9d` | Core, Pizzerias, Orders, Shared | Refactor | ~12 guard/component specs refactored.          |
| `26e0388` | Pizzerias, Cart, Orders, Shared | Refactor | Change detection + type safety in tests.       |
| `6cdda60` | Pizzerias, Core, Shared, Cart   | Refactor | Test structure + formatting across ~15 specs.  |
| `0d66ee7` | Pizzerias, Orders, Shared       | Quality  | Mock components → real implementations.        |
| `ca63022` | Pizzerias                       | Cleanup  | Standalone flags removed from mock components. |

### May 22–26 — Feature Expansion (3 commits)

| Commit    | Feature                        | Type        | What Happened                                                                                                      |
| --------- | ------------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------------ |
| `bd72c32` | Pizzerias, Shared              | **Birth**   | Pagination + `load-more` component (4 files). Full implementation.                                                 |
| `b7f434b` | Checkout, Orders, Core, Shared | **Rebuild** | Checkout → multi-step wizard. 20 new files, 4 modified, 2 deleted. All with co-located specs. Full implementation. |
| `77c09fc` | Auth                           | **Birth**   | Email availability validation on registration. Full implementation.                                                |

### May 26 – Jun 1 (3 commits)

| Commit    | Feature           | Type     | What Happened                         |
| --------- | ----------------- | -------- | ------------------------------------- |
| `2c91bea` | Pizzerias, Orders | Fix      | Linting pass.                         |
| `2a1e52a` | Config            | Config   | Node engine versions in package.json. |
| `fdd7553` | Checkout          | Refactor | Progress stepper → switch statement.  |

### Jun 2–5 — Polish + Coupons (6 commits)

| Commit    | Feature          | Type        | What Happened                                                  |
| --------- | ---------------- | ----------- | -------------------------------------------------------------- |
| `81abd79` | Core (Header)    | Fix         | Profile link accessibility.                                    |
| `7d23826` | Checkout, Orders | **Birth**   | Coupon code functionality. Full implementation with specs.     |
| `f3f1700` | Deps             | Deps        | Angular 22 + TypeScript 6 upgrade.                             |
| `8fa08a5` | Core (Footer)    | **Birth**   | Footer placeholder with `@defer` loading. Full implementation. |
| `ecd87f8` | Checkout         | Enhancement | Debounce on coupon validation.                                 |
| `d5a7229` | Checkout, Orders | Fix         | Discount reset on coupon validation error.                     |
| `059e7fc` | Auth             | Fix         | Error handling in login + registration forms.                  |
| `bba14ca` | Assets           | Asset       | Sync icon SVG added.                                           |
| `3322c2d` | Checkout         | Enhancement | Coupon code functionality enhanced.                            |

### Summary

**0 stubs in 91 commits.** The init commit was a complete working application
(signal-based forms, lazy loading, computed state, full routing, 16 shared
components). Every subsequent commit was a refactoring of working code, a full
feature implementation, or infrastructure/config. The 23-day timeline was:
birth (2 days) → hardening (2 days) → testing (1 day) → quality (2 days) →
feature expansion (2 weeks).
