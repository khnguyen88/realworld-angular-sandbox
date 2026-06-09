# Realworld Angular - Commit-by-Commit Deep Dive

This document is Appendix A referenced in `README-SYSTEM-DESIGN.md`. It provides
a complete chronological listing of all 91 commits in the realworld-angular
project, reconstructed from the upstream repository's git history.

Source: `commit-log.txt` (generated from upstream `git log`).

---

## Commit Summary Table

| #   | SHA     | Date       | Message                                                                                                                       | Files         |
| --- | ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------- |
| 1   | a1eb73e | 2026-05-14 | init                                                                                                                          | A:169         |
| 2   | 072a8c6 | 2026-05-14 | Update API endpoints for pizzeria management to standardize route paths                                                       | A:48          |
| 3   | 9bade76 | 2026-05-14 | Add noPizzeriaGuard to manage access based on pizzeria existence                                                              | R:1 M:1       |
| 4   | b69db9f | 2026-05-14 | Add admin pizzeria form page with routing and styling                                                                         | R:3 M:1       |
| 5   | 1ecf2a3 | 2026-05-15 | Enhance checkout flow and clean up code                                                                                       | M:8 A:1 D:1   |
| 6   | 17565f4 | 2026-05-15 | Remove postRegisterRedirect from auth routes and register page, simplifying navigation logic for pizzeria owner registration. | M:2           |
| 7   | 157f436 | 2026-05-15 | Remove unused import from login-page component to streamline code and improve clarity.                                        | M:1           |
| 8   | a6d584d | 2026-05-15 | Update README and app configuration for improved functionality                                                                | M:2           |
| 9   | 489895d | 2026-05-15 | Update README to remove outdated checklist item                                                                               | M:1           |
| 10  | cf005d0 | 2026-05-15 | Style update for password visibility toggle on login and register pages                                                       | M:2           |
| 11  | 8f7148f | 2026-05-15 | Enhance password visibility toggle functionality on login and register pages                                                  | M:2           |
| 12  | 2f47ea5 | 2026-05-15 | Update README to reflect current project tasks and remove outdated items                                                      | M:1           |
| 13  | b08df5c | 2026-05-15 | Update Angular configuration and HTML for enhanced security and clarity                                                       | M:3           |
| 14  | 95ffec9 | 2026-05-15 | Remove Content Security Policy meta tag from index.html for simplification                                                    | M:1           |
| 15  | c281624 | 2026-05-15 | Refactor cart management and enhance cart reconstruction logic                                                                | M:10          |
| 16  | bde53e1 | 2026-05-17 | Update pizzeria details page to modify image source format                                                                    | M:1           |
| 17  | 08317f7 | 2026-05-17 | Remove pizza image file from public assets                                                                                    | D:1           |
| 18  | 0b950b3 | 2026-05-17 | Add full-width button class to login link on cart page                                                                        | M:1           |
| 19  | dfd03e7 | 2026-05-17 | Update footer link to direct users to GitHub Sponsors for project support                                                     | M:1           |
| 20  | 1f623fe | 2026-05-17 | Refactor pizzeria admin routes and links for consistency                                                                      | M:9           |
| 21  | fd7f4dd | 2026-05-17 | Remove Orders tab from pizzeria admin details page for streamlined navigation                                                 | M:1           |
| 22  | 43a4c77 | 2026-05-18 | Implement base URL interceptor for API requests and update environment configurations                                         | M:2 D:1 A:4   |
| 23  | 6367050 | 2026-05-18 | Enhance base URL interceptor to include image requests                                                                        | M:1           |
| 24  | cd435fb | 2026-05-18 | Remove proxy configuration from Angular serve options in angular.json                                                         | M:1           |
| 25  | 1f7eb63 | 2026-05-18 | Update Angular dependencies in pnpm-lock.yaml to latest versions                                                              | M:1           |
| 26  | 3199805 | 2026-05-18 | Refactor base URL handling in interceptor and image URL pipe                                                                  | M:2           |
| 27  | 7ee7518 | 2026-05-18 | Add MIT License to the project                                                                                                | A:1           |
| 28  | 2c4dfbf | 2026-05-18 | Refactor order status handling in order details page                                                                          | M:2           |
| 29  | bca0306 | 2026-05-18 | Enhance routing titles and page title management across the application                                                       | M:12          |
| 30  | 31a691b | 2026-05-18 | Refactor order row event handling and feedback display                                                                        | M:5           |
| 31  | 552299f | 2026-05-18 | Refactor pizzeria API service methods                                                                                         | M:1           |
| 32  | edbca41 | 2026-05-18 | Refactor pizzeria details page layout and button integration                                                                  | M:3           |
| 33  | 9622b8e | 2026-05-18 | Refactor navigation handling in authentication and checkout pages                                                             | M:4           |
| 34  | a34ed14 | 2026-05-18 | Enhance pizzeria details page event handling with takeUntilDestroyed                                                          | M:1           |
| 35  | 6dfdac0 | 2026-05-18 | Integrate DestroyRef and takeUntilDestroyed for improved subscription management in admin pizza list page                     | M:1           |
| 36  | 7166c62 | 2026-05-18 | Update profile route to use canMatch for authentication guard                                                                 | M:1           |
| 37  | b962582 | 2026-05-18 | Refactor confirm dialog imports for cleaner code structure                                                                    | M:1           |
| 38  | 21d74dd | 2026-05-18 | Fix typo in styleUrls property in admin pizza form dialog component                                                           | M:1           |
| 39  | 4e53703 | 2026-05-18 | Remove Badge component and integrate styles into StatusBadge for improved design consistency                                  | D:2 R:1 M:2   |
| 40  | 700957e | 2026-05-18 | Refactor Callout component structure for improved clarity and maintainability                                                 | M:2           |
| 41  | 7cf6ccc | 2026-05-18 | Refactor EmptyState component to streamline message handling                                                                  | M:2           |
| 42  | bb9d261 | 2026-05-18 | Refactor image picker component to improve category handling                                                                  | M:1           |
| 43  | bfeb289 | 2026-05-18 | Refactor form components to enhance accessibility and code clarity                                                            | M:11          |
| 44  | d94e072 | 2026-05-18 | Refactor PhotonLocationField component for improved functionality and accessibility                                           | M:2           |
| 45  | 4235429 | 2026-05-18 | Refactor PizzeriaDetailsPage to improve banner visibility management                                                          | M:1           |
| 46  | 396cfd7 | 2026-05-18 | Refactor AdminPizzeriaConfigurationPage for improved delete functionality and code clarity                                    | M:2           |
| 47  | d90296c | 2026-05-18 | Add AdminPizzaRow component for enhanced pizza management functionality                                                       | A:3 M:3       |
| 48  | dd7eebd | 2026-05-18 | Refactor AdminPizzaFormDialog to utilize httpResource for toppings management                                                 | M:3           |
| 49  | db82d83 | 2026-05-19 | Enhance Pizza Order Form Dialog with loading and error states for toppings                                                    | M:7           |
| 50  | 61bdfc7 | 2026-05-19 | Refactor Pizza API methods for consistency and clarity                                                                        | M:7           |
| 51  | cdbf77a | 2026-05-19 | Remove obsolete spec files for various components and services                                                                | D:10          |
| 52  | 771430c | 2026-05-19 | Refactor CartStore and related components for improved naming and functionality                                               | M:9           |
| 53  | 76ec4cc | 2026-05-19 | Refactor CartStore to utilize httpResource for cart management                                                                | M:1           |
| 54  | 70dae9c | 2026-05-19 | Add unit tests for core components and services                                                                               | A:54 M:7      |
| 55  | 922d723 | 2026-05-19 | Update image handling in components to use ngSrc for optimized loading                                                        | M:17          |
| 56  | eb25082 | 2026-05-19 | Remove redundant text from terms and conditions page for clarity                                                              | M:1           |
| 57  | 02b8d04 | 2026-05-19 | Add FAQ section to terms and conditions page for clarity                                                                      | M:1           |
| 58  | 944d810 | 2026-05-19 | Update README.md to clarify project purpose and features                                                                      | M:1           |
| 59  | 2114d67 | 2026-05-19 | Update environment configuration for development                                                                              | M:1           |
| 60  | cd764d5 | 2026-05-19 | Remove unnecessary comment from environment.development.ts                                                                    | M:1           |
| 61  | f385a09 | 2026-05-19 | Update README.md to reflect project name change and enhance clarity                                                           | M:1           |
| 62  | 49de7ab | 2026-05-19 | Enhance README.md with contribution guidelines and project scope clarification                                                | M:1           |
| 63  | e2ac29a | 2026-05-19 | Update README.md to include API documentation link                                                                            | M:1           |
| 64  | debb2fd | 2026-05-19 | chore: prettify                                                                                                               | M:150 A:4     |
| 65  | e267022 | 2026-05-19 | chore: add husky for improved Git hooks management                                                                            | M:2           |
| 66  | 5df43a6 | 2026-05-19 | chore: remove packageManager field from package.json                                                                          | M:1           |
| 67  | 0828a53 | 2026-05-19 | chore: add pnpm workspace configuration for build permissions                                                                 | A:1           |
| 68  | 0f8aff4 | 2026-05-20 | chore: simplify test command in CI workflow                                                                                   | M:1           |
| 69  | 9795b46 | 2026-05-20 | chore: linting                                                                                                                | M:11          |
| 70  | 293373a | 2026-05-20 | refactor: update tests and enhance pizzeria details page                                                                      | M:7           |
| 71  | ba04b9d | 2026-05-21 | test: refactor unit tests for guards and components                                                                           | M:16          |
| 72  | 26e0388 | 2026-05-21 | refactor: update component tests for change detection and type safety                                                         | M:17          |
| 73  | 6cdda60 | 2026-05-21 | refactor: enhance test structure and formatting across components                                                             | M:13          |
| 74  | 0d66ee7 | 2026-05-21 | refactor: replace mock components with actual implementations in tests                                                        | M:6           |
| 75  | ca63022 | 2026-05-21 | refactor: remove standalone flag from mock components in tests                                                                | M:3           |
| 76  | 70725e2 | 2026-05-21 | refactor: clean up imports in pizza order form dialog tests                                                                   | M:1           |
| 77  | bd72c32 | 2026-05-23 | refactor: enhance pizzeria details page with pagination and loading states                                                    | M:3 A:4       |
| 78  | b7f434b | 2026-05-26 | refactor: enhance checkout flow with new components and guards                                                                | M:13 D:2 A:18 |
| 79  | 77c09fc | 2026-05-26 | feat: add email availability validation to registration form                                                                  | M:1           |
| 80  | 2c91bea | 2026-05-26 | refactor: linting                                                                                                             | M:4           |
| 81  | 2a1e52a | 2026-06-01 | chore: specify Node.js engine versions in package.json                                                                        | M:1           |
| 82  | fdd7553 | 2026-06-01 | refactor: update checkout progress stepper to use switch statement                                                            | M:1           |
| 83  | 81abd79 | 2026-06-03 | fix: update user profile link accessibility                                                                                   | M:1           |
| 84  | 7d23826 | 2026-06-03 | feat: add coupon code functionality to checkout review step                                                                   | M:13          |
| 85  | f3f1700 | 2026-06-03 | chore: update Angular dependencies and TypeScript version                                                                     | M:3           |
| 86  | 8fa08a5 | 2026-06-05 | feat: add footer placeholder and defer loading for footer component                                                           | M:2           |
| 87  | ecd87f8 | 2026-06-05 | feat: add debounce to coupon code validation in checkout wizard                                                               | M:1           |
| 88  | d5a7229 | 2026-06-05 | fix: handle discount reset on coupon validation error                                                                         | M:2           |
| 89  | 059e7fc | 2026-06-05 | fix: improve error handling in login and registration forms                                                                   | M:2           |
| 90  | bba14ca | 2026-06-05 | feat: add sync icon SVG to public icons directory                                                                             | A:1           |
| 91  | 3322c2d | 2026-06-05 | feat: enhance coupon code functionality in checkout review step                                                               | M:5           |

---

## Detailed File Listings for Commits That Added New Files

The following sections list the actual filenames for every commit that created
at least one new file. These represent points where new code or assets entered the
codebase.

### Commit 1: a1eb73e (169 files added)

```
README.md
angular.json
eslint.config.js
package.json
pnpm-lock.yaml
proxy.conf.json
public/favicon.ico
public/favicon.png
public/favicon.svg
public/icons/add.svg
public/icons/bookmark-check.svg
public/icons/bookmark.svg
public/icons/cancel.svg
public/icons/check.svg
public/icons/chevron-left.svg
public/icons/chevron-right.svg
public/icons/close.svg
public/icons/content-copy.svg
public/icons/delete.svg
public/icons/delivery.svg
public/icons/edit.svg
public/icons/empty-shopping-cart.svg
public/icons/error.svg
public/icons/external-link.svg
public/icons/folder-off.svg
public/icons/location-off.svg
public/icons/menu.svg
public/icons/person-add.svg
public/icons/person-cancel.svg
public/icons/person-off.svg
public/icons/remove.svg
public/icons/search.svg
public/icons/shopping-cart.svg
public/icons/success.svg
public/icons/visibility-off.svg
public/icons/visibility.svg
public/images/pizza.jpg
public/images/pizzas/pizza-1.jpg
public/images/pizzas/pizza.jpg
public/images/pizzas/pizza.png
public/images/pizzeria.jpg
public/images/pizzerias/pizzeria-1.jpg
public/images/pizzerias/pizzeria.png
public/images/realworld-angular-banner.png
public/light-logo.gif
public/light-logo.svg
skills-lock.json
src/app/app.config.ts
src/app/app.css
src/app/app.html
src/app/app.routes.ts
src/app/app.spec.ts
src/app/app.ts
src/app/core/components/footer/footer.css
src/app/core/components/footer/footer.html
src/app/core/components/footer/footer.ts
src/app/core/components/header/header.css
src/app/core/components/header/header.html
src/app/core/components/header/header.ts
src/app/core/guards/auth/auth.guard.spec.ts
src/app/core/guards/auth/auth.guard.ts
src/app/core/guards/checkout-deactivate/checkout-deactivate.guard.spec.ts
src/app/core/guards/checkout-deactivate/checkout-deactivate.guard.ts
src/app/core/guards/pizzeria/no-pizzeria.guard.ts
src/app/core/guards/role/role.guard.spec.ts
src/app/core/guards/role/role.guard.ts
src/app/core/interceptors/credentials.interceptor.spec.ts
src/app/core/interceptors/credentials.interceptor.ts
src/app/core/models/pagination.model.ts
src/app/core/models/user.model.ts
src/app/core/services/auth.spec.ts
src/app/core/services/auth.ts
src/app/core/services/photon-api.spec.ts
src/app/core/services/photon-api.ts
src/app/features/auth/auth.routes.ts
src/app/features/auth/pages/login-page/login-page.css
src/app/features/auth/pages/login-page/login-page.html
src/app/features/auth/pages/login-page/login-page.ts
src/app/features/auth/pages/register-page/register-page.css
src/app/features/auth/pages/register-page/register-page.html
src/app/features/auth/pages/register-page/register-page.ts
src/app/features/auth/role.model.ts
src/app/features/cart/cart.routes.ts
src/app/features/cart/cart.store.spec.ts
src/app/features/cart/cart.store.ts
src/app/features/cart/pages/cart-page/cart-page.css
src/app/features/cart/pages/cart-page/cart-page.html
src/app/features/cart/pages/cart-page/cart-page.ts
src/app/features/checkout/checkout.routes.ts
src/app/features/checkout/pages/checkout-page/checkout-page.css
src/app/features/checkout/pages/checkout-page/checkout-page.html
src/app/features/checkout/pages/checkout-page/checkout-page.ts
src/app/features/legal/legal.routes.ts
src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.css
src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.html
src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.ts
src/app/features/not-found/not-found.routes.ts
src/app/features/not-found/pages/not-found-page/not-found-page.css
src/app/features/not-found/pages/not-found-page/not-found-page.html
src/app/features/not-found/pages/not-found-page/not-found-page.ts
src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.css
src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.html
src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.ts
src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.css
src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.html
src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.ts
src/app/features/orders/order-api.ts
src/app/features/orders/order.models.ts
src/app/features/orders/order.routes.ts
src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.css
src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.html
src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.ts
src/app/features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.html
src/app/features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.ts
src/app/features/orders/pages/order-details-page/order-details-page.css
src/app/features/orders/pages/order-details-page/order-details-page.html
src/app/features/orders/pages/order-details-page/order-details-page.ts
src/app/features/orders/pages/order-list-page/order-list-page.css
src/app/features/orders/pages/order-list-page/order-list-page.html
src/app/features/orders/pages/order-list-page/order-list-page.ts
src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.css
src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.html
src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.ts
src/app/features/pizzerias/models/pizza.models.ts
src/app/features/pizzerias/models/pizzeria.models.ts
src/app/features/pizzerias/models/staff.models.ts
src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.css
src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.html
src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.ts
src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.css
src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.html
src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.ts
src/app/features/pizzerias/pages/admin-pizzeria-configuration/admin-pizzeria-configuration-page.html
src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.css
src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.html
src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.ts
src/app/features/pizzerias/pages/admin-pizzeria-new-page/admin-pizzeria-new-page.css
src/app/features/pizzerias/pages/admin-pizzeria-new-page/admin-pizzeria-new-page.html
src/app/features/pizzerias/pages/admin-pizzeria-new-page/admin-pizzeria-new-page.ts
src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.css
src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.html
src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.ts
src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.css
src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.html
src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.ts
src/app/features/pizzerias/pizzeria.routes.ts
src/app/features/pizzerias/services/pizza-api.ts
src/app/features/pizzerias/services/pizzeria-api.spec.ts
src/app/features/pizzerias/services/pizzeria-api.ts
src/app/features/profile/pages/profile-page/profile-page.css
src/app/features/profile/pages/profile-page/profile-page.html
src/app/features/profile/pages/profile-page/profile-page.ts
src/app/features/profile/profile.routes.ts
src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.css
src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.html
src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.ts
src/app/features/unauthorized/unauthorized.routes.ts
src/app/shared/components/avatar/avatar.css
src/app/shared/components/avatar/avatar.html
src/app/shared/components/avatar/avatar.ts
src/app/shared/components/badge/badge.css
src/app/shared/components/badge/badge.html
src/app/shared/components/badge/badge.ts
src/app/shared/components/button/button.css
src/app/shared/components/button/button.html
src/app/shared/components/button/button.ts
src/app/shared/components/callout/callout.css
src/app/shared/components/callout/callout.html
src/app/shared/components/callout/callout.ts
src/app/shared/components/confirm-dialog/confirm-dialog.css
src/app/shared/components/confirm-dialog/confirm-dialog.html
src/app/shared/components/confirm-dialog/confirm-dialog.ts
src/app/shared/components/empty-state/empty-state.css
src/app/shared/components/empty-state/empty-state.html
src/app/shared/components/empty-state/empty-state.ts
src/app/shared/components/hero-banner/hero-banner.css
src/app/shared/components/hero-banner/hero-banner.html
src/app/shared/components/hero-banner/hero-banner.ts
src/app/shared/components/image-picker/image-picker.css
src/app/shared/components/image-picker/image-picker.html
src/app/shared/components/image-picker/image-picker.ts
src/app/shared/components/input/input.css
src/app/shared/components/input/input.html
src/app/shared/components/input/input.ts
src/app/shared/components/modal/modal-footer.ts
src/app/shared/components/modal/modal.css
src/app/shared/components/modal/modal.html
src/app/shared/components/modal/modal.ts
src/app/shared/components/pagination/pagination.css
src/app/shared/components/pagination/pagination.html
src/app/shared/components/pagination/pagination.ts
src/app/shared/components/photon-location-field/photon-location-field.css
src/app/shared/components/photon-location-field/photon-location-field.html
src/app/shared/components/photon-location-field/photon-location-field.ts
src/app/shared/components/pizza-logo/pizza-logo.css
src/app/shared/components/pizza-logo/pizza-logo.html
src/app/shared/components/pizza-logo/pizza-logo.ts
src/app/shared/components/spinner/spinner.css
src/app/shared/components/spinner/spinner.html
src/app/shared/components/spinner/spinner.ts
src/app/shared/components/status-badge/status-badge.html
src/app/shared/components/status-badge/status-badge.ts
src/app/shared/components/textarea/textarea.css
src/app/shared/components/textarea/textarea.html
src/app/shared/components/textarea/textarea.ts
src/app/shared/directives/role.directive.ts
src/app/shared/models/address.model.ts
src/app/shared/pipes/catalog-image-url.pipe.ts
src/index.html
src/main.ts
src/styles.css
src/styles/components/input.css
src/styles/design-system/_reset.css
src/styles/design-system/_tokens.css
tsconfig.app.json
tsconfig.json
tsconfig.spec.json
```

### Commit 2: 072a8c6 (48 files added)

```
.agents/skills/angular-developer/SKILL.md
.agents/skills/angular-developer/references/angular-animations.md
.agents/skills/angular-developer/references/angular-aria.md
.agents/skills/angular-developer/references/cli.md
.agents/skills/angular-developer/references/component-harnesses.md
.agents/skills/angular-developer/references/component-styling.md
.agents/skills/angular-developer/references/components.md
.agents/skills/angular-developer/references/creating-services.md
.agents/skills/angular-developer/references/data-resolvers.md
.agents/skills/angular-developer/references/define-routes.md
.agents/skills/angular-developer/references/defining-providers.md
.agents/skills/angular-developer/references/di-fundamentals.md
.agents/skills/angular-developer/references/e2e-testing.md
.agents/skills/angular-developer/references/effects.md
.agents/skills/angular-developer/references/hierarchical-injectors.md
.agents/skills/angular-developer/references/host-elements.md
.agents/skills/angular-developer/references/injection-context.md
.agents/skills/angular-developer/references/inputs.md
.agents/skills/angular-developer/references/linked-signal.md
.agents/skills/angular-developer/references/loading-strategies.md
.agents/skills/angular-developer/references/mcp.md
.agents/skills/angular-developer/references/navigate-to-routes.md
.agents/skills/angular-developer/references/outputs.md
.agents/skills/angular-developer/references/reactive-forms.md
.agents/skills/angular-developer/references/rendering-strategies.md
.agents/skills/angular-developer/references/resource.md
.agents/skills/angular-developer/references/route-animations.md
.agents/skills/angular-developer/references/route-guards.md
.agents/skills/angular-developer/references/router-lifecycle.md
.agents/skills/angular-developer/references/router-testing.md
.agents/skills/angular-developer/references/show-routes-with-outlets.md
.agents/skills/angular-developer/references/signal-forms.md
.agents/skills/angular-developer/references/signals-overview.md
.agents/skills/angular-developer/references/tailwind-css.md
.agents/skills/angular-developer/references/template-driven-forms.md
.agents/skills/angular-developer/references/testing-fundamentals.md
.editorconfig
.github/workflows/ci.yml
.gitignore
.prettierrc
.vscode/extensions.json
.vscode/launch.json
.vscode/mcp.json
.vscode/tasks.json
```

### Commit 5: 1ecf2a3 (1 file added)

```
src/app/features/checkout/guards/cart-not-empty.guard.ts
```

### Commit 22: 43a4c77 (4 files added)

```
src/app/core/interceptors/base-url.interceptor.spec.ts
src/app/core/interceptors/base-url.interceptor.ts
src/environments/environment.development.ts
src/environments/environment.ts
```

### Commit 27: 7ee7518 (1 file added)

```
LICENSE
```

### Commit 47: d90296c (3 files added)

```
src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.css
src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.html
src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.ts
```

### Commit 54: 70dae9c (54 files added)

```
src/app/core/components/footer/footer.spec.ts
src/app/core/components/header/header.spec.ts
src/app/core/guards/auth/auth.guard.spec.ts
src/app/core/guards/checkout-deactivate/checkout-deactivate.guard.spec.ts
src/app/core/guards/role/role.guard.spec.ts
src/app/core/interceptors/base-url.interceptor.spec.ts
src/app/core/interceptors/credentials.interceptor.spec.ts
src/app/core/services/auth.spec.ts
src/app/core/services/photon-api.spec.ts
src/app/features/auth/pages/login-page/login-page.spec.ts
src/app/features/auth/pages/register-page/register-page.spec.ts
src/app/features/cart/cart.store.spec.ts
src/app/features/cart/pages/cart-page/cart-page.spec.ts
src/app/features/checkout/guards/cart-not-empty.guard.spec.ts
src/app/features/checkout/pages/checkout-page/checkout-page.spec.ts
src/app/features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.spec.ts
src/app/features/not-found/pages/not-found-page/not-found-page.spec.ts
src/app/features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.spec.ts
src/app/features/orders/components/pizza-size-option-field/pizza-size-option-field.spec.ts
src/app/features/orders/order-api.spec.ts
src/app/features/orders/pages/admin-order-list-page/admin-order-list-page.spec.ts
src/app/features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.spec.ts
src/app/features/orders/pages/order-details-page/order-details-page.spec.ts
src/app/features/orders/pages/order-list-page/order-list-page.spec.ts
src/app/features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.spec.ts
src/app/features/pizzerias/components/admin-pizza-row/admin-pizza-row.spec.ts
src/app/features/pizzerias/guards/no-pizzeria.guard.spec.ts
src/app/features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.spec.ts
src/app/features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.spec.ts
src/app/features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.spec.ts
src/app/features/pizzerias/pages/admin-pizzeria-form-page/admin-pizzeria-form-page.spec.ts
src/app/features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.spec.ts
src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.spec.ts
src/app/features/pizzerias/services/pizza-api.spec.ts
src/app/features/pizzerias/services/pizzeria-api.spec.ts
src/app/features/profile/pages/profile-page/profile-page.spec.ts
src/app/features/unauthorized/pages/unauthorized-page/unauthorized-page.spec.ts
src/app/shared/components/avatar/avatar.spec.ts
src/app/shared/components/button/button.spec.ts
src/app/shared/components/callout/callout.spec.ts
src/app/shared/components/confirm-dialog/confirm-dialog.spec.ts
src/app/shared/components/empty-state/empty-state.spec.ts
src/app/shared/components/hero-banner/hero-banner.spec.ts
src/app/shared/components/image-picker/image-picker.spec.ts
src/app/shared/components/input/input.spec.ts
src/app/shared/components/modal/modal.spec.ts
src/app/shared/components/pagination/pagination.spec.ts
src/app/shared/components/photon-location-field/photon-location-field.spec.ts
src/app/shared/components/pizza-logo/pizza-logo.spec.ts
src/app/shared/components/spinner/spinner.spec.ts
src/app/shared/components/status-badge/status-badge.spec.ts
src/app/shared/components/textarea/textarea.spec.ts
src/app/shared/directives/role.directive.spec.ts
src/app/shared/pipes/catalog-image-url.pipe.spec.ts
```

### Commit 64: debb2fd (4 files added)

```
.husky/.gitignore
.husky/pre-commit
.prettierignore
.prettierrc.json
```

### Commit 67: 0828a53 (1 file added)

```
pnpm-workspace.yaml
```

### Commit 77: bd72c32 (4 files added)

```
src/app/shared/components/load-more/load-more.css
src/app/shared/components/load-more/load-more.html
src/app/shared/components/load-more/load-more.spec.ts
src/app/shared/components/load-more/load-more.ts
```

### Commit 78: b7f434b (18 files added)

```
src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.css
src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.html
src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.spec.ts
src/app/features/checkout/components/checkout-delivery-step/checkout-delivery-step.ts
src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.css
src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.html
src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.spec.ts
src/app/features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.ts
src/app/features/checkout/components/checkout-review-step/checkout-review-step.css
src/app/features/checkout/components/checkout-review-step/checkout-review-step.html
src/app/features/checkout/components/checkout-review-step/checkout-review-step.spec.ts
src/app/features/checkout/components/checkout-review-step/checkout-review-step.ts
src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.css
src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.html
src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.spec.ts
src/app/features/checkout/components/checkout-schedule-step/checkout-schedule-step.ts
src/app/features/checkout/guards/checkout-step.guard.spec.ts
src/app/features/checkout/guards/checkout-step.guard.ts
```

### Commit 90: bba14ca (1 file added)

```
public/icons/sync.svg
```

---

## Stats

| Metric                                    | Value                              |
| ----------------------------------------- | ---------------------------------- |
| Total commits                             | 91                                 |
| Total files added across all commits      | 308                                |
| Most active day (by commit count)         | 2026-05-18 (27 commits)            |
| Most files in a single commit             | 169 (commit 1, a1eb73e: "init")    |
| Date range                                | 2026-05-14 to 2026-06-05 (23 days) |
| Commits that created new files            | 12                                 |
| Commits that only modified existing files | 72                                 |
| Commits that only deleted files           | 1                                  |
| Commits that included renames             | 3                                  |

### Files Added Per Commit (descending)

| SHA     | Message                                                                               | Files Added |
| ------- | ------------------------------------------------------------------------------------- | ----------- |
| a1eb73e | init                                                                                  | 169         |
| 70dae9c | Add unit tests for core components and services                                       | 54          |
| 072a8c6 | Update API endpoints for pizzeria management to standardize route paths               | 48          |
| b7f434b | refactor: enhance checkout flow with new components and guards                        | 18          |
| 43a4c77 | Implement base URL interceptor for API requests and update environment configurations | 4           |
| debb2fd | chore: prettify                                                                       | 4           |
| bd72c32 | refactor: enhance pizzeria details page with pagination and loading states            | 4           |
| d90296c | Add AdminPizzaRow component for enhanced pizza management functionality               | 3           |
| 1ecf2a3 | Enhance checkout flow and clean up code                                               | 1           |
| 7ee7518 | Add MIT License to the project                                                        | 1           |
| 0828a53 | chore: add pnpm workspace configuration for build permissions                         | 1           |
| bba14ca | feat: add sync icon SVG to public icons directory                                     | 1           |
