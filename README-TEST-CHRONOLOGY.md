# Test Chronology — Creation Order & Evolution

> **Data source:** `realworld-angular/` git history (upstream [realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular))
> **Generated:** 2026-06-08

---

## Quick Reference

| Phase  | Date          | Time (Local) | Commit                                   | Action                                                       | Specs |
| ------ | ------------- | ------------ | ---------------------------------------- | ------------------------------------------------------------ | ----- |
| **1**  | 2026-05-14    | 23:12 CEST   | `a1eb73e` — init                         | Created 9 skeleton specs                                     | +9    |
| **2**  | 2026-05-18    | 00:57 CEST   | `43a4c77` — base URL interceptor         | Added 1 interceptor spec amid implementation work            | +1    |
| **3a** | 2026-05-19    | 01:52 CEST   | `cdbf77a` — remove obsolete specs        | **Deleted all 10** Phase 1+2 specs                           | −10   |
| **3b** | 2026-05-19    | 12:14 CEST   | `70dae9c` — add unit tests               | **Replaced with 54** comprehensive specs                     | +54   |
| **4**  | 2026-05-23    | 00:19 CEST   | `bd72c32` — pizzeria details enhancement | Added `load-more.spec.ts` alongside new component            | +1    |
| **5**  | 2026-05-26    | 12:41 CEST   | `b7f434b` — checkout flow enhancement    | Added 6 checkout specs, deleted `checkout-deactivate` guard  | +6 −1 |
| **6**  | 2026-05-27+   | —            | `7d23826`, `3322c2d` — coupon features   | Refactored/extended existing specs for coupon code           | 0 net |
| **7**  | 2026-05-19→27 | —            | 8 refactor commits                       | Enhanced existing specs (linting, type safety, mock cleanup) | 0 net |

**Final count:** 60 spec files with ~344 individual `it()` test blocks.

---

## Phase 1: Skeleton Specs — 2026-05-14 23:12 CEST

**Commit:** `a1eb73e` — "init"
**Net change:** +9 specs

The project scaffolding commit included 9 test files alongside the application code. These were **placeholder-quality specs** — minimal in scope, coarser in mocking strategy, and ultimately all deleted 5 days later (Phase 3a).

### Files Created

| #   | File                                                                        | Test Blocks | Feature Area                    |
| --- | --------------------------------------------------------------------------- | ----------- | ------------------------------- |
| 1   | `src/app/app.spec.ts`                                                       | 4           | App root                        |
| 2   | `src/app/core/services/auth.spec.ts`                                        | 11          | Core — Auth                     |
| 3   | `src/app/core/services/photon-api.spec.ts`                                  | 6           | Core — Geocoding                |
| 4   | `src/app/core/guards/auth/auth.guard.spec.ts`                               | 4 \*        | Both `authGuard` + `guestGuard` |
| 5   | `src/app/core/guards/role/role.guard.spec.ts`                               | ~4          | Core — Role guard               |
| 6   | `src/app/core/guards/checkout-deactivate/checkout-deactivate.guard.spec.ts` | ~3          | Checkout — Deactivate guard     |
| 7   | `src/app/core/interceptors/credentials.interceptor.spec.ts`                 | ~3          | Core — Credentials              |
| 8   | `src/app/features/cart/cart.store.spec.ts`                                  | ~12         | Cart — Store (no HTTP sync)     |
| 9   | `src/app/features/pizzerias/services/pizzeria-api.spec.ts`                  | ~4          | Pizzerias — API                 |

> _\* Auth guard file covered 2 guards (`authGuard` + `guestGuard`) in a single spec — a pattern retained in the replacement._
>
> Note: `app.spec.ts` was not replaced in Phase 3 and was permanently removed.

### Key Test Code (Phase 1 Quality)

**Auth service** — already had solid patterns with `HttpTestingController`:

```ts
// init version — auth.spec.ts
it('should set user and stop loading on success', () => {
  service.init().subscribe();
  const req = httpMock.expectOne('/api/auth/me');
  req.flush(mockUser);
  expect(service.user()).toEqual(mockUser);
  expect(service.isAuthenticated()).toBe(true);
});

it('should not clear a user established by register when /me returns 401 later', () => {
  // Tests that register() wins over init()'s 401 — subtle race condition covered
  service.init().subscribe();
  const meReq = httpMock.expectOne('/api/auth/me');
  service.register('newer@example.com', 'password123').subscribe();
  const regReq = httpMock.expectOne('/api/auth/register');
  regReq.flush(mockUser);
  expect(service.user()).toEqual(mockUser);
  meReq.flush('Unauthorized', { status: 401, statusText: 'Unauthorized' });
  expect(service.user()).toEqual(mockUser); // register's user survives init's 401
});
```

**Auth guard** — used `signal()` for stubs (less isolated than the Phase 3 approach):

```ts
// init version — auth.guard.spec.ts
function setup(isAuthenticated: boolean): void {
  TestBed.configureTestingModule({
    providers: [
      provideRouter([]),
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: Auth, useValue: { isAuthenticated: signal(isAuthenticated), user: signal(null) } },
    ],
  });
}

it('should redirect to /auth/login when not authenticated', () => {
  setup(false);
  const result = TestBed.runInInjectionContext(() =>
    authGuard({} as ActivatedRouteSnapshot, {} as RouterStateSnapshot),
  );
  expect(result).toBeInstanceOf(UrlTree);
  expect((result as UrlTree).toString()).toBe('/auth/login');
});
```

### Evaluation — Why These 9 First?

**Architectural reasoning:**

1. **Auth is the dependency linchpin.** `Auth` (service) and `authGuard` are consumed by every protected route, the header, the checkout flow, and the cart store. Test them first because everything else depends on them being correct.

2. **Cart store is the core business logic.** The `CartStore` is a signal-based state machine that governs add/remove/clear/merge logic. Testing it early validates the most complex pure-logic layer before any UI tests reference it.

3. **Pizzeria API and Photon API are external integration surfaces.** Testing these early establishes the HTTP testing patterns (`HttpTestingController`) that every subsequent service test copies.

4. **Credentials interceptor and checkout-deactivate guard** fill out the infrastructure layer — request modification and navigation control. These are foundational to multi-page user flows.

5. **`app.spec.ts`** tests the root component shell — the nav bar toggle, mobile menu — establishing the pattern for component testing.

**Process reasoning:**

- The developer built tests **inline with the initial project scaffolding**, not as an afterthought. Every source file in the init commit had a co-located spec.
- The tests were **functional but not polished** — they used `ActivatedRouteSnapshot`/`RouterStateSnapshot` casts and `signal()`-based stubs that would later be refined with `vi.fn()` mocks.
- This was a **"get it working, then make it right"** approach — the Phase 1 tests proved the patterns worked but weren't the final form.

---

## Phase 2: Base URL Interceptor — 2026-05-18 00:57 CEST

**Commit:** `43a4c77` — "Implement base URL interceptor for API requests and update environment configurations"
**Net change:** +1 spec

### File Created

| #   | File                                                     | Test Blocks | Feature Area    |
| --- | -------------------------------------------------------- | ----------- | --------------- |
| 1   | `src/app/core/interceptors/base-url.interceptor.spec.ts` | 3           | Core — Base URL |

### Evaluation — Why Now?

**Architectural reasoning:**

The `BaseUrlInterceptor` was added during implementation work on environment-based API URL configuration. The interceptor prepends `/api` to relative URLs, which is a cross-cutting concern that affects every HTTP call. Testing it alongside its implementation is natural — the spec validates the interceptor's URL transformation logic using `HttpTestingController` to inspect forwarded request URLs.

**Process reasoning:**

This was **the only incremental test addition before the big rewrite**. The developer added it as they implemented the feature, suggesting a nascent TDD-like workflow for infrastructure code. The fact that it was also deleted in Phase 3a (along with all the other init-phase specs) means it was caught in the mass wipe — its replacement in Phase 3b would have near-identical logic but with the newer mocking patterns.

---

## Phase 3a: Mass Deletion — 2026-05-19 01:52 CEST

**Commit:** `cdbf77a` — "Remove obsolete spec files for various components and services"
**Net change:** −10 specs

### Files Deleted

All 10 Phase 1+2 specs were removed:
`app.spec.ts`, `auth.spec.ts`, `photon-api.spec.ts`, `auth.guard.spec.ts`, `role.guard.spec.ts`, `checkout-deactivate.guard.spec.ts`, `credentials.interceptor.spec.ts`, `base-url.interceptor.spec.ts`, `cart.store.spec.ts`, `pizzeria-api.spec.ts`

### Evaluation — Why Delete All Existing Tests?

**This is the most revealing moment in the chronology.** At 01:52am, the developer deleted every test they had written over the preceding 5 days. Then 10 hours later (12:14pm), they wrote 54 new specs as a single massive batch.

**Interpretations:**

1. **Skeleton → Comprehensive rewrite.** The Phase 1 tests were scaffold-level — they proved the test harnesses worked but didn't exhaustively cover behavior. Rather than patch and extend them incrementally, the developer chose a clean slate. This is a deliberate quality decision: the new tests would use consistent patterns (`vi.fn()` for stubs, `NO_ERRORS_SCHEMA` for shallow rendering, `TestBed.runInInjectionContext()` for guards) that would have been awkward to retrofit.

2. **Late-night decision to raise the bar.** The 01:52 deletion followed by a 12:14 recreation suggests an overnight shift in approach. The developer may have realized the placeholder tests didn't meet their standard for a public reference project.

3. **One commit for atomicity.** Bundling all 54 new specs into a single commit (`70dae9c`) means the test suite went from zero to comprehensive in one atomic change. This makes the git history cleaner — there's no intermediate state where some features have new-style tests and others have old-style.

---

## Phase 3b: The Big Batch — 2026-05-19 12:14 CEST

**Commit:** `70dae9c` — "Add unit tests for core components and services"
**Net change:** +54 specs

This is the **defining commit** of the test suite. It adds 54 spec files covering every layer of the application, establishing the patterns that the entire suite still follows today. Of the 60 specs in the final codebase, **54 were born here** (90%).

### Files Created — By Category

#### Core Infrastructure (6 specs)

| #   | File                                                | `it()` Blocks | Tests What                                |
| --- | --------------------------------------------------- | ------------- | ----------------------------------------- |
| 1   | `core/services/auth.spec.ts`                        | 11            | Login, logout, register, init, role flags |
| 2   | `core/services/photon-api.spec.ts`                  | 6             | Geocoding forward/reverse search          |
| 3   | `core/guards/auth/auth.guard.spec.ts`               | 4             | authGuard + guestGuard (both in one file) |
| 4   | `core/guards/role/role.guard.spec.ts`               | 4             | Role-based route protection               |
| 5   | `core/interceptors/credentials.interceptor.spec.ts` | 3             | withCredentials for API vs Photon         |
| 6   | `core/interceptors/base-url.interceptor.spec.ts`    | 3             | URL prefix transformation                 |

#### Shared Components (16 specs)

| #   | File                                                                    | `it()` Blocks |
| --- | ----------------------------------------------------------------------- | ------------- |
| 7   | `shared/components/button/button.spec.ts`                               | 8             |
| 8   | `shared/components/input/input.spec.ts`                                 | 7             |
| 9   | `shared/components/textarea/textarea.spec.ts`                           | 7             |
| 10  | `shared/components/modal/modal.spec.ts`                                 | 4             |
| 11  | `shared/components/spinner/spinner.spec.ts`                             | 3             |
| 12  | `shared/components/callout/callout.spec.ts`                             | 8             |
| 13  | `shared/components/confirm-dialog/confirm-dialog.spec.ts`               | 4             |
| 14  | `shared/components/empty-state/empty-state.spec.ts`                     | 6             |
| 15  | `shared/components/hero-banner/hero-banner.spec.ts`                     | 3             |
| 16  | `shared/components/image-picker/image-picker.spec.ts`                   | 7             |
| 17  | `shared/components/pagination/pagination.spec.ts`                       | 9             |
| 18  | `shared/components/photon-location-field/photon-location-field.spec.ts` | 7             |
| 19  | `shared/components/pizza-logo/pizza-logo.spec.ts`                       | 6             |
| 20  | `shared/components/avatar/avatar.spec.ts`                               | 4             |
| 21  | `shared/components/status-badge/status-badge.spec.ts`                   | 5             |
| 22  | `shared/directives/role.directive.spec.ts`                              | 11            |
| 23  | `shared/pipes/catalog-image-url.pipe.spec.ts`                           | 5             |

#### Feature: Auth (2 specs)

| #   | File                                                      | `it()` Blocks |
| --- | --------------------------------------------------------- | ------------- |
| 24  | `features/auth/pages/login-page/login-page.spec.ts`       | 3             |
| 25  | `features/auth/pages/register-page/register-page.spec.ts` | 4             |

#### Feature: Cart (2 specs)

| #   | File                                              | `it()` Blocks |
| --- | ------------------------------------------------- | ------------- |
| 26  | `features/cart/cart.store.spec.ts`                | 18            |
| 27  | `features/cart/pages/cart-page/cart-page.spec.ts` | 4             |

#### Feature: Checkout (2 specs — initial)

| #   | File                                                          | `it()` Blocks |
| --- | ------------------------------------------------------------- | ------------- |
| 28  | `features/checkout/guards/cart-not-empty.guard.spec.ts`       | 2             |
| 29  | `features/checkout/pages/checkout-page/checkout-page.spec.ts` | 6             |

#### Feature: Orders (7 specs)

| #   | File                                                                                  | `it()` Blocks |
| --- | ------------------------------------------------------------------------------------- | ------------- |
| 30  | `features/orders/order-api.spec.ts`                                                   | 3             |
| 31  | `features/orders/components/pizza-order-form-dialog/pizza-order-form-dialog.spec.ts`  | 7             |
| 32  | `features/orders/components/pizza-size-option-field/pizza-size-option-field.spec.ts`  | 8             |
| 33  | `features/orders/pages/order-list-page/order-list-page.spec.ts`                       | 7             |
| 34  | `features/orders/pages/order-details-page/order-details-page.spec.ts`                 | 7             |
| 35  | `features/orders/pages/admin-order-list-page/admin-order-list-page.spec.ts`           | 6             |
| 36  | `features/orders/pages/admin-order-list-page/admin-order-row/admin-order-row.spec.ts` | 9             |

#### Feature: Pizzerias (11 specs)

| #   | File                                                                                                   | `it()` Blocks |
| --- | ------------------------------------------------------------------------------------------------------ | ------------- |
| 37  | `features/pizzerias/services/pizzeria-api.spec.ts`                                                     | 4             |
| 38  | `features/pizzerias/services/pizza-api.spec.ts`                                                        | 3             |
| 39  | `features/pizzerias/guards/no-pizzeria.guard.spec.ts`                                                  | 3             |
| 40  | `features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.spec.ts`                               | 8             |
| 41  | `features/pizzerias/pages/pizzeria-details-page/pizzeria-details-page.spec.ts`                         | 16            |
| 42  | `features/pizzerias/pages/admin-pizza-list-page/admin-pizza-list-page.spec.ts`                         | 6             |
| 43  | `features/pizzerias/pages/admin-pizzeria-configuration-page/admin-pizzeria-configuration-page.spec.ts` | 6             |
| 44  | `features/pizzerias/pages/admin-pizzeria-details-page/admin-pizzeria-details-page.spec.ts`             | 3             |
| 45  | `features/pizzerias/pages/admin-pizzeria-form-page/admin-pizzeria-form-page.spec.ts`                   | 2             |
| 46  | `features/pizzerias/components/admin-pizza-form-dialog/admin-pizza-form-dialog.spec.ts`                | 6             |
| 47  | `features/pizzerias/components/admin-pizza-row/admin-pizza-row.spec.ts`                                | 9             |

#### Feature: Profile, Legal, Not-Found, Unauthorized (4 specs)

| #   | File                                                                               | `it()` Blocks |
| --- | ---------------------------------------------------------------------------------- | ------------- |
| 48  | `features/profile/pages/profile-page/profile-page.spec.ts`                         | 3             |
| 49  | `features/legal/pages/terms-and-conditions-page/terms-and-conditions-page.spec.ts` | 3             |
| 50  | `features/not-found/pages/not-found-page/not-found-page.spec.ts`                   | 3             |
| 51  | `features/unauthorized/pages/unauthorized-page/unauthorized-page.spec.ts`          | 4             |

#### Layout Components (2 specs)

| #   | File                                    | `it()` Blocks |
| --- | --------------------------------------- | ------------- |
| 52  | `core/components/footer/footer.spec.ts` | 2             |
| 53  | `core/components/header/header.spec.ts` | 8             |

### Key Test Code — Phase 3 Quality Leap

**Auth guard — Phase 3 rewrite** uses `vi.fn()` instead of `signal()`:

```ts
// Phase 3 version — auth.guard.spec.ts
const authStub: Mocked<Pick<Auth, 'isAuthenticated'>> = {
  isAuthenticated: vi.fn(),
};

it('should return a UrlTree to /auth/login when not authenticated', () => {
  authStub.isAuthenticated.mockReturnValue(false);
  const result = TestBed.runInInjectionContext(() => authGuard({} as any, {} as any));
  expect(result).toBeInstanceOf(UrlTree);
  expect(router.serializeUrl(result as UrlTree)).toBe('/auth/login');
});
```

**Button component — new pattern** for shallow standalone components:

```ts
// Phase 3 version — button.spec.ts
beforeEach(async () => {
  TestBed.configureTestingModule({}).overrideComponent(Button, {
    set: { schemas: [NO_ERRORS_SCHEMA] },
  });
  fixture = TestBed.createComponent(Button);
  el = fixture.nativeElement;
  buttonEl = el.querySelector('button')!;
  await fixture.whenStable();
});

it('should show loading spinner when isLoading is true', async () => {
  fixture.componentRef.setInput('isLoading', true);
  await fixture.whenStable();
  expect(buttonEl.querySelector('.btn-spinner')).not.toBeNull();
  expect(buttonEl.getAttribute('aria-busy')).toBe('true');
});
```

### Evaluation — Why 54 Specs in One Batch?

**Architectural reasoning:**

The batch follows a clear **dependency-first ordering within the commit itself** (visible in the file creation list):

1. **Core services & interceptors first** — `auth.spec.ts`, `photon-api.spec.ts`, `credentials.interceptor.spec.ts`, `base-url.interceptor.spec.ts`. These have zero component dependencies and establish the HTTP mocking patterns everything else uses.

2. **Guards second** — `auth.guard.spec.ts`, `role.guard.spec.ts`, `cart-not-empty.guard.spec.ts`, `no-pizzeria.guard.spec.ts`. Guards depend on services (Auth, CartStore) and routing, so they naturally follow services.

3. **Shared components third** — 16 leaf components (`button`, `input`, `modal`, etc.). These are dependency-free UI atoms that can be tested in isolation with `NO_ERRORS_SCHEMA`. Writing them third establishes the component testing pattern before tackling pages.

4. **Feature pages fourth** — 17 pages across auth, cart, checkout, orders, pizzerias, profile, legal, not-found, unauthorized. Pages depend on shared components (stubbed via `NO_ERRORS_SCHEMA`) and services (mocked). The shared component tests already validated the component testing approach, so pages follow the same pattern.

5. **Feature dialogs and sub-components fifth** — 9 more complex feature components like `PizzaOrderFormDialog`, `AdminPizzaRow`. These often override `imports` to bring in real child components rather than using `NO_ERRORS_SCHEMA`, making them the most complex tests.

6. **Directive and pipe last** — `role.directive.spec.ts`, `catalog-image-url.pipe.spec.ts`. These are the most isolated tests (directives use host components, pipes don't even need TestBed) and serve as the final completeness check.

**Process reasoning:**

- The developer made a deliberate decision to **replace, not refactor.** Rewriting 54 specs from scratch is faster and produces better results than incrementally upgrading 10 placeholder specs. The uniformity of mocking patterns (`vi.fn()`, `Mocked<>` types, `NO_ERRORS_SCHEMA`, `componentRef.setInput()`) across all 54 files proves they were written with a single, consistent mental model.

- The commit message says "Add unit tests for core components and services" but actually covered the entire app. This suggests the developer set out to write tests for the core and then kept going until everything was covered. The scope crept from "core" to "everything" within a single session.

- The batch was written in a single day (12:14pm commit after a 01:52am deletion). This is ~54 specs in one workday — achievable if the component structure was already stable and the testing patterns were decided upfront.

---

## Phase 4: Load More Component — 2026-05-23 00:19 CEST

**Commit:** `bd72c32` — "refactor: enhance pizzeria details page with pagination and loading states"
**Net change:** +1 spec

### File Created

| #   | File                                            | `it()` Blocks | Feature Area             |
| --- | ----------------------------------------------- | ------------- | ------------------------ |
| 1   | `shared/components/load-more/load-more.spec.ts` | 3             | Shared — Infinite scroll |

### Key Test Code

```ts
// Phase 4 — load-more.spec.ts
function stubViewportNearBottom(): void {
  Object.defineProperty(document.documentElement, 'scrollHeight', {
    value: 1000,
    configurable: true,
  });
  Object.defineProperty(window, 'scrollY', { value: 700, configurable: true });
  Object.defineProperty(window, 'innerHeight', { value: 400, configurable: true });
}

it('should emit loadMore when scrolled near the bottom', async () => {
  stubViewportNearBottom();
  await fixture.whenStable();
  const countBeforeScroll = emitCount;
  window.dispatchEvent(new Event('scroll'));
  expect(emitCount).toBe(countBeforeScroll + 1);
});

it('should not emit when not near the bottom', async () => {
  stubViewportNotNearBottom();
  await fixture.whenStable();
  const countBeforeScroll = emitCount;
  window.dispatchEvent(new Event('scroll'));
  expect(emitCount).toBe(countBeforeScroll);
});
```

### Evaluation — Why Now?

**Architectural reasoning:**

The `LoadMore` component was a **new feature addition** (infinite scroll pagination for the pizzeria details page), not a pre-existing untested component. The test was created **alongside the component's implementation** in the same commit. This is the first instance of true TDD-aligned behavior in the chronology — the initial phases wrote tests after the code existed, but Phase 4 demonstrates "new component, new test, same commit."

**Process reasoning:**

This single-test addition shows the developer maintaining the 1:1 spec-to-source ratio even as new features landed, 4 days after the big batch. The test uses the same `NO_ERRORS_SCHEMA` shallow rendering pattern established in Phase 3b, demonstrating pattern consistency. It also adds a creative technique — stubbing `document.documentElement.scrollHeight` and `window.scrollY` — to test scroll-position detection without a real viewport. This shows the developer was willing to extend the testing toolkit for new challenges.

---

## Phase 5: Checkout Flow Enhancement — 2026-05-26 12:41 CEST

**Commit:** `b7f434b` — "refactor: enhance checkout flow with new components and guards"
**Net change:** +6 specs, −1 spec

### Files Created

| #   | File                                                                                       | `it()` Blocks | Feature Area                               |
| --- | ------------------------------------------------------------------------------------------ | ------------- | ------------------------------------------ |
| 1   | `features/checkout/services/checkout-wizard.spec.ts`                                       | 20            | Checkout — Multi-step wizard state machine |
| 2   | `features/checkout/guards/checkout-step.guard.spec.ts`                                     | 7             | Checkout — Step sequence enforcement       |
| 3   | `features/checkout/components/checkout-delivery-step/checkout-delivery-step.spec.ts`       | 2             | Checkout — Delivery form                   |
| 4   | `features/checkout/components/checkout-schedule-step/checkout-schedule-step.spec.ts`       | 3             | Checkout — Scheduling                      |
| 5   | `features/checkout/components/checkout-review-step/checkout-review-step.spec.ts`           | 6→9           | Checkout — Order review                    |
| 6   | `features/checkout/components/checkout-progress-stepper/checkout-progress-stepper.spec.ts` | 4             | Checkout — Step indicator                  |

### Files Deleted

| #   | File                                                                | Reason                            |
| --- | ------------------------------------------------------------------- | --------------------------------- |
| 1   | `core/guards/checkout-deactivate/checkout-deactivate.guard.spec.ts` | Replaced by `checkout-step.guard` |

### Key Test Code

**CheckoutWizard — the most complex test in the suite** (20 tests):

```ts
// Phase 5 — checkout-wizard.spec.ts
describe('tipAmount', () => {
  it('should compute 10% of total when tip type is ten', () => {
    cartStoreStub.totalPrice.set(20);
    service.checkoutForm.tip.type().value.set('ten');
    TestBed.flushEffects();
    expect(service.tipAmount()).toBe(2);
  });

  it('should compute 15% of total when tip type is fifteen', () => {
    cartStoreStub.totalPrice.set(10);
    service.checkoutForm.tip.type().value.set('fifteen');
    TestBed.flushEffects();
    expect(service.tipAmount()).toBe(1.5);
  });
});

describe('validateStep', () => {
  it('should not navigate on invalid delivery', async () => {
    await service.validateStep('delivery');
    expect(service.stepStatus().delivery).not.toBe('success');
    expect(service.activeStep()).toBe('delivery');
  });

  it('should validate and navigate on valid delivery', async () => {
    service.checkoutForm.delivery.street().value.set('123 Main St');
    service.checkoutForm.delivery.location().value.set({ city: 'Rome', country: 'Italy' });
    TestBed.flushEffects();
    await service.validateStep('delivery');
    expect(service.stepStatus().delivery).toBe('success');
  });
});
```

**CheckoutStepGuard — step sequencing enforcement** (7 tests):

```ts
// Phase 5 — checkout-step.guard.spec.ts
it('should redirect schedule to delivery when delivery is invalid', async () => {
  const result = TestBed.runInInjectionContext(() => checkoutStepGuard('schedule')({}, []));
  expect(result).toBeInstanceOf(UrlTree);
  expect(router.serializeUrl(result as UrlTree)).toBe('/checkout/delivery');
});

it('should allow direct navigation to review when prior steps are valid', async () => {
  wizard.checkoutForm.delivery.street().value.set('123 Main St');
  wizard.checkoutForm.delivery.location().value.set({ city: 'Rome', country: 'Italy' });
  TestBed.flushEffects();
  await router.navigateByUrl('/checkout/review');
  expect(router.url).toBe('/checkout/review');
  expect(wizard.activeStep()).toBe('review');
});
```

### Evaluation — Why Checkout Tests Came Last?

**Architectural reasoning:**

The checkout flow is the most architecturally complex feature in the application — a multi-step wizard with sequential validation, tip calculation, delivery scheduling, and order placement. It was the last major feature to be built and therefore the last to be tested.

The 6 new specs reveal a layered design:

1. **`CheckoutWizard`** (20 tests) is the brain — a signal-based state machine managing step transitions, tip computation, billing address sync, and order creation. It's the most test-rich file in the entire suite because it contains the most business logic.

2. **`CheckoutStepGuard`** (7 tests) enforces the wizard's step sequence at the routing level — you can't skip to `/checkout/review` without completing `/checkout/delivery` and `/checkout/schedule`. The guard tests exercise every transition edge case.

3. **Step components** (delivery, schedule, review, progress-stepper — 15 total tests) are presentation-layer wrappers that render form inputs and delegate validation to the wizard. They're tested for DOM structure, not business logic.

4. **`checkout-deactivate.guard.spec.ts` was deleted** — the old deactivation guard was replaced by the new step guard. This is a pattern substitution, not a loss of coverage.

**Process reasoning:**

The developer built checkout iteratively over 3 days (May 23→26). The test creation tracks the implementation exactly:

| Date              | What Was Built                               | Tests Added |
| ----------------- | -------------------------------------------- | ----------- |
| May 19 (Phase 3b) | Basic checkout page + cart-not-empty guard   | 2 specs     |
| May 26 (Phase 5)  | Full wizard + 3 step components + step guard | 6 specs     |

This is **incremental TDD for a complex feature** — start with the shell, get the full flow working, then add comprehensive tests. The 20-test CheckoutWizard spec shows the developer understood this was the highest-risk component in the app and invested testing effort proportionally.

---

## Phase 6: Coupon Code Extension — 2026-05-27+

**Commits:** `7d23826` — "feat: add coupon code functionality to checkout review step", `3322c2d` — "feat: enhance coupon code functionality in checkout review step"
**Net change:** 0 new spec files (modified existing `checkout-review-step.spec.ts`)

### What Changed

The `checkout-review-step.spec.ts` gained coupon-specific tests:

- Coupon code input field in the review step
- Coupon application logic
- Coupon validation

The test count in this file grew from 6 → 9 tests across these two commits.

### Evaluation

This phase extends the checkout review spec rather than creating a new one, reinforcing the existing pattern of feature-co-located testing. The developer added tests in the same commits as the feature implementation — a disciplined habit that persisted through the final features of the project.

---

## Phase 7: Test Refactoring Wave — 2026-05-19→27

**Commits:** `debb2fd`, `9795b46`, `293373a`, `ba04b9d`, `26e0388`, `6cdda60`, `0d66ee7`, `ca63022`, `70725e2`

Eight commits improved existing tests without adding or removing spec files:

| Date       | Commit    | What Changed                                                  |
| ---------- | --------- | ------------------------------------------------------------- |
| 2026-05-19 | `debb2fd` | Prettier formatting applied to all specs                      |
| 2026-05-19 | `9795b46` | ESLint fixes across specs                                     |
| 2026-05-22 | `293373a` | Updated tests alongside pizzeria details enhancements         |
| 2026-05-23 | `ba04b9d` | Refactored guard and component tests                          |
| 2026-05-23 | `26e0388` | Updated component tests for change detection + type safety    |
| 2026-05-23 | `6cdda60` | Enhanced test structure and formatting                        |
| 2026-05-25 | `0d66ee7` | Replaced mock components with actual implementations in tests |
| 2026-05-25 | `ca63022` | Removed `standalone` flag from mock components                |
| 2026-05-26 | `70725e2` | Cleaned up imports in pizza order form dialog tests           |

### Evaluation

These refactoring commits demonstrate a **test-as-first-class-citizen** mindset:

1. **Formatting and linting** (`debb2fd`, `9795b46`) applied to all specs immediately after the big Phase 3b batch. The developer treated test code with the same quality bar as production code.

2. **The mid-stream refactors** (`293373a`, `ba04b9d`, `26e0388`, `6cdda60`) updated tests as implementation details evolved — the pizzeria details page added pagination, components changed their change detection behavior, and the tests kept pace.

3. **Mock → Real component migration** (`0d66ee7`, `ca63022`) shows the developer progressively tightening the feedback loop. Initially using mock components (via `NO_ERRORS_SCHEMA`), then replacing mocks with real implementations where integration behavior mattered (like `PizzaOrderFormDialog` importing its real children).

4. **Import cleanup** (`70725e2`) is the final polish — removing dead imports from test files. This is the kind of detail work that distinguishes a maintained test suite from a neglected one.

---

## Feature Cross-Reference: When Each Feature Got Tests

| Feature               | Phase 1 (init)                       | Phase 3b (batch)                      | Phase 4   | Phase 5 | Total Specs |
| --------------------- | ------------------------------------ | ------------------------------------- | --------- | ------- | ----------- |
| **Core — Auth**       | auth.service, auth.guard, role.guard | ✓ (replaced)                          | —         | —       | 3           |
| **Core — HTTP**       | credentials.interceptor              | ✓ + base-url.interceptor (replaced)   | —         | —       | 2           |
| **Core — Geocoding**  | photon-api.service                   | ✓ (replaced)                          | —         | —       | 1           |
| **Core — Layout**     | —                                    | header, footer                        | —         | —       | 2           |
| **Shared Components** | —                                    | 16 components + 1 directive + 1 pipe  | load-more | —       | 18          |
| **Auth Pages**        | —                                    | login, register                       | —         | —       | 2           |
| **Cart**              | cart.store                           | ✓ (replaced) + cart-page              | —         | —       | 2           |
| **Checkout**          | checkout-deactivate.guard            | cart-not-empty.guard, checkout-page   | —         | 6 specs | 8           |
| **Orders**            | —                                    | 7 specs                               | —         | —       | 7           |
| **Pizzerias**         | pizzeria-api.service                 | 10 more specs (replaced pizzeria-api) | —         | —       | 11          |
| **Profile**           | —                                    | profile-page                          | —         | —       | 1           |
| **Legal**             | —                                    | terms-and-conditions                  | —         | —       | 1           |
| **Not Found**         | —                                    | not-found-page                        | —         | —       | 1           |
| **Unauthorized**      | —                                    | unauthorized-page                     | —         | —       | 1           |
| **App Root**          | app.spec                             | —                                     | —         | —       | 0 (deleted) |

---

## Final Evaluation: Why This Chronological Order?

### The Big Picture

The test creation chronology reveals five layers of reasoning:

### 1. Dependency-Driven Layering (Architectural)

Tests were created from the bottom of the dependency graph upward:

```
Services → Guards → Shared Components → Feature Pages → Complex Dialogs
   ↓            ↓              ↓                ↓              ↓
Phase 1+3b   Phase 1+3b      Phase 3b        Phase 3b       Phase 3b+5
```

**Why it matters:** If `Auth` is broken, `authGuard` tests that depend on it are meaningless. If `Button` doesn't render, `LoginPage` tests that contain it are unreliable. Building test coverage from the leaves inward means each layer of tests validates both the layer itself AND the correctness of the dependencies it relies on.

### 2. Complexity-Weighted Investment (Process)

The number of tests per feature correlates with business-logic complexity, not with UI surface area:

| Component             | Test Count | Why                                                         |
| --------------------- | ---------- | ----------------------------------------------------------- |
| `CheckoutWizard`      | 20         | Multi-step state machine with tip math, cross-field effects |
| `CartStore`           | 18         | Signal-based cart with merge/deduplicate/clear logic        |
| `PizzeriaDetailsPage` | 16         | Pagination, loading states, catalog rendering               |
| `Auth` (service)      | 11         | Auth lifecycle, race conditions, role computation           |
| `Header`              | 8          | Auth-aware navigation, menu toggle, role display            |
| `Button`              | 8          | Variant/palette/size/loading/disabled states                |

**Why it matters:** The developer didn't write equal tests for every file — they invested proportionally in the most logic-dense components. The `CheckoutWizard` at 20 tests wasn't because it's a "big file" — it's because it contains the most decisions, calculations, and state transitions.

### 3. Wipe-and-Rewrite Quality Decision (Process)

The Phase 1→3a→3b sequence (build skeleton → delete all → rewrite comprehensively) is the most consequential process decision:

- **Phase 1 tests were placeholder quality** — they used `signal()` stubs, `ActivatedRouteSnapshot` casts, and coarser mocking
- **Rather than incremental upgrade**, the developer chose a clean break
- **Phase 3b established canonical patterns** — `vi.fn()` mocks, `Mocked<>` types, `NO_ERRORS_SCHEMA`, `componentRef.setInput()` — and applied them uniformly to all 54 specs

**Why it matters:** This was a quality investment at the cost of test history. The "wrong" approach would have been to keep the placeholder tests and add new tests with different patterns — that would have created a two-tier test suite where half the files use old conventions. The wipe ensured pattern uniformity at the cost of losing the "tests grew with the code" narrative.

### 4. Feature-Parallel Implementation (Process)

The non-checkout features were implemented and tested in one massive batch (Phase 3b). The checkout flow was implemented and tested incrementally over two phases (3b + 5). This suggests two different development modes:

- **"Build everything, then test everything"** for the stable, well-understood features (auth, orders, pizzerias, shared components)
- **"Build incrementally, test with each increment"** for the checkout flow, which was the most architecturally novel feature

**Why it matters:** The developer adapted their process to the task. For CRUD features with clear API contracts (orders, pizzerias), the big-batch approach was efficient. For the stateful multi-step checkout wizard, incremental testing reduced the risk of a broken state machine.

### 5. Test Maintenance as Continuous Practice (Process)

The 8 refactoring commits (Phase 7) show that tests weren't "write once and forget":

- Formatting/linting applied to all specs immediately
- Tests kept pace with component evolution (change detection, type safety)
- Mock-to-real migrations tightened integration fidelity
- Import cleanup removed dead code

**Why it matters:** The test suite is maintained with the same hygiene as production code. This is the difference between a test suite that rots and one that stays useful.

### The Bottom Line

The test creation order reflects a **deliberate, quality-first approach**:

1. Start with dependency-free infrastructure (services, guards)
2. Build the UI atom library (16 shared components)
3. Assemble feature pages from tested atoms
4. Invest extra effort in the complex stateful features (cart, checkout)
5. Maintain with the same discipline as production code

The single most telling moment is the Phase 3a→3b wipe-and-replace. A developer who deletes all their tests and rewrites them at higher quality has internalized that **test code is real code** — it deserves the same investment in architecture, consistency, and maintenance as the application itself.
