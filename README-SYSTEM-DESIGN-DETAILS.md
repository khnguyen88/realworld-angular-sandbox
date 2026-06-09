# System Design Details -- File Creation by Phase

This document inventories files by the phase in which they were **first introduced**
(status `A` added or `R` renamed). A file belongs to the first phase where it
appears with `A` or `R` in the commit log. Files that were later deleted or
re-created are still shown in their original creation phase.

---

## Phase 1: Foundation

**Date range:** May 14--15, 2026
**Commits:** a1eb73e through c281624 (15 commits)
**Summary:** Initial project scaffold, all feature modules, shared components, guards, services, models, routes, and initial (later removed) test files. Tooling and CI configuration added in the second commit.

### Root / Config (17 files)

| File | SHA |
|------|-----|
| `angular.json` | a1eb73e |
| `eslint.config.js` | a1eb73e |
| `package.json` | a1eb73e |
| `pnpm-lock.yaml` | a1eb73e |
| `proxy.conf.json` | a1eb73e |
| `README.md` | a1eb73e |
| `skills-lock.json` | a1eb73e |
| `src/index.html` | a1eb73e |
| `src/main.ts` | a1eb73e |
| `src/styles.css` | a1eb73e |
| `src/styles/components/input.css` | a1eb73e |
| `src/styles/design-system/_reset.css` | a1eb73e |
| `src/styles/design-system/_tokens.css` | a1eb73e |
| `tsconfig.app.json` | a1eb73e |
| `tsconfig.json` | a1eb73e |
| `tsconfig.spec.json` | a1eb73e |

**Count: 16** (moved `no-pizzeria.guard.ts` counted under Pizzerias after rename)

### Public Assets (40 files)

| File | SHA |
|------|-----|
| `public/favicon.ico` | a1eb73e |
| `public/favicon.png` | a1eb73e |
| `public/favicon.svg` | a1eb73e |
| `public/icons/add.svg` | a1eb73e |
| `public/icons/bookmark-check.svg` | a1eb73e |
| `public/icons/bookmark.svg` | a1eb73e |
| `public/icons/cancel.svg` | a1eb73e |
| `public/icons/check.svg` | a1eb73e |
| `public/icons/chevron-left.svg` | a1eb73e |
| `public/icons/chevron-right.svg` | a1eb73e |
| `public/icons/close.svg` | a1eb73e |
| `public/icons/content-copy.svg` | a1eb73e |
| `public/icons/delete.svg` | a1eb73e |
| `public/icons/delivery.svg` | a1eb73e |
| `public/icons/edit.svg` | a1eb73e |
| `public/icons/empty-shopping-cart.svg` | a1eb73e |
| `public/icons/error.svg` | a1eb73e |
| `public/icons/external-link.svg` | a1eb73e |
| `public/icons/folder-off.svg` | a1eb73e |
| `public/icons/location-off.svg` | a1eb73e |
| `public/icons/menu.svg` | a1eb73e |
| `public/icons/person-add.svg` | a1eb73e |
| `public/icons/person-cancel.svg` | a1eb73e |
| `public/icons/person-off.svg` | a1eb73e |
| `public/icons/remove.svg` | a1eb73e |
| `public/icons/search.svg` | a1eb73e |
| `public/icons/shopping-cart.svg` | a1eb73e |
| `public/icons/success.svg` | a1eb73e |
| `public/icons/visibility-off.svg` | a1eb73e |
| `public/icons/visibility.svg` | a1eb73e |
| `public/images/pizza.jpg` | a1eb73e |
| `public/images/pizzas/pizza-1.jpg` | a1eb73e |
| `public/images/pizzas/pizza.jpg` | a1eb73e |
| `public/images/pizzas/pizza.png` | a1eb73e |
| `public/images/pizzeria.jpg` | a1eb73e |
| `public/images/pizzerias/pizzeria-1.jpg` | a1eb73e |
| `public/images/pizzerias/pizzeria.png` | a1eb73e |
| `public/images/realworld-angular-banner.png` | a1eb73e |
| `public/light-logo.gif` | a1eb73e |
| `public/light-logo.svg` | a1eb73e |

### Core (18 files)

| File | SHA |
|------|-----|
| `src/app/app.config.ts` | a1eb73e |
| `src/app/app.css` | a1eb73e |
| `src/app/app.html` | a1eb73e |
| `src/app/app.routes.ts` | a1eb73e |
| `src/app/app.ts` | a1eb73e |
| `src/app/core/components/footer/footer.css` | a1eb73e |
| `src/app/core/components/footer/footer.html` | a1eb73e |
| `src/app/core/components/footer/footer.ts` | a1eb73e |
| `src/app/core/components/header/header.css` | a1eb73e |
| `src/app/core/components/header/header.html` | a1eb73e |
| `src/app/core/components/header/header.ts` | a1eb73e |
| `src/app/core/guards/auth/auth.guard.ts` | a1eb73e |
| `src/app/core/guards/checkout-deactivate/checkout-deactivate.guard.ts` | a1eb73e |
| `src/app/core/guards/role/role.guard.ts` | a1eb73e |
| `src/app/core/interceptors/credentials.interceptor.ts` | a1eb73e |
| `src/app/core/models/pagination.model.ts` | a1eb73e |
| `src/app/core/models/user.model.ts` | a1eb73e |
| `src/app/core/services/auth.ts` | a1eb73e |
| `src/app/core/services/photon-api.ts` | a1eb73e |

Note: `no-pizzeria.guard.ts` was originally created at `src/app/core/guards/pizzeria/`
and renamed in the same phase; it is listed under Pizzerias at its final path.

### Features -- Auth (8 files)

| File | SHA |
|------|-----|
| `src/app/features/auth/auth.routes.ts` | a1eb73e |
| `src/app/features/auth/pages/login-page/login-page.css` | a1eb73e |
| `src/app/features/auth/pages/login-page/login-page.html` | a1eb73e |
| `src/app/features/auth/pages/login-page/login-page.ts` | a1eb73e |
| `src/app/features/auth/pages/register-page/register-page.css` | a1eb73e |
| `src/app/features/auth/pages/register-page/register-page.html` | a1eb73e |
| `src/app/features/auth/pages/register-page/register-page.ts` | a1eb73e |
| `src/app/features/auth/role.model.ts` | a1eb73e |

### Features -- Cart (5 files)

| File | SHA |
|------|-----|
| `src/app/features/cart/cart.routes.ts` | a1eb73e |
| `src/app/features/cart/cart.store.ts` | a1eb73e |
| `src/app/features/cart/pages/cart-page/cart-page.css` | a1eb73e |
| `src/app/features/cart/pages/cart-page/cart-page.html` | a1eb73e |
| `src/app/features/cart/pages/cart-page/cart-page.ts` | a1eb73e |

### Features -- Checkout (5 files)

| File | SHA |
|------|-----|
| `src/app/features/checkout/checkout.routes.ts` | a1eb73e |
| `src/app/features/checkout/guards/cart-not-empty.guard.ts` | 1ecf2a3 |
| `src/app/features/checkout/pages/checkout-page/checkout-page.css` | a1eb73e |
| `src/app/features/checkout/pages/checkout-page/checkout-page.html` | a1eb73e |
| `src/app/features/checkout/pages/checkout-page/checkout-page.ts` | a1eb73e |

### Features -- Orders (20 files)

| File | SHA |
|------|-----|
| `src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.css` | a1eb73e |
| `src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.html` | a1eb73e |
| `src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.ts` | a1eb73e |
| `src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.css` | a1eb73e |
| `src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.html` | a1eb73e |
| `src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.ts` | a1eb73e |
| `src/app/features/orders/order-api.ts` | a1eb73e |
| `src/app/features/orders/order.models.ts` | a1eb73e |
| `src/app/features/orders/order.routes.ts` | a1eb73e |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.css` | a1eb73e |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.html` | a1eb73e |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.ts` | a1eb73e |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.html` | a1eb73e |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.ts` | a1eb73e |
| `src/app/features/orders/pages/order-details-page/order-details-page.css` | a1eb73e |
| `src/app/features/orders/pages/order-details-page/order-details-page.html` | a1eb73e |
| `src/app/features/orders/pages/order-details-page/order-details-page.ts` | a1eb73e |
| `src/app/features/orders/pages/order-list-page/order-list-page.css` | a1eb73e |
| `src/app/features/orders/pages/order-list-page/order-list-page.html` | a1eb73e |
| `src/app/features/orders/pages/order-list-page/order-list-page.ts` | a1eb73e |

### Features -- Pizzerias (30 files)

| File | SHA |
|------|-----|
| `src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.css` | a1eb73e |
| `src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.html` | a1eb73e |
| `src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.ts` | a1eb73e |
| `src/app/features/pizzerias/guards/no-pizzeria.guard.ts` | 9bade76 |
| `src/app/features/pizzerias/models/pizza.models.ts` | a1eb73e |
| `src/app/features/pizzerias/models/pizzeria.models.ts` | a1eb73e |
| `src/app/features/pizzerias/models/staff.models.ts` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.css` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.html` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.ts` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.css` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.html` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.ts` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-configuration/admin-pizzeria-configuration-page.html` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.css` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.html` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.ts` | a1eb73e |
| `src/app/features/pizzerias/pages/admin-pizzeria-form-page/admin-pizzeria-form-page.css` | b69db9f |
| `src/app/features/pizzerias/pages/admin-pizzeria-form-page/admin-pizzeria-form-page.html` | b69db9f |
| `src/app/features/pizzerias/pages/admin-pizzeria-form-page/admin-pizzeria-form-page.ts` | b69db9f |
| `src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.css` | a1eb73e |
| `src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.html` | a1eb73e |
| `src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.ts` | a1eb73e |
| `src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.css` | a1eb73e |
| `src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.html` | a1eb73e |
| `src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.ts` | a1eb73e |
| `src/app/features/pizzerias/pizzeria.routes.ts` | a1eb73e |
| `src/app/features/pizzerias/services/pizza-api.ts` | a1eb73e |
| `src/app/features/pizzerias/services/pizzeria-api.ts` | a1eb73e |

Note: `admin-pizzeria-form-page/` files were created as `admin-pizzeria-new-page/`
and renamed in the same phase. `admin-pizzeria-configuration/admin-pizzeria-configuration-page.html`
was created in this phase and deleted later in the same phase (commit 1ecf2a3).

### Features -- Other (16 files)

| File | SHA |
|------|-----|
| `src/app/features/legal/legal.routes.ts` | a1eb73e |
| `src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.css` | a1eb73e |
| `src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.html` | a1eb73e |
| `src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.ts` | a1eb73e |
| `src/app/features/not-found/not-found.routes.ts` | a1eb73e |
| `src/app/features/not-found/pages/not-found-page/not-found-page.css` | a1eb73e |
| `src/app/features/not-found/pages/not-found-page/not-found-page.html` | a1eb73e |
| `src/app/features/not-found/pages/not-found-page/not-found-page.ts` | a1eb73e |
| `src/app/features/profile/pages/profile-page/profile-page.css` | a1eb73e |
| `src/app/features/profile/pages/profile-page/profile-page.html` | a1eb73e |
| `src/app/features/profile/pages/profile-page/profile-page.ts` | a1eb73e |
| `src/app/features/profile/profile.routes.ts` | a1eb73e |
| `src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.css` | a1eb73e |
| `src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.html` | a1eb73e |
| `src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.ts` | a1eb73e |
| `src/app/features/unauthorized/unauthorized.routes.ts` | a1eb73e |

### Shared -- Components (50 files)

| File | SHA |
|------|-----|
| `src/app/shared/components/avatar/avatar.css` | a1eb73e |
| `src/app/shared/components/avatar/avatar.html` | a1eb73e |
| `src/app/shared/components/avatar/avatar.ts` | a1eb73e |
| `src/app/shared/components/badge/badge.html` | a1eb73e |
| `src/app/shared/components/badge/badge.ts` | a1eb73e |
| `src/app/shared/components/button/button.css` | a1eb73e |
| `src/app/shared/components/button/button.html` | a1eb73e |
| `src/app/shared/components/button/button.ts` | a1eb73e |
| `src/app/shared/components/callout/callout.css` | a1eb73e |
| `src/app/shared/components/callout/callout.html` | a1eb73e |
| `src/app/shared/components/callout/callout.ts` | a1eb73e |
| `src/app/shared/components/confirm-dialog/confirm-dialog.css` | a1eb73e |
| `src/app/shared/components/confirm-dialog/confirm-dialog.html` | a1eb73e |
| `src/app/shared/components/confirm-dialog/confirm-dialog.ts` | a1eb73e |
| `src/app/shared/components/empty-state/empty-state.css` | a1eb73e |
| `src/app/shared/components/empty-state/empty-state.html` | a1eb73e |
| `src/app/shared/components/empty-state/empty-state.ts` | a1eb73e |
| `src/app/shared/components/hero-banner/hero-banner.css` | a1eb73e |
| `src/app/shared/components/hero-banner/hero-banner.html` | a1eb73e |
| `src/app/shared/components/hero-banner/hero-banner.ts` | a1eb73e |
| `src/app/shared/components/image-picker/image-picker.css` | a1eb73e |
| `src/app/shared/components/image-picker/image-picker.html` | a1eb73e |
| `src/app/shared/components/image-picker/image-picker.ts` | a1eb73e |
| `src/app/shared/components/input/input.css` | a1eb73e |
| `src/app/shared/components/input/input.html` | a1eb73e |
| `src/app/shared/components/input/input.ts` | a1eb73e |
| `src/app/shared/components/modal/modal-footer.ts` | a1eb73e |
| `src/app/shared/components/modal/modal.css` | a1eb73e |
| `src/app/shared/components/modal/modal.html` | a1eb73e |
| `src/app/shared/components/modal/modal.ts` | a1eb73e |
| `src/app/shared/components/pagination/pagination.css` | a1eb73e |
| `src/app/shared/components/pagination/pagination.html` | a1eb73e |
| `src/app/shared/components/pagination/pagination.ts` | a1eb73e |
| `src/app/shared/components/photon-location-field/photon-location-field.css` | a1eb73e |
| `src/app/shared/components/photon-location-field/photon-location-field.html` | a1eb73e |
| `src/app/shared/components/photon-location-field/photon-location-field.ts` | a1eb73e |
| `src/app/shared/components/pizza-logo/pizza-logo.css` | a1eb73e |
| `src/app/shared/components/pizza-logo/pizza-logo.html` | a1eb73e |
| `src/app/shared/components/pizza-logo/pizza-logo.ts` | a1eb73e |
| `src/app/shared/components/spinner/spinner.css` | a1eb73e |
| `src/app/shared/components/spinner/spinner.html` | a1eb73e |
| `src/app/shared/components/spinner/spinner.ts` | a1eb73e |
| `src/app/shared/components/status-badge/status-badge.html` | a1eb73e |
| `src/app/shared/components/status-badge/status-badge.ts` | a1eb73e |
| `src/app/shared/components/textarea/textarea.css` | a1eb73e |
| `src/app/shared/components/textarea/textarea.html` | a1eb73e |
| `src/app/shared/components/textarea/textarea.ts` | a1eb73e |

Note: `badge/badge.css` was created here and renamed to `status-badge/status-badge.css`
in Phase 2; only the rename target is shown (in Phase 2). `badge/badge.html` and
`badge/badge.ts` remain listed here -- they were created in P1 and deleted in P2.

### Shared -- Directives / Pipes / Models (3 files)

| File | SHA |
|------|-----|
| `src/app/shared/directives/role.directive.ts` | a1eb73e |
| `src/app/shared/models/address.model.ts` | a1eb73e |
| `src/app/shared/pipes/catalog-image-url.pipe.ts` | a1eb73e |

### Tests (9 files)

| File | SHA |
|------|-----|
| `src/app/app.spec.ts` | a1eb73e |
| `src/app/core/guards/auth/auth.guard.spec.ts` | a1eb73e |
| `src/app/core/guards/checkout-deactivate/checkout-deactivate.guard.spec.ts` | a1eb73e |
| `src/app/core/guards/role/role.guard.spec.ts` | a1eb73e |
| `src/app/core/interceptors/credentials.interceptor.spec.ts` | a1eb73e |
| `src/app/core/services/auth.spec.ts` | a1eb73e |
| `src/app/core/services/photon-api.spec.ts` | a1eb73e |
| `src/app/features/cart/cart.store.spec.ts` | a1eb73e |
| `src/app/features/pizzerias/services/pizzeria-api.spec.ts` | a1eb73e |

Note: These 9 spec files were created during the initial scaffold, then all
deleted in Phase 2 (commit cdbf77a), and 8 of the 9 were re-created from
scratch in Phase 3. `app.spec.ts` was never re-created.

### Tooling (44 files)

| File | SHA |
|------|-----|
| `.agents/skills/angular-developer/SKILL.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/angular-animations.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/angular-aria.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/cli.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/component-harnesses.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/component-styling.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/components.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/creating-services.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/data-resolvers.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/define-routes.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/defining-providers.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/di-fundamentals.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/e2e-testing.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/effects.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/hierarchical-injectors.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/host-elements.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/injection-context.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/inputs.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/linked-signal.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/loading-strategies.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/mcp.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/navigate-to-routes.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/outputs.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/reactive-forms.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/rendering-strategies.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/resource.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/route-animations.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/route-guards.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/router-lifecycle.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/router-testing.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/show-routes-with-outlets.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/signal-forms.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/signals-overview.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/tailwind-css.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/template-driven-forms.md` | 072a8c6 |
| `.agents/skills/angular-developer/references/testing-fundamentals.md` | 072a8c6 |
| `.editorconfig` | 072a8c6 |
| `.github/workflows/ci.yml` | 072a8c6 |
| `.gitignore` | 072a8c6 |
| `.prettierrc` | 072a8c6 |
| `.vscode/extensions.json` | 072a8c6 |
| `.vscode/launch.json` | 072a8c6 |
| `.vscode/mcp.json` | 072a8c6 |
| `.vscode/tasks.json` | 072a8c6 |

---

## Phase 2: Core Architecture Refinement

**Date range:** May 17--18, 2026
**Commits:** bde53e1 through cdbf77a (36 commits)
**Summary:** Environment configuration, base URL interceptor, LICENSE, new admin-pizza-row component, Badge-to-StatusBadge CSS migration.

### Root / Config (3 files)

| File | SHA |
|------|-----|
| `LICENSE` | 7ee7518 |
| `src/environments/environment.development.ts` | 43a4c77 |
| `src/environments/environment.ts` | 43a4c77 |

### Core (2 files)

| File | SHA |
|------|-----|
| `src/app/core/interceptors/base-url.interceptor.ts` | 43a4c77 |
| `src/app/core/interceptors/base-url.interceptor.spec.ts` | 43a4c77 |

### Features -- Pizzerias (3 files)

| File | SHA |
|------|-----|
| `src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.css` | d90296c |
| `src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.html` | d90296c |
| `src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.ts` | d90296c |

### Shared -- Components (1 file)

| File | SHA |
|------|-----|
| `src/app/shared/components/status-badge/status-badge.css` | 4e53703 |

Note: Renamed from `badge/badge.css`. The Badge component's HTML and TS were
deleted in this phase (commit 4e53703), consolidating badge styling into
StatusBadge.

---

## Phase 3: Testing & Documentation

**Date range:** May 19--20, 2026
**Commits:** 771430c through 9795b46 (18 commits)
**Summary:** Comprehensive test suite added (45 new spec files), Prettier/Husky tooling, pnpm workspace configuration.

### Root / Config (1 file)

| File | SHA |
|------|-----|
| `pnpm-workspace.yaml` | 0828a53 |

### Tests (45 files)

| File | SHA |
|------|-----|
| `src/app/core/components/footer/footer.spec.ts` | 70dae9c |
| `src/app/core/components/header/header.spec.ts` | 70dae9c |
| `src/app/features/auth/pages/login-page/login-page.spec.ts` | 70dae9c |
| `src/app/features/auth/pages/register-page/register-page.spec.ts` | 70dae9c |
| `src/app/features/cart/pages/cart-page/cart-page.spec.ts` | 70dae9c |
| `src/app/features/checkout/guards/cart-not-empty.guard.spec.ts` | 70dae9c |
| `src/app/features/checkout/pages/checkout-page/checkout-page.spec.ts` | 70dae9c |
| `src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.spec.ts` | 70dae9c |
| `src/app/features/not-found/pages/not-found-page/not-found-page.spec.ts` | 70dae9c |
| `src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.spec.ts` | 70dae9c |
| `src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.spec.ts` | 70dae9c |
| `src/app/features/orders/order-api.spec.ts` | 70dae9c |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.spec.ts` | 70dae9c |
| `src/app/features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.spec.ts` | 70dae9c |
| `src/app/features/orders/pages/order-details-page/order-details-page.spec.ts` | 70dae9c |
| `src/app/features/orders/pages/order-list-page/order-list-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/guards/no-pizzeria.guard.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/pages/admin-pizzeria-form-page/admin-pizzeria-form-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.spec.ts` | 70dae9c |
| `src/app/features/pizzerias/services/pizza-api.spec.ts` | 70dae9c |
| `src/app/features/profile/pages/profile-page/profile-page.spec.ts` | 70dae9c |
| `src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.spec.ts` | 70dae9c |
| `src/app/shared/components/avatar/avatar.spec.ts` | 70dae9c |
| `src/app/shared/components/button/button.spec.ts` | 70dae9c |
| `src/app/shared/components/callout/callout.spec.ts` | 70dae9c |
| `src/app/shared/components/confirm-dialog/confirm-dialog.spec.ts` | 70dae9c |
| `src/app/shared/components/empty-state/empty-state.spec.ts` | 70dae9c |
| `src/app/shared/components/hero-banner/hero-banner.spec.ts` | 70dae9c |
| `src/app/shared/components/image-picker/image-picker.spec.ts` | 70dae9c |
| `src/app/shared/components/input/input.spec.ts` | 70dae9c |
| `src/app/shared/components/modal/modal.spec.ts` | 70dae9c |
| `src/app/shared/components/pagination/pagination.spec.ts` | 70dae9c |
| `src/app/shared/components/photon-location-field/photon-location-field.spec.ts` | 70dae9c |
| `src/app/shared/components/pizza-logo/pizza-logo.spec.ts` | 70dae9c |
| `src/app/shared/components/spinner/spinner.spec.ts` | 70dae9c |
| `src/app/shared/components/status-badge/status-badge.spec.ts` | 70dae9c |
| `src/app/shared/components/textarea/textarea.spec.ts` | 70dae9c |
| `src/app/shared/directives/role.directive.spec.ts` | 70dae9c |
| `src/app/shared/pipes/catalog-image-url.pipe.spec.ts` | 70dae9c |

Note: 8 spec files initially created in Phase 1 and deleted in Phase 2 were
re-created in this commit (`auth.guard.spec.ts`, `checkout-deactivate.guard.spec.ts`,
`role.guard.spec.ts`, `credentials.interceptor.spec.ts`, `auth.spec.ts`,
`photon-api.spec.ts`, `cart.store.spec.ts`, `pizzeria-api.spec.ts`). These are
not repeated here -- they were first introduced in Phase 1.

### Tooling (4 files)

| File | SHA |
|------|-----|
| `.husky/.gitignore` | debb2fd |
| `.husky/pre-commit` | debb2fd |
| `.prettierignore` | debb2fd |
| `.prettierrc.json` | debb2fd |

---

## Phase 4: Test Refactoring

**Date range:** May 20--22, 2026
**Commits:** 293373a through 70725e2 (7 commits)
**Summary:** No new files -- all commits were modifications to existing spec files
and components. This phase refined tests for change detection, type safety,
and replaced mock components with real implementations.

**New file count: 0**

---

## Phase 5: Feature Enhancements

**Date range:** May 22 -- June 5, 2026
**Commits:** bd72c32 through 3322c2d (15 commits)
**Summary:** Load-more pagination component, multi-step checkout wizard
(delivery, progress stepper, review, schedule steps), checkout step guard,
checkout wizard service, coupon code support, sync SVG icon.

### Public Assets (1 file)

| File | SHA |
|------|-----|
| `public/icons/sync.svg` | bba14ca |

### Features -- Checkout (20 files)

| File | SHA |
|------|-----|
| `src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.css` | b7f434b |
| `src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.html` | b7f434b |
| `src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.spec.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.css` | b7f434b |
| `src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.html` | b7f434b |
| `src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.spec.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-review-step/checkout-review-step.css` | b7f434b |
| `src/app/features/checkout/components/checkout-review-step/checkout-review-step.html` | b7f434b |
| `src/app/features/checkout/components/checkout-review-step/checkout-review-step.spec.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-review-step/checkout-review-step.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.css` | b7f434b |
| `src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.html` | b7f434b |
| `src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.spec.ts` | b7f434b |
| `src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.ts` | b7f434b |
| `src/app/features/checkout/guards/checkout-step.guard.spec.ts` | b7f434b |
| `src/app/features/checkout/guards/checkout-step.guard.ts` | b7f434b |
| `src/app/features/checkout/services/checkout-wizard.spec.ts` | b7f434b |
| `src/app/features/checkout/services/checkout-wizard.ts` | b7f434b |

### Shared -- Components (4 files)

| File | SHA |
|------|-----|
| `src/app/shared/components/load-more/load-more.css` | bd72c32 |
| `src/app/shared/components/load-more/load-more.html` | bd72c32 |
| `src/app/shared/components/load-more/load-more.spec.ts` | bd72c32 |
| `src/app/shared/components/load-more/load-more.ts` | bd72c32 |

---

## Summary Table: New Files per Phase by Layer

| Layer | P1 | P2 | P3 | P4 | P5 | Total |
|-------|----|----|----|----|----|-------|
| Root / Config | 16 | 3 | 1 | 0 | 0 | **20** |
| Public Assets | 40 | 0 | 0 | 0 | 1 | **41** |
| Core | 18 | 2 | 0 | 0 | 0 | **20** |
| Features -- Auth | 8 | 0 | 0 | 0 | 0 | **8** |
| Features -- Cart | 5 | 0 | 0 | 0 | 0 | **5** |
| Features -- Checkout | 5 | 0 | 0 | 0 | 20 | **25** |
| Features -- Orders | 20 | 0 | 0 | 0 | 0 | **20** |
| Features -- Pizzerias | 30 | 3 | 0 | 0 | 0 | **33** |
| Features -- Other | 16 | 0 | 0 | 0 | 0 | **16** |
| Shared -- Components | 50 | 1 | 0 | 0 | 4 | **55** |
| Shared -- Directives / Pipes / Models | 3 | 0 | 0 | 0 | 0 | **3** |
| Tests | 9 | 0 | 45 | 0 | 0 | **54** |
| Tooling | 44 | 0 | 4 | 0 | 0 | **48** |
| **Total** | **264** | **9** | **50** | **0** | **25** | **348** |

---

## Key Observations

1. **Phase 1 was the heavy lift.** 264 files (76% of the total codebase) were
   introduced in the first 15 commits over roughly 17 hours. Nearly all feature,
   shared, and infrastructure code was laid down in this initial burst, including
   30 files for the Pizzerias feature alone.

2. **Test-first-then-delete-then-rewrite.** Nine spec files were created in the
   init commit, deleted en masse in Phase 2 (commit cdbf77a), and then 8 of them
   re-created from scratch in Phase 3. `app.spec.ts` was the only spec that was
   never re-created. This suggests a deliberate decision to discard the initial
   test scaffolding and start over with a different testing approach in Phase 3.

3. **Phase 2 was about infrastructure, not features.** Only 9 new files:
   environment configuration, a base URL interceptor, the `admin-pizza-row`
   component, a LICENSE file, and the Badge-to-StatusBadge CSS rename. The
   phase's 36 commits were almost entirely modifications to existing code.

4. **All testing arrived in Phase 3.** 45 brand-new spec files were added in
   commit 70dae9c, covering every component, guard, interceptor, service, page,
   directive, and pipe in the codebase. Combined with the 8 re-created specs
   from Phase 1, the total test suite at this point reached 53 spec files.

5. **Phase 4 was a refinement phase with zero new files.** Seven commits of pure
   refactoring on existing tests and components -- replacing mocks with real
   implementations, improving type safety, and cleaning up imports.

6. **Phase 5 was checkout-focused.** Of its 25 new files, 20 (80%) were in the
   Checkout feature: a multi-step wizard with four step components, a step guard,
   and a wizard service. The other 5 were the `load-more` shared component and
   one new SVG icon.

7. **The Checkout feature grew the most after Phase 1.** It started with 5 files
   (a simple single-page checkout) and expanded to 25 files with the wizard
   architecture in Phase 5, making it the second-largest feature module by file
   count after Pizzerias.

8. **The Tooling layer was front-loaded.** 44 of 48 tooling files (92%) were
   introduced in Phase 1 (mostly `.agents/skills/` references and `.vscode/`
   config). Only `.husky/` and `.prettier*` were added later in Phase 3.

9. **Shared components were built up-front.** All 50 shared component source
   files were created in Phase 1. Only the `load-more` component (4 files) and
   the StatusBadge CSS migration (1 file) were added later, making the shared
   layer remarkably stable from the beginning.

10. **The construction order follows a distinct pattern:** full-stack scaffold
    (P1) -> architecture hardening (P2) -> comprehensive testing (P3) -> test
    quality refinement (P4) -> feature enhancement with new capabilities (P5).
