# Testing Guide

This project uses [Vitest](https://vitest.dev/) with [jsdom](https://github.com/jsdom/jsdom) as the test runner, replacing the traditional Karma/Jasmine setup. Tests are co-located with their source files as `*.spec.ts` files.

> **Testing Docs Index:**
>
> - **README-TEST-GUIDE.md** — How to write tests (Angular recommended + project patterns)
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — This file: factual inventory of what exists (59 specs, categories, patterns)
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

## Table of Contents

- [Infrastructure](#infrastructure)
- [Running Tests](#running-tests)
- [Test Inventory](#test-inventory)
- [Testing Patterns](#testing-patterns)
  - [Services & APIs](#services--apis)
  - [Stores](#stores)
  - [Interceptors](#interceptors)
  - [Functional Guards](#functional-guards)
  - [Components](#components)
  - [Dialogs & Overlays](#dialogs--overlays)
  - [Directives](#directives)
  - [Pipes](#pipes)
- [Coverage Gap Analysis](#coverage-gap-analysis)

## Infrastructure

| Layer           | Technology                                                                |
| --------------- | ------------------------------------------------------------------------- |
| Test runner     | [Vitest](https://vitest.dev/) v4                                          |
| DOM environment | jsdom v28                                                                 |
| Angular builder | `@angular/build:unit-test`                                                |
| HTTP mocking    | `@angular/common/http/testing` (HttpTestingController)                    |
| TypeScript      | `tsconfig.spec.json` extends `tsconfig.json`, adds `vitest/globals` types |

**Configuration** — the test builder is defined in `angular.json`:

```json
{
  "test": {
    "builder": "@angular/build:unit-test"
  }
}
```

**`tsconfig.spec.json`:**

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "outDir": "./out-tsc/spec",
    "types": ["vitest/globals"]
  },
  "include": ["src/**/*.d.ts", "src/**/*.spec.ts"]
}
```

There is no `vitest.config.ts` file — the Angular CLI builder generates the Vitest configuration internally. The `vitest/globals` type reference makes `describe`, `it`, `expect`, `vi`, etc. available without explicit imports (though the codebase imports them explicitly for clarity).

## Running Tests

```bash
pnpm run test        # Run all tests once (aliases: ng test)
```

There is no watch mode script defined in `package.json`, but `ng test --watch` works with the Angular CLI.

## Test Inventory

**59 spec files** across the entire codebase. All tests are **unit tests** — there are no e2e, integration, or visual regression tests (see [Coverage Gap Analysis](#coverage-gap-analysis)).

### By Category

| Category                | Count | Files                                                                                                                                                                                                                                                                                                                                                                                     |
| ----------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Service tests           | 5     | `auth.spec.ts`, `order-api.spec.ts`, `pizzeria-api.spec.ts`, `pizza-api.spec.ts`, `checkout-wizard.spec.ts`                                                                                                                                                                                                                                                                               |
| Store tests             | 1     | `cart.store.spec.ts`                                                                                                                                                                                                                                                                                                                                                                      |
| Interceptor tests       | 2     | `credentials.interceptor.spec.ts`, `base-url.interceptor.spec.ts`                                                                                                                                                                                                                                                                                                                         |
| Guard tests             | 5     | `auth.guard.spec.ts` (covers `authGuard` and `guestGuard`), `role.guard.spec.ts`, `cart-not-empty.guard.spec.ts`, `checkout-step.guard.spec.ts`, `no-pizzeria.guard.spec.ts`                                                                                                                                                                                                              |
| Shared component tests  | 16    | `button`, `input`, `textarea`, `modal`, `spinner`, `callout`, `confirm-dialog`, `empty-state`, `hero-banner`, `image-picker`, `load-more`, `pagination`, `photon-location-field`, `pizza-logo`, `avatar`, `status-badge`                                                                                                                                                                  |
| Feature page tests      | 17    | `login-page`, `register-page`, `cart-page`, `checkout-page`, `order-list-page`, `order-details-page`, `admin-order-list-page`, `pizzeria-list-page`, `pizzeria-details-page`, `admin-pizza-list-page`, `admin-pizzeria-configuration-page`, `admin-pizzeria-details-page`, `admin-pizzeria-form-page`, `profile-page`, `not-found-page`, `unauthorized-page`, `terms-and-conditions-page` |
| Feature component tests | 9     | `checkout-delivery-step`, `checkout-progress-stepper`, `checkout-review-step`, `checkout-schedule-step`, `pizza-order-form-dialog`, `pizza-size-option-field`, `admin-pizza-form-dialog`, `admin-pizza-row`, `admin-order-row`                                                                                                                                                            |
| Layout component tests  | 2     | `footer.spec.ts`, `header.spec.ts`                                                                                                                                                                                                                                                                                                                                                        |
| Directive tests         | 1     | `role.directive.spec.ts`                                                                                                                                                                                                                                                                                                                                                                  |
| Pipe tests              | 1     | `catalog-image-url.pipe.spec.ts`                                                                                                                                                                                                                                                                                                                                                          |

### By Feature Area

| Feature                                       | Spec Files |
| --------------------------------------------- | ---------- |
| Core (services, guards, interceptors, layout) | 8          |
| Shared (components, directives, pipes)        | 18         |
| Auth                                          | 2          |
| Cart                                          | 2          |
| Checkout                                      | 8          |
| Orders                                        | 7          |
| Pizzerias                                     | 11         |
| Profile                                       | 1          |
| Legal                                         | 1          |
| Not Found                                     | 1          |
| Unauthorized                                  | 1          |

## Testing Patterns

### Services & APIs

> **Angular Alignment:** ✓ Fully aligned with official recommendations

Services that make HTTP requests are tested with Angular's `HttpTestingController`. The pattern is consistent across all 6 service specs:

- Configure `TestBed` with `provideHttpClientTesting()`
- Inject both the service under test and `HttpTestingController`
- Call `httpTesting.verify()` in `afterEach` to ensure no unmatched requests remain
- Use `httpTesting.expectOne(url)` to intercept requests and `req.flush(data)` to respond

**Example** from `src/app/core/services/auth.spec.ts`:

```ts
beforeEach(() => {
  TestBed.configureTestingModule({
    providers: [provideHttpClientTesting()],
  });
  service = TestBed.inject(Auth);
  httpTesting = TestBed.inject(HttpTestingController);
});

afterEach(() => {
  httpTesting.verify(); // ensures no outstanding HTTP requests
});

it('should POST credentials and update user signal', () => {
  service.login('test@example.com', 'password').subscribe();
  const req = httpTesting.expectOne('/api/auth/login');
  expect(req.request.method).toBe('POST');
  expect(req.request.body).toEqual({ email: 'test@example.com', password: 'password' });
  req.flush(mockUser); // respond with mock data
  expect(service.user()).toEqual(mockUser); // assert signal state
});
```

Key conventions:

- Mock data objects (`mockUser`, `mockPizzeria`, etc.) are defined at the top of the file outside `describe` blocks
- Error scenarios are tested by flushing with error status: `req.flush('Unauthorized', { status: 401, statusText: 'Unauthorized' })`
- Every HTTP method is asserted: `expect(req.request.method).toBe('GET')` / `'POST'` / `'PATCH'` / `'DELETE'`

### Stores

> **Angular Alignment:** ✓ Fully aligned. The `httpTesting.match()` pattern is a project innovation not directly covered by Angular docs but functionally correct.

The `CartStore` (`src/app/features/cart/cart.store.spec.ts`) tests a signal-based store that syncs cart state to the server via POST requests. Key patterns:

- `TestBed.flushEffects()` triggers reactive effects that would normally fire during change detection
- `httpTesting.expectNone()` asserts that no HTTP request was made (e.g., when the cart is empty)
- `httpTesting.match()` with a predicate captures matching requests without failing if none exist, useful when multiple requests fire reactively

```ts
it('should not make an HTTP request when cart is empty', () => {
  TestBed.flushEffects();
  httpTesting.expectNone(() => true); // no request of any kind should fire
});

it('should trigger a POST to /api/orders/cart after adding item', () => {
  store.addItem('pizza1', 1, 's1', [], 'p1');
  TestBed.flushEffects();
  const req = httpTesting.expectOne((r) => r.url.includes('/api/orders/cart'));
  expect(req.request.method).toBe('POST');
  expect(req.request.body.pizzeriaId).toBe('p1');
  req.flush(mockCartData);
});
```

When the cart sync effect fires automatically after state changes (add, update, remove), `httpTesting.match()` is used to flush the intermediate requests:

```ts
beforeEach(() => {
  store.addItem('pizza1', 2, null, [], 'p1');
  httpTesting
    .match((r) => r.url.includes('/api/orders/cart'))
    .forEach((r) => r.flush(mockCartData)); // flush all matching requests
});
```

### Interceptors

> **Angular Alignment:** ✓ Fully aligned with official recommendations

Functional interceptors are tested by wiring them into a real `HttpClient` via `provideHttpClient(withInterceptors([...]))` and asserting the resulting request properties:

```ts
TestBed.configureTestingModule({
  providers: [
    provideHttpClient(withInterceptors([credentialsInterceptor])),
    provideHttpClientTesting(),
  ],
});
http = TestBed.inject(HttpClient);
httpTesting = TestBed.inject(HttpTestingController);
```

Then make requests and inspect the intercepted properties:

```ts
it('should add withCredentials to regular API requests', () => {
  http.get('/api/pizzerias').subscribe();
  const req = httpTesting.expectOne('/api/pizzerias');
  expect(req.request.withCredentials).toBe(true);
  req.flush([]);
});

it('should not add withCredentials to Photon API requests', () => {
  http.get('https://photon.komoot.io/api/?q=rome').subscribe();
  const req = httpTesting.expectOne('https://photon.komoot.io/api/?q=rome');
  expect(req.request.withCredentials).toBe(false);
  req.flush({});
});
```

This pattern tests the interceptor as a black box — the test only asserts the resulting request properties, not internal implementation.

### Functional Guards

> **Angular Alignment:** ⚠ Works but has a better alternative. The `runInInjectionContext()` approach tests guard logic in isolation but Angular recommends `RouterTestingHarness` for integration testing guards with their routes. The Angular 22 3-argument signature has been resolved upstream. See `README-TEST-GUIDE.md` for both patterns.

The project uses functional guards (`authGuard`, `guestGuard`, `roleGuard`, `cartNotEmptyGuard`, `checkoutStepGuard`, `noPizzeriaGuard`). These are plain functions (not injectable classes), so they are tested via `TestBed.runInInjectionContext()`.

Dependencies are stubbed as plain objects with `vi.fn()`:

```ts
const authStub: Mocked<Pick<Auth, 'isAuthenticated'>> = {
  isAuthenticated: vi.fn(),
};

beforeEach(() => {
  TestBed.configureTestingModule({
    providers: [provideRouter([]), { provide: Auth, useValue: authStub }],
  });
  router = TestBed.inject(Router);
});
```

Guards are called inside the injection context and return either `boolean` or `UrlTree`:

```ts
it('should return true when user is authenticated', () => {
  authStub.isAuthenticated.mockReturnValue(true);
  const result = TestBed.runInInjectionContext(() =>
    authGuard({ path: '' } as Route, [] as unknown as UrlSegment[]),
  );
  expect(result).toBe(true);
});

it('should return a UrlTree to /auth/login when not authenticated', () => {
  authStub.isAuthenticated.mockReturnValue(false);
  const result = TestBed.runInInjectionContext(() =>
    authGuard({ path: '' } as Route, [] as unknown as UrlSegment[]),
  );
  expect(result).toBeInstanceOf(UrlTree);
  expect(router.serializeUrl(result as UrlTree)).toBe('/auth/login');
});
```

The `roleGuard` tests follow the same pattern but mock the `Auth.user` signal:

```ts
const userSignal = signal<User | null>(null);
const authStub = { user: userSignal };

it('should return true when user has required role', () => {
  userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
  const result = TestBed.runInInjectionContext(() =>
    roleGuard(['CUSTOMER'])({} as Route, [] as unknown as UrlSegment[]),
  );
  expect(result).toBe(true);
});
```

### Components

> **Angular Alignment:** ⚠ Works but has a better alternative. Angular recommends Component Harnesses (`TestbedHarnessEnvironment`) as the standard way to interact with components in tests. The project uses `querySelector` which is simpler but more brittle against template refactors. See `README-TEST-GUIDE.md` for both patterns.

All component tests follow the standalone Angular testing pattern:

- Use `TestBed.configureTestingModule()` (no `declarations` — everything is standalone)
- Use `NO_ERRORS_SCHEMA` to skip rendering child component templates, keeping tests focused on the component under test
- Signal-based inputs are set via `fixture.componentRef.setInput(name, value)`
- Reactive effects are triggered via `TestBed.flushEffects()` or `await fixture.whenStable()`

**Basic component test** from `src/app/shared/components/button/button.spec.ts`:

```ts
beforeEach(async () => {
  TestBed.configureTestingModule({}).overrideComponent(Button, {
    set: { schemas: [NO_ERRORS_SCHEMA] },
  });
  fixture = TestBed.createComponent(Button);
  el = fixture.nativeElement;
  buttonEl = el.querySelector('button')!;
  await fixture.whenStable();
});

it('should apply variant and palette classes', async () => {
  fixture.componentRef.setInput('variant', 'outlined');
  fixture.componentRef.setInput('palette', 'danger');
  await fixture.whenStable();
  expect(buttonEl.className).toContain('btn--outlined-danger');
});

it('should show loading spinner when isLoading is true', async () => {
  fixture.componentRef.setInput('isLoading', true);
  await fixture.whenStable();
  expect(buttonEl.querySelector('.btn-spinner')).not.toBeNull();
  expect(buttonEl.getAttribute('aria-busy')).toBe('true');
});
```

**Page component test** from `src/app/features/auth/pages/login-page/login-page.spec.ts`:

Page tests additionally provide `provideRouter([])` and interact with form elements by dispatching DOM events:

```ts
beforeEach(async () => {
  TestBed.configureTestingModule({
    providers: [provideHttpClientTesting(), provideRouter([])],
  }).overrideComponent(LoginPage, { set: { schemas: [NO_ERRORS_SCHEMA] } });

  fixture = TestBed.createComponent(LoginPage);
  el = fixture.nativeElement;
  httpTesting = TestBed.inject(HttpTestingController);
  await fixture.whenStable();
});

it('should call POST /api/auth/login on form submit with valid credentials', async () => {
  const emailInput = el.querySelector<HTMLInputElement>('input[autocomplete="email"]');
  const passwordInput = el.querySelector<HTMLInputElement>(
    'input[autocomplete="current-password"]',
  );

  emailInput.value = 'test@example.com';
  emailInput.dispatchEvent(new Event('input'));
  passwordInput.value = 'password123';
  passwordInput.dispatchEvent(new Event('input'));

  const form = el.querySelector('form');
  form?.dispatchEvent(new Event('submit'));
  await fixture.whenStable();

  const req = httpTesting.expectOne('/api/auth/login');
  expect(req.request.method).toBe('POST');
  req.flush(mockUser);
});
```

Key conventions:

- Query DOM elements with attribute selectors (`[autocomplete="email"]`) or component selectors (`rw-input[label="Email"]`)
- Dispatch `new Event('input')` after setting `input.value` to trigger Angular form bindings
- Dispatch `new Event('submit')` on the form element rather than clicking a submit button

### Dialogs & Overlays

> **Angular Alignment:** ✓ Aligned with Angular. Stubs `DialogRef` and provides `DIALOG_DATA` injection token for CDK-based dialog components. See GUIDE for Modal, ConfirmDialog, and Form Dialog examples.

Dialog components receive data via Angular CDK's `DIALOG_DATA` injection token and close via `DialogRef`. Tests provide mock values for both:

```ts
beforeEach(async () => {
  closeFn = vi.fn();
  TestBed.configureTestingModule({
    providers: [
      { provide: DialogRef<ConfirmDialogResult>, useValue: { close: closeFn } },
      { provide: DIALOG_DATA, useValue: { title: 'Are you sure?', message: '...' } },
    ],
  }).overrideComponent(ConfirmDialog, { set: { schemas: [NO_ERRORS_SCHEMA] } });
  fixture = TestBed.createComponent(ConfirmDialog);
  el = fixture.nativeElement;
  await fixture.whenStable();
});

it('should render the title from data', () => {
  expect(el.textContent).toContain('Are you sure?');
});
```

For more complex dialogs (like `PizzaOrderFormDialog`), the test overrides `imports` on the component to bring in real child components (forms, buttons, modals) rather than using `NO_ERRORS_SCHEMA`, allowing interaction with the full dialog:

```ts
TestBed.configureTestingModule({
  providers: [
    provideHttpClientTesting(),
    { provide: DialogRef, useValue: { close: closeFn } },
    { provide: DIALOG_DATA, useValue: dialogData },
  ],
}).overrideComponent(PizzaOrderFormDialog, {
  set: {
    imports: [
      DecimalPipe,
      NgOptimizedImage,
      CatalogImageUrlPipe,
      Modal,
      Spinner,
      Button,
      Input,
      SizeOptionField,
      FormRoot,
      FormField,
    ],
  },
});
```

Form value changes in child components are set directly on the debug element's component instance:

```ts
const sizeDe = fixture.debugElement.query((de) => de.componentInstance instanceof SizeOptionField);
sizeDe.componentInstance.value.set({ id: 's1', label: 'Medium', price: 1 });
TestBed.flushEffects();
```

### Directives

> **Angular Alignment:** ✓ Fully aligned. The host component pattern is the canonical approach for testing structural directives.

Structural directives (like `*rwRole`) are tested using a **host component** pattern. A minimal test component is declared inline with the directive applied in its template, and the directive's dependency (`Auth`) is stubbed with a `signal`:

```ts
const userSignal = signal<User | null>(null);
const authStub = { user: userSignal };

@Component({
  imports: [RoleDirective],
  template: `
    <span *rwRole="'CUSTOMER'" id="customer-content">Customer only</span>
    <span *rwRole="'CUSTOMER'; else guestTpl" id="customer-or-else">Customer</span>
    <ng-template #guestTpl><span id="else-content">Please sign in</span></ng-template>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
class TestHostComponent {}
```

Tests then manipulate the signal and observe which content is rendered:

```ts
it('should react to user signal changes', async () => {
  expect(el.querySelector('#customer-content')).toBeNull();

  userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
  await fixture.whenStable();
  expect(el.querySelector('#customer-content')).not.toBeNull();

  userSignal.set(null);
  await fixture.whenStable();
  expect(el.querySelector('#customer-content')).toBeNull();
});
```

This tests both the initial render and reactivity to dynamic signal changes.

### Pipes

> **Angular Alignment:** ✓ Fully aligned. Instantiate directly with `new Pipe()` — no TestBed needed.

Pure pipes are the simplest tests — instantiate directly, no `TestBed` needed:

```ts
import { CatalogImageUrlPipe } from './catalog-image-url.pipe';
import { environment } from '../../../environments/environment';

describe('CatalogImageUrlPipe', () => {
  const pipe = new CatalogImageUrlPipe();

  it('should build a pizzeria image URL', () => {
    const result = pipe.transform('my-pizzeria.jpg', 'pizzeria');
    expect(result).toBe(`${environment.apiBaseUrl}/images/pizzerias/my-pizzeria.jpg`);
  });

  it('should encode special characters in the filename', () => {
    const result = pipe.transform('my pizza #1.jpg', 'pizza');
    expect(result).toContain(encodeURIComponent('my pizza #1.jpg'));
  });
});
```

The `environment` import is used directly — the test runs against the default `environment.ts` (not the development override).

> **Illustrative sections in the GUIDE:** Three additional patterns are documented in
> README-TEST-GUIDE.md as `[Illustrative]` sections — @defer blocks, Data Resolvers, and
> Custom Form Controls (ControlValueAccessor). These are not based on realworld-angular
> but are generated from Angular official documentation for reference.

## Coverage Gap Analysis

The following test types are **not present** in this codebase:

| Gap                       | Status         | Notes                                                                                                                                                            |
| ------------------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **E2E tests**             | Missing        | No Cypress, Playwright, or Selenium setup. Full user flows (browse → add to cart → checkout → track order) are not tested end-to-end.                            |
| **Integration tests**     | Missing        | All HTTP calls are mocked with `HttpTestingController`. No tests hit the real API at `api.realworldangular.org`.                                                 |
| **Visual regression**     | Missing        | No screenshot comparison tools (Percy, Chromatic, etc.).                                                                                                         |
| **Performance tests**     | Missing        | No Lighthouse CI, bundle size budgets for tests, or benchmark tests.                                                                                             |
| **Accessibility tests**   | Missing        | No `axe-core`, `pa11y`, or Angular CDK a11y test helpers.                                                                                                        |
| **Route integration**     | Partial        | Guide now documents `RouterTestingHarness` pattern in `README-TEST-GUIDE.md`. Guards tested with `runInInjectionContext()` cover logic but not full integration. |
| **Component harnesses**   | Missing        | No harness usage in 34+ component specs. Guide documents the recommended pattern. See `README-TEST-INSIGHTS.md` for prioritization.                              |
| **Test coverage reports** | Not configured | No coverage thresholds or reporting scripts defined.                                                                                                             |

### Recommendations

If expanding test coverage:

1. **E2E** — Add Playwright (preferred for modern Angular) or Cypress for critical user journeys: browse pizzerias, add to cart, checkout flow, admin panel CRUD, invite-token registration.

2. **Integration** — Add a small suite that hits the deployed API (`api.realworldangular.org`) to verify contract compatibility. These can share the same `describe`/`it` Vitest syntax since Vitest supports async tests natively.

3. **Accessibility** — Integrate `axe-core` into component tests or add a dedicated a11y check in CI. The `web-accessibility-auditor` superpowers skill can also audit pages on demand.

4. **Coverage** — Add Vitest coverage configuration (`coverage.provider: 'v8'` or `istanbul`) with minimum thresholds in CI.

For a prioritized improvement roadmap with timelines, see `README-TEST-INSIGHTS.md`.
