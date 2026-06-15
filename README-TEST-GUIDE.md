# Angular Test Guide

A practical walkthrough of what to test and how to write it, based on the
[realworld-angular](https://github.com/realworld-angular/realworld-angular)
test suite, Angular's official testing documentation, and current Angular
testing guidance.

> **Testing Docs Index:**
>
> - **README-TEST-GUIDE.md** — This file: how to write tests (Angular recommended + project patterns)
> - **README-TEST-AGENT-GUIDE.md** — LLM-facing recipe book for any Angular + Vitest project
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — Angular 22 + PrimeNG v20+ companion cookbook
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists (latest run 59/59 specs pass, 350/350 tests pass)
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

Angular CLI projects now default to **Vitest** with **jsdom**. Run tests with
`ng test`; this sandbox's pinned upstream app is tested with:

```bash
pnpm run test
```

Each section below shows two approaches: the **Angular Recommended** way
(per official docs and the Angular skill references) and the **Project Pattern**
(how realworld-angular currently tests). Choose based on whether you're writing
new tests or maintaining existing ones.

> **Note on "Project Pattern" examples:** the code excerpts under each section are
> representative of how the real `.spec.ts` files in this project are written, not
> always verbatim copies. Use them as a template for the patterns, then refer to the
> actual spec file (linked throughout) for the full test list, including edge cases
> the excerpts omit.

## Current Testing Reality

The upstream `realworld-angular` test suite currently compiles and runs and is **fully green**.
Run the suite with:

```bash
pnpm run test
```

Latest local result: **59/59 specs pass, 350/350 tests pass**. The earlier `PhotonLocationField` failure has been resolved upstream.

This guide documents Angular-recommended patterns and the project's current test patterns. It does **not** claim the suite is production-ready beyond unit tests. Use the checklist below to write better tests; treat any future failures as a separate cleanup task.

## Industry-Standard Testing Checklist

A test is trustworthy when it is deterministic, isolated, and behavior-focused. Use this checklist when writing or reviewing Angular + Vitest tests:

- **HTTP isolation:** use `HttpTestingController` for Angular HTTP calls and `provideHttpClientTesting()`.
- **No leaked requests:** call `httpTesting.verify()` in `afterEach`.
- **Effect flushing:** call `TestBed.flushEffects()` after signal/effect mutations that should trigger reactive work.
- **Stable async waits:** call `await fixture.whenStable()` after input changes, state changes, or async interactions.
- **User-facing assertions:** assert on rendered DOM, emitted values, route results, or state changes, not private fields.
- **Accessibility assertions:** include roles, labels, `aria-*` state, and keyboard-relevant behavior where the UI exposes them.
- **Route integration when it matters:** use `RouterTestingHarness` when the behavior under test is navigation, redirect, guard pipeline, or resolver-to-component data flow.
- **Real imports when integration matters:** prefer real child component imports when the test is about parent/child behavior.
- **Shallow tests when isolation matters:** keep `NO_ERRORS_SCHEMA` for leaf components whose children are tested separately.
- **Negative paths:** cover empty, error, disabled, denied, and invalid states when the component exposes them.
- **No stale providers:** prefer scoped provider setup and `overrideProvider()` when possible; use `TestBed.resetTestingModule()` only when the test truly needs a fresh TestBed inside the same `describe`.

---

## Table of Contents

- [Current Testing Reality](#current-testing-reality)
- [Industry-Standard Testing Checklist](#industry-standard-testing-checklist)
- [Decision Flow: What Do I Test?](#decision-flow-what-do-i-test)
- [Pipes](#pipes)
- [Services](#services)
- [Interceptors](#interceptors)
- [Stores / State](#stores--state)
- [[Illustrative] Reactive Primitives](#illustrative-reactive-primitives)
- [[Illustrative] httpResource](#illustrative-httpresource-with-real-api-hit)
- [Components](#components)
- [Dialogs & Overlays](#dialogs--overlays)
- [[Illustrative] @defer Blocks](#illustrative-defer-blocks)
- [Page Components (Smart / Container)](#page-components-smart--container)
- [Guards](#guards)
- [[Illustrative] Data Resolvers](#illustrative-data-resolvers)
- [Directives](#directives)
- [Forms & Wizard Services](#forms--wizard-services)
- [[Illustrative] Custom Form Controls](#illustrative-custom-form-controls)
- [Route Config Files](#route-config-files)
- [Quick Reference Table](#quick-reference-table)

---

## Decision Flow: What Do I Test?

```
Does the file have runtime behavior (methods, logic, state mutations)?
├── YES → Write a .spec.ts for it. Choose the type below.
└── NO  → Skip it. (models/*.model.ts, *.routes.ts, app.config.ts)

What kind of behavior?
├── HTTP calls, data fetching, business logic → Service test
├── DOM rendering, user interaction, visual output → Component test
├── Routing allow/deny decisions → Guard test
├── Request transformation → Interceptor test
├── Input→output data transformation → Pipe test
├── DOM manipulation via attribute → Directive test (host component)
├── Event emission from component → output() test
├── Root element bindings (role, class, style) → host element test
├── Reactive state with computed signals → Store test
├── Writable derived state with reset logic → linkedSignal test
├── Side effects (logging, sync, canvas) → effect / afterRenderEffect test
└── Multi-step form workflow → Wizard/Service test with real forms

Which approach?
├── Writing new tests? → Use Angular Recommended patterns (harnesses, RouterTestingHarness)
└── Maintaining existing tests? → Use Project Patterns (querySelector, runInInjectionContext)
```

For every unit you test, **cover these states**:

- **Initial state** (what does it look like before anything happens?)
- **Success path** (when everything works)
- **Error / empty / edge case** (when things go wrong)
- **State transition** (reacting to changes)

Also ask what the test is proving. A component test should prove rendered UI or user-facing behavior; a service test should prove request shape and state changes; a guard test should prove allow/deny decisions and exact redirect URLs. If the test only proves an implementation detail, rewrite the assertion toward observable behavior.

---

## Pipes

### What to test

- Correct output for valid input
- Edge cases: empty string, null, special characters
- Encoding/escaping behavior if applicable

### Angular Recommended

Pure pipes are stateless functions — instantiate directly with `new MyPipe()`. No TestBed needed.
This pattern is universally correct and both Angular docs and the project agree.

### Project Pattern

The project follows the same pattern. No gap.

```typescript
import { describe, it, expect } from 'vitest';
import { CatalogImageUrlPipe } from './catalog-image-url.pipe';
import { environment } from '../../../environments/environment';

describe('CatalogImageUrlPipe', () => {
  const pipe = new CatalogImageUrlPipe();

  it('should build a pizzeria image URL', () => {
    const result = pipe.transform('my-pizzeria.jpg', 'pizzeria');
    expect(result).toBe(`${environment.apiBaseUrl}/images/pizzerias/my-pizzeria.jpg`);
  });

  it('should build a pizza image URL', () => {
    const result = pipe.transform('margherita.png', 'pizza');
    expect(result).toBe(`${environment.apiBaseUrl}/images/pizzas/margherita.png`);
  });

  it('should encode special characters in the filename', () => {
    const result = pipe.transform('my pizza #1.jpg', 'pizza');
    expect(result).toContain(encodeURIComponent('my pizza #1.jpg'));
  });

  it('should use the pizzerias segment for pizzeria kind', () => {
    const result = pipe.transform('test.jpg', 'pizzeria');
    expect(result).toContain('/images/pizzerias/');
  });

  it('should use the pizzas segment for pizza kind', () => {
    const result = pipe.transform('test.jpg', 'pizza');
    expect(result).toContain('/images/pizzas/');
  });
});
```

### Key rules

- Pipes are pure stateless functions — instantiate directly with `new MyPipe()`. No TestBed.
- Test output values, not implementation details.
- If the pipe uses a regex, test it thoroughly (Angular docs specifically call this out).
- Optionally add a complementary component test to verify the pipe works in a template binding.
- **Alignment:** ✓ No gap between Angular recommended and project pattern.

### Angular docs reference: [angular.dev/guide/testing/pipes](https://angular.dev/guide/testing/pipes)

---

## Services

### What to test

- Initial state (is it null/empty before any calls?)
- Every public method: verify the correct HTTP endpoint, method, body, and response handling
- Computed signal derivations
- Error handling (what happens on 401, 500, etc.)

### Angular Recommended

Use `HttpTestingController` from `@angular/common/http/testing`. Configure TestBed with
`provideHttpClientTesting()`, inject both the service and `HttpTestingController`, and
call `httpTesting.verify()` in `afterEach` to catch un-flushed requests.

Reference: `angular-developer` skill `testing-fundamentals.md`

### Project Pattern

The realworld-angular project follows this pattern exactly. No gap.

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { Auth } from './auth';
import { User } from '../models/user.model';

const mockUser: User = { id: '1', email: 'test@example.com', role: 'CUSTOMER', name: 'Test User' };
const mockAdmin: User = {
  id: '2',
  email: 'admin@example.com',
  role: 'PIZZERIA_ADMIN',
  name: 'Admin User',
};

describe('Auth', () => {
  let service: Auth;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClientTesting()],
    });
    service = TestBed.inject(Auth);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify(); // catches leaked requests
  });

  // Initial state
  it('should have null user initially', () => {
    expect(service.user()).toBeNull();
  });

  it('should have isAuthenticated false initially', () => {
    expect(service.isAuthenticated()).toBe(false);
  });

  describe('init()', () => {
    it('should set user signal on success', () => {
      service.init().subscribe();
      const req = httpTesting.expectOne('/api/auth/me');
      expect(req.request.method).toBe('GET');
      req.flush(mockUser);
      expect(service.user()).toEqual(mockUser);
      expect(service.isAuthenticated()).toBe(true);
    });

    it('should keep user null on error', () => {
      service.init().subscribe();
      const req = httpTesting.expectOne('/api/auth/me');
      req.flush('Unauthorized', { status: 401, statusText: 'Unauthorized' });
      expect(service.user()).toBeNull();
      expect(service.isAuthenticated()).toBe(false);
    });
  });

  describe('login()', () => {
    it('should POST credentials and update user signal', () => {
      service.login('test@example.com', 'password').subscribe();
      const req = httpTesting.expectOne('/api/auth/login');
      expect(req.request.method).toBe('POST');
      expect(req.request.body).toEqual({ email: 'test@example.com', password: 'password' });
      req.flush(mockUser);
      expect(service.user()).toEqual(mockUser);
    });
  });

  describe('register()', () => {
    it('should POST credentials and update user signal', () => {
      service.register('test@example.com', 'password').subscribe();
      const req = httpTesting.expectOne('/api/auth/register');
      expect(req.request.method).toBe('POST');
      expect(req.request.body).toEqual({ email: 'test@example.com', password: 'password' });
      req.flush(mockUser);
      expect(service.user()).toEqual(mockUser);
    });
  });

  describe('registerPizzeriaOwner()', () => {
    it('should POST to register-pizzeria-owner and update user signal', () => {
      service.registerPizzeriaOwner('owner@example.com', 'password').subscribe();
      const req = httpTesting.expectOne('/api/auth/register-pizzeria-owner');
      expect(req.request.method).toBe('POST');
      req.flush(mockAdmin);
      expect(service.user()).toEqual(mockAdmin);
    });
  });

  describe('logout()', () => {
    it('should POST to logout endpoint', () => {
      service.logout().subscribe();
      const req = httpTesting.expectOne('/api/auth/logout');
      expect(req.request.method).toBe('POST');
      req.flush(null);
    });
  });

  describe('computed signals', () => {
    it('isCustomer should be true when role is CUSTOMER', () => {
      service.user.set(mockUser);
      expect(service.isCustomer()).toBe(true);
      expect(service.isAdmin()).toBe(false);
    });

    it('isAdmin should be true when role is PIZZERIA_ADMIN', () => {
      service.user.set(mockAdmin);
      expect(service.isAdmin()).toBe(true);
      expect(service.isCustomer()).toBe(false);
    });

    it('isAuthenticated should reflect user signal', () => {
      service.user.set(mockUser);
      expect(service.isAuthenticated()).toBe(true);
      service.user.set(null);
      expect(service.isAuthenticated()).toBe(false);
    });
  });
});
```

### Key rules

- Always use `TestBed.inject()` — never `new Auth(httpClient)`. DI wiring must go through TestBed.
- Always call `httpTesting.verify()` in `afterEach` to catch un-flushed requests.
- Test **all four assertions** per endpoint: URL, method, body, and post-response state.
- Test **both** the success and error branches of every HTTP call.
- For services using `httpResource`, see the Angular skill's `resource.md` reference for async reactivity patterns.
- **Alignment:** ✓ No gap between Angular recommended and project pattern.

### Angular docs reference: [angular.dev/guide/testing/services](https://angular.dev/guide/testing/services)

---

## Interceptors

### What to test

- Modifies the outgoing request correctly (e.g., adds headers, transforms URL)
- Does NOT modify requests it should skip
- Handles response transformations (if applicable)

### Angular Recommended

Register the interceptor with `provideHttpClient(withInterceptors([...]))` and use a real
`HttpClient` to make requests that pass through the interceptor. Assert on the resulting
request properties.

### Project Pattern

The project follows this pattern exactly. No gap.

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { HttpClient } from '@angular/common/http';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { credentialsInterceptor } from './credentials.interceptor';

describe('credentialsInterceptor', () => {
  let http: HttpClient;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(withInterceptors([credentialsInterceptor])),
        provideHttpClientTesting(),
      ],
    });
    http = TestBed.inject(HttpClient);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

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

  it('should add withCredentials to non-Photon external requests', () => {
    http.get('https://api.realworldangular.org/api/auth/me').subscribe();
    const req = httpTesting.expectOne('https://api.realworldangular.org/api/auth/me');
    expect(req.request.withCredentials).toBe(true);
    req.flush({});
  });
});
```

### Key rules

- Register the interceptor with `provideHttpClient(withInterceptors([...]))` — it runs through the real pipeline.
- Use a real `HttpClient` to make requests that pass through the interceptor.
- Test the request's **side effects** — modified headers, URL, `withCredentials`, etc.
- Test both "should modify" and "should not modify" branches.
- **Alignment:** ✓ No gap between Angular recommended and project pattern.

---

## Stores / State

### What to test

- Initial state (empty items, null values, isEmpty = true)
- Adding items (state mutates correctly, derived signals update)
- Removing items (state mutates, edge case: removing last item)
- Cross-entity constraints (e.g., can't add items from different pizzerias)
- Side effects (HTTP requests triggered by state changes)
- Negative: no HTTP when state is empty

### Angular Recommended

Angular's `httpResource` is the standard way to fetch data into signal state. When testing
stores that use `httpResource`, the key is to use `TestBed.flushEffects()` to trigger the
reactive pipeline and `HttpTestingController` to intercept the resulting HTTP requests.

Reference: `angular-developer` skill `resource.md`, `effects.md`

### Project Pattern

The realworld-angular `CartStore` tests use `TestBed.flushEffects()` after state mutations
to trigger effect-driven `httpResource` calls. The `httpTesting.match()` pattern is a project
innovation for flushing multiple intermediate requests at once.

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { CartStore, CartData } from './cart.store';

const mockCartData: CartData = {
  pizzeria: { id: 'p1', name: 'Roma', image: 'roma.jpg' },
  items: [
    {
      id: 'item1',
      pizza: { id: 'pizza1', name: 'Margherita', image: 'marg.jpg', basePrice: 9.5 },
      quantity: 2,
      size: { id: 's1', label: 'Large', price: 2 },
      extraToppings: [],
      totalPrice: 23,
    },
  ],
  total: 23,
};

describe('CartStore', () => {
  let store: CartStore;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClientTesting()],
    });
    store = TestBed.inject(CartStore);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  describe('initial state', () => {
    it('should have empty items', () => {
      expect(store.items()).toEqual([]);
    });

    it('should have null pizzeria', () => {
      expect(store.pizzeria()).toBeNull();
    });

    it('should be empty', () => {
      expect(store.isEmpty()).toBe(true);
    });

    it('should not make an HTTP request when cart is empty', () => {
      TestBed.flushEffects();
      httpTesting.expectNone(() => true);
    });
  });

  describe('addItem()', () => {
    it('should add an item and set the pizzeria', () => {
      store.addItem('pizza1', 1, 's1', [], 'p1');
      expect(store.items().length).toBe(1);
      expect(store.pizzeria()).toEqual({ id: 'p1' });
      expect(store.isEmpty()).toBe(false);
    });

    it('should increment quantity when adding same item again', () => {
      store.addItem('pizza1', 1, 's1', [], 'p1');
      store.addItem('pizza1', 2, 's1', [], 'p1');
      expect(store.items().length).toBe(1);
      expect(store.items()[0].quantity).toBe(3);
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
    });

    it('should clear and reset when adding item from different pizzeria', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      store.addItem('pizza2', 1, null, [], 'p2');
      expect(store.pizzeria()).toEqual({ id: 'p2' });
      expect(store.items().length).toBe(1);
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
    });

    it('should trigger a POST to /api/orders/cart after adding item', () => {
      store.addItem('pizza1', 1, 's1', [], 'p1');
      void store.cart();
      TestBed.flushEffects();
      const req = httpTesting.expectOne((r) => r.url.includes('/api/orders/cart'));
      expect(req.request.method).toBe('POST');
      expect(req.request.body.pizzeriaId).toBe('p1');
      req.flush(mockCartData);
    });
  });

  describe('updateQuantity()', () => {
    beforeEach(() => {
      store.addItem('pizza1', 2, null, [], 'p1');
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
    });

    it('should update the quantity of an existing item', () => {
      const itemId = store.items()[0].id;
      store.updateQuantity(itemId, 5);
      expect(store.items()[0].quantity).toBe(5);
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
    });

    it('should remove item when quantity set to 0', () => {
      const itemId = store.items()[0].id;
      store.updateQuantity(itemId, 0);
      expect(store.items().length).toBe(0);
      expect(store.isEmpty()).toBe(true);
    });
  });

  describe('removeItem()', () => {
    it('should remove the item from the cart', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
      const itemId = store.items()[0].id;
      store.removeItem(itemId);
      expect(store.items().length).toBe(0);
    });

    it('should clear pizzeria when last item is removed', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
      const itemId = store.items()[0].id;
      store.removeItem(itemId);
      expect(store.pizzeria()).toBeNull();
    });
  });

  describe('clear()', () => {
    it('should reset items and pizzeria', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
      store.clear();
      expect(store.items()).toEqual([]);
      expect(store.pizzeria()).toBeNull();
      expect(store.isEmpty()).toBe(true);
    });
  });

  describe('hasItemsForOtherPizzeria()', () => {
    it('should return false when cart is empty', () => {
      expect(store.hasItemsForOtherPizzeria('p1')).toBe(false);
    });

    it('should return false when pizzeria matches', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
      expect(store.hasItemsForOtherPizzeria('p1')).toBe(false);
    });

    it('should return true when pizzeria differs', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      httpTesting
        .match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
      expect(store.hasItemsForOtherPizzeria('p2')).toBe(true);
    });
  });

  describe('cart value from httpResource', () => {
    it('should post cart body with correct pizzeriaId and items', () => {
      store.addItem('pizza1', 2, 's1', ['t1'], 'p1');
      void store.cart();
      TestBed.flushEffects();
      const req = httpTesting.expectOne((r) => r.url.includes('/api/orders/cart'));
      expect(req.request.body.pizzeriaId).toBe('p1');
      expect(req.request.body.items[0].pizzaId).toBe('pizza1');
      expect(req.request.body.items[0].quantity).toBe(2);
      req.flush(mockCartData);
    });

    it('should not make a request when cart returns undefined (empty)', () => {
      TestBed.flushEffects();
      httpTesting.expectNone((r) => r.url.includes('/api/orders/cart'));
    });
  });
});
```

### Key rules

- `TestBed.flushEffects()` after state changes to trigger effect-driven HTTP.
- `httpTesting.match()` for multi-request scenarios — flush all pending cart requests at once.
- `httpTesting.expectNone()` for asserting no requests should fire.
- Test **domain constraints** (same pizzeria, quantity merges) — these are the business rules.
- **Alignment:** ✓ Mostly aligned. The project's `httpTesting.match()` pattern is a useful
  innovation not directly covered by Angular docs.

---

## [Illustrative] httpResource

> **Not based on realworld-angular** — illustrative example generated from Angular official documentation.

`httpResource` is Angular's reactive wrapper around `HttpClient`: you give it a function
that returns a URL, and it exposes `value()`, `hasValue()`, `isLoading()`, and `error()`
as signals. It's eager (fires on creation, not on subscription) and cancels in-flight
requests when its source signals change. Because it builds on `HttpClient`, it supports
all the same features (interceptors, headers, params) — and tests use the same
`HttpTestingController` as the [Services](#services) section.

### What to test

- Initial state — `isLoading()` is true, `hasValue()` is false before the response
- Success path — response lands, `value()` matches the payload, `isLoading()` is false
- Reactive reload — when the source signal changes, a new request fires with the new URL
- Error path — `error()` is set when the request fails, `hasValue()` stays false

### Project Pattern

The pattern matches the project's existing `HttpTestingController` usage exactly. Use
`TestBed.flushEffects()` for effect-driven `httpResource` behavior, then assert on the
resource signals after stabilization. The `injector` option binds the resource to the
test's `TestBed` injector so it sees the mock backend.

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { ApplicationRef, Injector, signal } from '@angular/core';
import { httpResource } from '@angular/common/http';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { TodoComponent } from './todo.component';

describe('TodoComponent (httpResource)', () => {
  let httpTesting: HttpTestingController;
  let injector: Injector;
  let appRef: ApplicationRef;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    httpTesting = TestBed.inject(HttpTestingController);
    injector = TestBed.inject(Injector);
    appRef = TestBed.inject(ApplicationRef);
  });

  afterEach(() => {
    httpTesting.verify(); // catches leaked requests
  });

  it('should fetch a todo and expose it on the resource', async () => {
    // Reproduce the component's resource binding inside the test injector
    const id = signal(1);
    const todo = httpResource(() => `https://jsonplaceholder.typicode.com/todos/${id()}`, {
      injector,
    });

    TestBed.tick(); // fire the initial effect
    const req = httpTesting.expectOne('https://jsonplaceholder.typicode.com/todos/1');
    expect(req.request.method).toBe('GET');

    req.flush({ id: 1, title: 'delectus aut autem', completed: false });
    await appRef.whenStable(); // let values propagate to the resource

    expect(todo.hasValue()).toBe(true);
    expect(todo.isLoading()).toBe(false);
    expect(todo.value()).toEqual({ id: 1, title: 'delectus aut autem', completed: false });
  });

  it('should reload when the source signal changes', async () => {
    const id = signal(1);
    const todo = httpResource(() => `https://jsonplaceholder.typicode.com/todos/${id()}`, {
      injector,
    });

    TestBed.tick();
    httpTesting.expectOne('/todos/1').flush({ id: 1, title: 'first', completed: true });
    await appRef.whenStable();

    id.set(2);
    TestBed.tick();
    httpTesting.expectOne('/todos/2').flush({ id: 2, title: 'second', completed: false });
    await appRef.whenStable();

    expect(todo.value()).toEqual({ id: 2, title: 'second', completed: false });
  });

  it('should surface server errors via the error() signal', async () => {
    const id = signal(1);
    const todo = httpResource(() => `https://jsonplaceholder.typicode.com/todos/${id()}`, {
      injector,
    });

    TestBed.tick();
    httpTesting.expectOne('/todos/1').flush('boom', { status: 500, statusText: 'Server Error' });
    await appRef.whenStable();

    expect(todo.error()).toBeTruthy();
    expect(todo.hasValue()).toBe(false);
  });
});
```

When the resource lives inside a real component fixture, the pattern is the same but
you trigger the request through the component rather than reconstructing the resource
in the test:

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { TodoComponent } from './todo.component';

describe('TodoComponent (full fixture)', () => {
  let fixture: ComponentFixture<TodoComponent>;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    fixture = TestBed.createComponent(TodoComponent);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should render the todo title after loading', async () => {
    httpTesting
      .expectOne('https://jsonplaceholder.typicode.com/todos/1')
      .flush({ id: 1, title: 'delectus aut autem', completed: false });
    await fixture.whenStable();
    expect(fixture.nativeElement.textContent).toContain('delectus aut autem');
  });
});
```

### Key rules

- **Always pass the test injector:** `httpResource(url, { injector })` — without it the
  resource binds to the wrong injector and won't see `HttpTestingController`.
- **Trigger and stabilize:** call `TestBed.tick()` to fire the initial effect, then
  `await appRef.whenStable()` (or `await fixture.whenStable()` for a fixture-based test)
  before reading `value()` / `error()` — values propagate through change detection.
- **Read `value()` only when `hasValue()` is true** — Angular throws at runtime if you
  read `value()` while in an error state.
- **Assert on `isLoading()`, `hasValue()`, `error()`, and `value()`** — these are the four
  signals `httpResource` exposes. Pick whichever is most relevant to the test.
- **Reactive reload is implicit** — when the URL function's source signals change,
  `httpResource` cancels the in-flight request and fires a new one. Use
  `TestBed.flushEffects()` after a signal change to flush the new request.
- **Alignment:** ✓ Project pattern matches Angular recommended. `httpResource` is a wrapper
  around `HttpClient`, so it uses the exact same test APIs.

### Angular docs reference: [angular.dev/guide/http/http-resource#testing-an-httpresource](https://angular.dev/guide/http/http-resource#testing-an-httpresource)

---

## [Illustrative] Reactive Primitives

> **Note:** The topics in this section are not yet exercised in the realworld-angular test
> suite. The examples below use a fictional `ShippingPicker` component and are generated from
> the `angular-developer` skill references (`linked-signal.md`, `effects.md`).

### What to test

- **linkedSignal:** Default value derived from source; manual overrides; reset when source
  changes; preserve override when value still valid in new source
- **effect:** Runs at least once; re-runs when tracked signals change; cleanup function
  executes before next run; does NOT propagate state changes (use `computed`/`linkedSignal` instead)
- **afterRenderEffect:** Correct phase ordering (earlyRead → write → mixedReadWrite → read);
  write phase receives data from prior read phase; never runs during SSR

### [Illustrative] linkedSignal

```typescript
import { Component, signal, linkedSignal } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

@Component({
  selector: 'app-shipping-picker',
  template: `
    <select (change)="onChange($event)">
      @for (opt of shippingOptions(); track opt) {
        <option [value]="opt">{{ opt }}</option>
      }
    </select>
  `,
})
class ShippingPicker {
  readonly shippingOptions = signal(['Ground', 'Air', 'Sea']);
  readonly selectedOption = linkedSignal(() => this.shippingOptions()[0]);

  onChange(event: Event) {
    const select = event.target as HTMLSelectElement;
    this.selectedOption.set(select.value);
  }
}

describe('ShippingPicker (linkedSignal)', () => {
  let component: ShippingPicker;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    const fixture = TestBed.createComponent(ShippingPicker);
    component = fixture.componentInstance;
  });

  it('should default to the first shipping option', () => {
    expect(component.selectedOption()).toBe('Ground');
  });

  it('should allow manual override', () => {
    component.selectedOption.set('Air');
    expect(component.selectedOption()).toBe('Air');
  });

  it('should reset to first option when source signal changes', () => {
    component.selectedOption.set('Air');
    component.shippingOptions.set(['Express', 'Overnight', 'Drone']);
    TestBed.flushEffects();
    expect(component.selectedOption()).toBe('Express');
  });
});
```

Reference: `angular-developer` skill `linked-signal.md`

### [Illustrative] effect & afterRenderEffect

```typescript
import { Component, signal, effect, afterRenderEffect, Injector, effect } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

describe('effect', () => {
  it('should run at least once', () => {
    const counter = signal(0);
    let runs = 0;
    TestBed.runInInjectionContext(() => {
      effect(() => {
        counter(); // track this signal
        runs++;
      });
    });
    TestBed.flushEffects();
    expect(runs).toBe(1);
  });

  it('should re-run when a tracked signal changes', () => {
    const counter = signal(0);
    let captured = 0;
    TestBed.runInInjectionContext(() => {
      effect(() => {
        captured = counter();
      });
    });
    TestBed.flushEffects();
    counter.set(42);
    TestBed.flushEffects();
    expect(captured).toBe(42);
  });

  it('should run cleanup before the next execution', () => {
    const counter = signal(0);
    const cleaned: number[] = [];
    TestBed.runInInjectionContext(() => {
      effect((onCleanup) => {
        const val = counter();
        onCleanup(() => cleaned.push(val));
      });
    });
    TestBed.flushEffects();
    counter.set(1);
    TestBed.flushEffects();
    expect(cleaned).toEqual([0]); // cleanup captured value from first run
  });
});

describe('afterRenderEffect', () => {
  it('should execute phases in order', async () => {
    const source = signal(100);
    let writeReceived = 0;
    const fixture = TestBed.createComponent(
      class {
        constructor() {
          afterRenderEffect({
            earlyRead: () => source(),
            write: (w) => {
              writeReceived = w;
            },
          });
        }
      },
    );
    await fixture.whenStable();
    expect(writeReceived).toBe(100);
  });
});
```

### [Illustrative] resource & httpResource

> **Note:** Not yet exercised directly in the realworld-angular test suite. The project's
> `CartStore` uses `httpResource` under the hood but tests it indirectly through store
> mutations. The example below tests `resource()` directly using a fictional `UserLoader`.

```typescript
import { resource, signal } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('resource', () => {
  it('should start in loading state', () => {
    const userId = signal('123');
    let resolveLoader: (v: unknown) => void;
    const loaderPromise = new Promise((r) => (resolveLoader = r));

    const userResource = TestBed.runInInjectionContext(() =>
      resource({
        params: () => ({ id: userId() }),
        loader: async () => loaderPromise,
      }),
    );

    TestBed.flushEffects();
    expect(userResource.isLoading()).toBe(true);
    expect(userResource.hasValue()).toBe(false);
  });

  it('should resolve to a value when loader completes', async () => {
    const userId = signal('123');
    const mockUser = { id: '123', name: 'Alice' };

    const userResource = TestBed.runInInjectionContext(() =>
      resource({
        params: () => ({ id: userId() }),
        loader: async ({ params }) => mockUser,
      }),
    );

    TestBed.flushEffects();
    // Let the loader promise resolve
    await vi.waitFor(() => userResource.hasValue());
    expect(userResource.value()).toEqual(mockUser);
    expect(userResource.status()).toBe('resolved');
  });

  it('should reload when params change', () => {
    const userId = signal('123');
    let callCount = 0;

    TestBed.runInInjectionContext(() =>
      resource({
        params: () => ({ id: userId() }),
        loader: async ({ params }) => {
          callCount++;
          return { id: params.id, name: 'User' };
        },
      }),
    );

    TestBed.flushEffects();
    userId.set('456');
    TestBed.flushEffects();
    expect(callCount).toBe(2);
  });

  it('should handle loader errors', async () => {
    const userId = signal('123');

    const userResource = TestBed.runInInjectionContext(() =>
      resource({
        params: () => ({ id: userId() }),
        loader: async () => {
          throw new Error('Network failure');
        },
      }),
    );

    TestBed.flushEffects();
    await vi.waitFor(() => userResource.status() === 'error');
    expect(userResource.error()).toBeInstanceOf(Error);
  });
});
```

**httpResource testing:** For `httpResource` (which uses Angular's `HttpClient`), use
`HttpTestingController` exactly as shown in the [Services](#services) section — the pattern
is identical: `expectOne()` → assert method/body → `flush()` → assert signal state.

Reference: `angular-developer` skill `resource.md`

### Key rules

- `effect()` and `afterRenderEffect()` must be created inside an injection context
  (constructor or `runInInjectionContext`).
- Use `TestBed.flushEffects()` to synchronously flush pending effects and resource loading in tests.
- Use `TestBed.runInInjectionContext()` to create effects/resources outside a component constructor.
- For `afterRenderEffect`, call `await fixture.whenStable()` to let the render cycle complete.
- **Never** use `effect` to propagate state between signals — use `computed()` or
  `linkedSignal()` instead. This is a critical Angular rule.
- **resource() status flow:** `idle` → `loading` → `resolved` (or `error`). When the
  value is set locally via `.set()` or `.update()`, status becomes `local`. Use
  `vi.waitFor()` for async resolution in Vitest.
- **Resource loader params:** the loader receives `{ params, previous, abortSignal }`.
  Use `abortSignal` to cancel in-flight work when params change.
- **Alignment:** N/A — standalone `resource()` and `afterRenderEffect` are not exercised
  in the realworld-angular test suite. The examples above are illustrative per the
  `angular-developer` skill references. `httpResource` testing is covered in Stores.

### Angular docs reference

- [angular.dev/guide/signals/linked-signal](https://angular.dev/guide/signals/linked-signal)
- [angular.dev/guide/signals/effect](https://angular.dev/guide/signals/effect)
- [angular.dev/guide/signals/resource](https://angular.dev/guide/signals/resource)
- [angular.dev/api/core/testing/TestBed#flushEffects](https://angular.dev/api/core/testing/TestBed#flushEffects)

---

## Components

### What to test

- Renders the correct DOM structure given its inputs
- Applies correct CSS classes based on input values
- Shows/hides elements based on state
- Emits outputs on user interaction
- Sets correct ARIA attributes (accessibility is a first-class assertion)
- Disabled / loading / active states

### Angular Recommended — Component Harnesses

Component harnesses are the standard, preferred way to interact with components in tests.
They provide a user-centric API that insulates tests from internal DOM changes.

Reference: `angular-developer` skill `component-harnesses.md`

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { TestbedHarnessEnvironment, HarnessLoader } from '@angular/cdk/testing/testbed';
import { describe, it, expect, beforeEach } from 'vitest';
import { Button } from './button';
import { ButtonHarness } from './testing/button-harness';

describe('Button (with harness)', () => {
  let fixture: ComponentFixture<Button>;
  let loader: HarnessLoader;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(Button);
    loader = TestbedHarnessEnvironment.loader(fixture);
  });

  it('should apply variant and palette classes', async () => {
    fixture.componentRef.setInput('variant', 'outlined');
    fixture.componentRef.setInput('palette', 'danger');
    const harness = await loader.getHarness(ButtonHarness);
    expect(await harness.getCssClass()).toContain('btn--outlined-danger');
  });

  it('should be disabled when isDisabled is true', async () => {
    fixture.componentRef.setInput('isDisabled', true);
    const harness = await loader.getHarness(ButtonHarness);
    expect(await harness.isDisabled()).toBe(true);
  });

  it('should show loading state and set aria-busy', async () => {
    fixture.componentRef.setInput('isLoading', true);
    const harness = await loader.getHarness(ButtonHarness);
    expect(await harness.isLoading()).toBe(true);
    expect(await harness.getAriaAttribute('aria-busy')).toBe('true');
  });
});
```

A custom harness for Button might look like:

```typescript
// src/app/shared/components/button/testing/button-harness.ts
import { ComponentHarness } from '@angular/cdk/testing';

export class ButtonHarness extends ComponentHarness {
  static hostSelector = 'button, [rw-button]';

  async getCssClass(): Promise<string> {
    const host = await this.host();
    return (await host.getAttribute('class')) ?? '';
  }

  async isDisabled(): Promise<boolean> {
    const host = await this.host();
    return (await host.getProperty('disabled')) === true;
  }

  async isLoading(): Promise<boolean> {
    const host = await this.host();
    return (
      (await host.hasClass('btn--loading')) || (await host.getAttribute('aria-busy')) === 'true'
    );
  }

  async getAriaAttribute(name: string): Promise<string | null> {
    return (await this.host()).getAttribute(name);
  }
}
```

### Project Pattern — querySelector + NO_ERRORS_SCHEMA

The realworld-angular project uses `querySelector` for DOM access and `NO_ERRORS_SCHEMA`
to ignore child component selectors. This is simpler but more brittle — template refactors
can silently break tests.

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { describe, it, expect, beforeEach } from 'vitest';
import { Button } from './button';

describe('Button', () => {
  let fixture: ComponentFixture<Button>;
  let el: HTMLElement;
  let buttonEl: HTMLButtonElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({}).overrideComponent(Button, {
      set: { schemas: [NO_ERRORS_SCHEMA] },
    });
    fixture = TestBed.createComponent(Button);
    el = fixture.nativeElement;
    buttonEl = el.querySelector('button')!;
    await fixture.whenStable();
  });

  it('should render a button element', () => {
    expect(buttonEl).not.toBeNull();
  });

  it('should apply variant and palette classes', async () => {
    fixture.componentRef.setInput('variant', 'outlined');
    fixture.componentRef.setInput('palette', 'danger');
    await fixture.whenStable();
    expect(buttonEl.className).toContain('btn--outlined-danger');
  });

  it('should apply size class', async () => {
    fixture.componentRef.setInput('size', 'sm');
    await fixture.whenStable();
    expect(buttonEl.className).toContain('btn--sm');
  });

  it('should set type attribute', async () => {
    fixture.componentRef.setInput('type', 'submit');
    await fixture.whenStable();
    expect(buttonEl.type).toBe('submit');
  });

  it('should be disabled when isDisabled is true', async () => {
    fixture.componentRef.setInput('isDisabled', true);
    await fixture.whenStable();
    expect(buttonEl.disabled).toBe(true);
  });

  it('should show loading spinner when isLoading is true', async () => {
    fixture.componentRef.setInput('isLoading', true);
    await fixture.whenStable();
    expect(buttonEl.querySelector('.btn-spinner')).not.toBeNull();
    expect(buttonEl.getAttribute('aria-busy')).toBe('true');
  });

  it('should be disabled when isLoading is true', async () => {
    fixture.componentRef.setInput('isLoading', true);
    await fixture.whenStable();
    expect(buttonEl.disabled).toBe(true);
  });

  it('should project content', () => {
    expect(el.textContent).toContain('');
  });
});
```

### Decision Rule

| Situation                                             | Use                                                                      |
| ----------------------------------------------------- | ------------------------------------------------------------------------ |
| Shared component library (Button, Input, Modal)       | **Harnesses** — consumed by many tests, template changes cascade         |
| One-off component or page component                   | **querySelector** — harness overhead not justified for a single consumer |
| Test needs to verify a child component's internal DOM | **querySelector** or `fixture.debugElement.query(By.directive(...))`     |
| New project or high-value shared component            | **Harnesses** — start with the modern approach                           |

### NO_ERRORS_SCHEMA Guidance

- **Use when:** testing a leaf component in isolation where child components have their own tests.
- **Avoid when:** the test needs to verify parent/child integration. Use explicit `imports: [ChildA, ChildB]` instead.
- **Angular docs warn** that blanket `NO_ERRORS_SCHEMA` usage hides real template errors.
- **Project reality:** the current suite uses shallow rendering heavily, which is valid for leaf components but means page specs do not prove child integration.

### Key rules

- Use `NO_ERRORS_SCHEMA` to ignore child component selectors. Each component has its own tests.
- Set signal-based inputs with `fixture.componentRef.setInput('name', value)`.
- `await fixture.whenStable()` after every async change (input set, state toggle).
- Test accessibility attributes (`aria-*`, `role`) as assertions — not an afterthought.
- **Alignment:** ⚠ Project uses `querySelector` where Angular recommends harnesses.
  See `README-TEST-INSIGHTS.md` for the improvement roadmap.
- **Signal outputs:** Subscribe via `.subscribe()` on the `OutputEmitterRef`. Clean up with
  `.unsubscribe()` or let Angular handle it on component destroy.
- **Host bindings:** Test directly on `fixture.nativeElement` — the root element IS the
  host element. Use `await fixture.whenStable()` to let bindings propagate.
- **Host events:** Trigger with `fixture.nativeElement.dispatchEvent(new KeyboardEvent(...))`.

### [Illustrative] Signal Outputs

> **Note:** Not yet exercised in the realworld-angular test suite. Example uses a fictional
> `TodoList` component.

```typescript
import { Component, output, input } from '@angular/core';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

@Component({
  selector: 'app-todo-list',
  template: `
    @for (item of items(); track item) {
      <button (click)="remove.emit(item)">Remove {{ item }}</button>
    }
  `,
})
class TodoList {
  readonly items = input<string[]>([]);
  readonly remove = output<string>();
}

describe('TodoList (signal output)', () => {
  let fixture: ComponentFixture<TodoList>;
  let component: TodoList;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(TodoList);
    component = fixture.componentInstance;
  });

  it('should emit the removed item through the signal output', () => {
    fixture.componentRef.setInput('items', ['Buy milk', 'Walk dog']);
    const emitted: string[] = [];
    const sub = component.remove.subscribe((item) => emitted.push(item));

    // Simulate clicking the first remove button
    const buttons = fixture.nativeElement.querySelectorAll('button');
    (buttons[0] as HTMLButtonElement).click();

    expect(emitted).toEqual(['Buy milk']);
    sub.unsubscribe();
  });
});
```

### [Illustrative] Host Element Bindings

> **Note:** Not yet exercised in the realworld-angular test suite. Example uses a fictional
> `ToggleChip` component with `host:` bindings.

```typescript
import { Component, input, output } from '@angular/core';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

@Component({
  selector: 'app-toggle-chip',
  template: `{{ label() }}`,
  host: {
    role: 'switch',
    '[attr.aria-checked]': 'checked()',
    '[class.chip--active]': 'checked()',
    '[style.borderColor]': 'checked() ? "green" : "gray"',
  },
})
class ToggleChip {
  readonly label = input.required<string>();
  readonly checked = input(false);
}

describe('ToggleChip (host bindings)', () => {
  let fixture: ComponentFixture<ToggleChip>;
  let el: HTMLElement;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(ToggleChip);
    el = fixture.nativeElement;
  });

  it('should apply static host attribute (role)', () => {
    expect(el.getAttribute('role')).toBe('switch');
  });

  it('should reflect aria-checked from input signal', async () => {
    fixture.componentRef.setInput('checked', true);
    await fixture.whenStable();
    expect(el.getAttribute('aria-checked')).toBe('true');
  });

  it('should toggle CSS class from input signal', async () => {
    expect(el.classList.contains('chip--active')).toBe(false);
    fixture.componentRef.setInput('checked', true);
    await fixture.whenStable();
    expect(el.classList.contains('chip--active')).toBe(true);
  });

  it('should update inline style from input signal', async () => {
    fixture.componentRef.setInput('checked', true);
    await fixture.whenStable();
    expect(el.style.borderColor).toBe('green');
  });
});
```

### Angular docs reference: [angular.dev/guide/testing/components-basics](https://angular.dev/guide/testing/components-basics)

---

## Dialogs & Overlays

### What to test

- Dialog renders content from injected `DIALOG_DATA`
- Close button calls `DialogRef.close()` with or without a result
- ARIA attributes on the overlay panel (`role="document"`, `aria-label`)
- Conditional rendering when optional data fields are missing
- Form submission inside a dialog (HTTP + close interaction)

### Angular Recommended

For dialogs built with `@angular/cdk/dialog`, stub the `DialogRef` and provide test data
via `DIALOG_DATA` injection token. Use `vi.fn()` for the close method to assert close behavior.
For Angular Material dialogs, use the CDK testing harnesses.

Reference: `angular-developer` skill `testing-fundamentals.md`

### Project Pattern

The realworld-angular project uses `DialogRef` + `DIALOG_DATA` stubs with `NO_ERRORS_SCHEMA`
for dialog chrome. The `PizzaOrderFormDialog` test adds real component imports for form integration.

**Example 1: Simple dialog (Modal)**

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { DialogRef } from '@angular/cdk/dialog';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Modal } from './modal';

describe('Modal', () => {
  let fixture: ComponentFixture<Modal>;
  let el: HTMLElement;
  let closeFn: ReturnType<typeof vi.fn>;

  beforeEach(async () => {
    closeFn = vi.fn();
    TestBed.configureTestingModule({
      providers: [{ provide: DialogRef, useValue: { close: closeFn } }],
    }).overrideComponent(Modal, { set: { schemas: [NO_ERRORS_SCHEMA] } });
    fixture = TestBed.createComponent(Modal);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render the title from input', async () => {
    fixture.componentRef.setInput('title', 'Confirm action');
    await fixture.whenStable();
    expect(el.textContent).toContain('Confirm action');
  });

  it('should close dialog when close button is clicked', () => {
    el.querySelector<HTMLButtonElement>('[aria-label="Close dialog"]')!.click();
    expect(closeFn).toHaveBeenCalled();
  });

  it('should have role document on the panel', () => {
    expect(el.querySelector('[role="document"]')).not.toBeNull();
  });
});
```

**Example 2: Dialog with injected data (ConfirmDialog)**

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { NO_ERRORS_SCHEMA } from '@angular/core';
import { DIALOG_DATA, DialogRef } from '@angular/cdk/dialog';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { ConfirmDialog, ConfirmDialogData, ConfirmDialogResult } from './confirm-dialog';

describe('ConfirmDialog', () => {
  let fixture: ComponentFixture<ConfirmDialog>;
  let el: HTMLElement;
  let closeFn: ReturnType<typeof vi.fn>;

  const defaultData: ConfirmDialogData = {
    title: 'Are you sure?',
    message: 'This action cannot be undone.',
    confirmLabel: 'Confirm',
    cancelLabel: 'Cancel',
  };

  beforeEach(async () => {
    closeFn = vi.fn();
    TestBed.configureTestingModule({
      providers: [
        { provide: DialogRef<ConfirmDialogResult>, useValue: { close: closeFn } },
        { provide: DIALOG_DATA, useValue: defaultData },
      ],
    }).overrideComponent(ConfirmDialog, { set: { schemas: [NO_ERRORS_SCHEMA] } });
    fixture = TestBed.createComponent(ConfirmDialog);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render the title from data', () => {
    expect(el.textContent).toContain('Are you sure?');
  });

  it('should render the message from data', () => {
    expect(el.textContent).toContain('This action cannot be undone.');
  });

  it('should render cancel and confirm buttons', () => {
    expect(el.textContent).toContain('Cancel');
    expect(el.textContent).toContain('Confirm');
  });

  it('should not show message when not provided', async () => {
    TestBed.resetTestingModule();
    closeFn = vi.fn();
    TestBed.configureTestingModule({
      providers: [
        { provide: DialogRef<ConfirmDialogResult>, useValue: { close: closeFn } },
        { provide: DIALOG_DATA, useValue: { title: 'Test' } },
      ],
    }).overrideComponent(ConfirmDialog, { set: { schemas: [NO_ERRORS_SCHEMA] } });
    fixture = TestBed.createComponent(ConfirmDialog);
    el = fixture.nativeElement;
    await fixture.whenStable();
    expect(el.querySelector('.confirm-dialog__message')).toBeNull();
  });
});
```

**Example 3: Dialog with form + HTTP (PizzaOrderFormDialog)**

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { DialogRef, DIALOG_DATA } from '@angular/cdk/dialog';
import { PizzaOrderFormDialog } from './pizza-order-form-dialog';
import { PizzaOrderFormDialogData } from '../../order.models';
import { Pizza } from '../../../pizzerias/models/pizza.models';
import { DecimalPipe, NgOptimizedImage } from '@angular/common';
import { FormField } from '@angular/forms/signals';
import { CatalogImageUrlPipe } from '../../../../shared/pipes/catalog-image-url.pipe';
import { Button } from '../../../../shared/components/button/button';
import { Modal } from '../../../../shared/components/modal/modal';
import { Input } from '../../../../shared/components/input/input';
import { Spinner } from '../../../../shared/components/spinner/spinner';
import { SizeOptionField } from '../pizza-size-option-field/pizza-size-option-field';

const mockPizza: Pizza = {
  id: 'pizza1',
  name: 'Margherita',
  basePrice: 9.5,
  image: 'marg.jpg',
  createdAt: '2024-01-01',
  toppings: [{ id: 't1', label: 'Mozzarella', price: 0, sortOrder: 1 }],
};

const dialogData: PizzaOrderFormDialogData = {
  pizza: mockPizza,
  pizzeriaId: 'p1',
  displayPizzeriaName: 'Roma',
};

describe('PizzaOrderFormDialog', () => {
  let fixture: ComponentFixture<PizzaOrderFormDialog>;
  let el: HTMLElement;
  let httpTesting: HttpTestingController;
  let closeFn: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    closeFn = vi.fn();
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
          FormField,
        ],
      },
    });
    fixture = TestBed.createComponent(PizzaOrderFormDialog);
    el = fixture.nativeElement;
    httpTesting = TestBed.inject(HttpTestingController);
    TestBed.flushEffects();
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should load sizes and toppings on init', () => {
    httpTesting.expectOne('/api/options/sizes').flush([]);
    httpTesting.expectOne('/api/options/toppings').flush([]);
  });

  it('should close dialog on form submission', async () => {
    httpTesting
      .expectOne('/api/options/sizes')
      .flush([{ id: 's1', label: 'Medium', price: 1, sortOrder: 1 }]);
    httpTesting.expectOne('/api/options/toppings').flush([]);
    await fixture.whenStable();
    TestBed.flushEffects();

    // Select a size (required by form validation)
    const sizeDe = fixture.debugElement.query(
      (de) => de.componentInstance instanceof SizeOptionField,
    );
    sizeDe.componentInstance.value.set({ id: 's1', label: 'Medium', price: 1 });
    TestBed.flushEffects();

    el.querySelector<HTMLButtonElement>('button[type="submit"]')!.click();
    TestBed.flushEffects();
    httpTesting.expectOne('/api/orders/cart').flush({});

    expect(closeFn).toHaveBeenCalled();
  });
});
```

### Key rules

- Stub `DialogRef` with `{ close: vi.fn() }` — the simplest useful stub.
- Provide `DIALOG_DATA` as a plain object — no need for the real injection token class.
- Prefer scoped provider setup or `overrideProvider()` when reconfiguring providers with different data within the same `describe`; use `TestBed.resetTestingModule()` only when a fresh TestBed is truly needed.
- For dialogs with real forms, use real `imports` instead of `NO_ERRORS_SCHEMA` so that `FormField` directives wire up correctly.
- Test the close flow: user action → `expect(closeFn).toHaveBeenCalled()`.
- Test ARIA: dialog panel should have `role="document"` or `role="dialog"`, close button should have `aria-label`.
- **Alignment:** ✓ Project pattern matches Angular recommended for dialog testing. Both use `DialogRef` + `DIALOG_DATA` stubs.

### Angular docs reference: [material.angular.io/cdk/dialog/overview](https://material.angular.io/cdk/dialog/overview)

---

## [Illustrative] @defer Blocks

> **Not based on realworld-angular** — illustrative example generated from Angular official documentation.

### What to test

- Deferred content is NOT rendered before the trigger condition is met
- Placeholder content IS rendered before the trigger
- Loading state renders when deferred content is being fetched
- Deferred content renders after the trigger activates
- Error state renders if deferred loading fails

### Angular Recommended

Angular provides `DeferBlockBehavior.Manual` in `TestBed` to step through `@defer` block states.
Use `fixture.getDeferBlocks()` to retrieve defer block fixtures, then call
`deferBlockFixture.render(DeferBlockState.X)` to manually control state transitions.

Reference: `angular-developer` skill `testing-fundamentals.md`

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Component } from '@angular/core';
import { DeferBlockBehavior, DeferBlockState } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';

@Component({
  selector: 'app-heavy',
  template: '<p>Heavy component loaded!</p>',
})
class HeavyComponent {}

@Component({
  imports: [HeavyComponent],
  template: `
    @defer (when isReady) {
      <app-heavy />
    } @placeholder {
      <p>Placeholder content</p>
    } @loading {
      <p>Loading...</p>
    } @error {
      <p>Failed to load</p>
    }
  `,
})
class TestDeferComponent {
  isReady = false;
}

describe('@defer blocks', () => {
  let fixture: ComponentFixture<TestDeferComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      deferBlockBehavior: DeferBlockBehavior.Manual,
    });
    fixture = TestBed.createComponent(TestDeferComponent);
  });

  it('should render placeholder by default', async () => {
    // In Manual mode, the defer block starts in Placeholder state — no render() needed
    expect(fixture.nativeElement.innerHTML).toContain('Placeholder content');
  });

  it('should render loading state', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Loading);
    expect(fixture.nativeElement.innerHTML).toContain('Loading...');
  });

  it('should render deferred content in complete state', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Complete);
    expect(fixture.nativeElement.innerHTML).toContain('Heavy component loaded!');
  });

  it('should render error state when deferred load fails', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Error);
    expect(fixture.nativeElement.innerHTML).toContain('Failed to load');
  });
});
```

### Key rules

- Set `deferBlockBehavior: DeferBlockBehavior.Manual` in `TestBed.configureTestingModule()` for manual control.
- In `Manual` mode, the defer block starts in the Placeholder state — no `render()` call is needed to assert placeholder content.
- `DeferBlockBehavior.PlayThrough` (default) plays through states naturally — use when you want real-world behavior.
- `fixture.getDeferBlocks()` returns a `Promise<DeferBlockFixture[]>` — always `await` it.
- `deferBlockFixture.render(DeferBlockState.X)` transitions the block to the target state. States: `Placeholder`, `Loading`, `Complete`, `Error`.
- Use `@defer (when condition)` for testable trigger conditions controlled by a component property.
- Test all four states: placeholder → loading → complete, plus error path.

### Angular docs reference: [angular.dev/guide/templates/defer#testing-defer-blocks](https://angular.dev/guide/templates/defer#testing-defer-blocks)

---

## Page Components (Smart / Container)

### What to test

- Renders the correct UI for each logical state:
  - **Loading** — spinner/skeleton shown, content hidden
  - **Empty** — empty state component shown
  - **Error** — error callout shown
  - **Populated** — data rendered correctly
- Makes the correct HTTP requests with the right params
- Reacts to child component events (pagination clicks, search input)
- Composes child components correctly

### Angular Recommended — RouterTestingHarness + real imports

Use `RouterTestingHarness` with `provideRouter` to test pages in their routing context.
Use real child component imports instead of `NO_ERRORS_SCHEMA` for integration fidelity.

Reference: `angular-developer` skill `router-testing.md`

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { provideRouter } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { PizzeriaListPage } from './pizzeria-list-page';
import { PizzeriaDetailPage } from '../pizzeria-details-page/pizzeria-details-page';
import { Page } from '../../../../core/models/pagination.model';
import { PizzeriaSummary } from '../../models/pizzeria.models';

const mockPizzeria: PizzeriaSummary = {
  /* ... */
};
function makePage(items: PizzeriaSummary[], totalPages = 1): Page<PizzeriaSummary> {
  /* ... */
}

describe('PizzeriaListPage (RouterTestingHarness)', () => {
  let harness: RouterTestingHarness;
  let httpTesting: HttpTestingController;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClientTesting(),
        provideRouter([
          { path: '', component: PizzeriaListPage },
          { path: 'pizzerias/:id', component: PizzeriaDetailPage },
        ]),
      ],
    });
    harness = await RouterTestingHarness.create();
    // Navigate into the page
    await harness.navigateByUrl('/', PizzeriaListPage);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should render pizzerias after a successful response', async () => {
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([mockPizzeria]));
    await harness.fixture.whenStable();
    expect(harness.fixture.nativeElement.textContent).toContain('Pizza Roma');
  });
});
```

### Project Pattern — provideRouter + NO_ERRORS_SCHEMA

The realworld-angular project uses `provideRouter([])` and `NO_ERRORS_SCHEMA` to test pages
in isolation. This verifies the page's own template structure but not integration with child
components.

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { provideRouter } from '@angular/router';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { PizzeriaListPage } from './pizzeria-list-page';
import { Page } from '../../../../core/models/pagination.model';
import { PizzeriaSummary } from '../../models/pizzeria.models';
import { By } from '@angular/platform-browser';

const mockPizzeria: PizzeriaSummary = {
  id: '1',
  name: 'Pizza Roma',
  city: 'Rome',
  country: 'Italy',
  image: 'roma.jpg',
  owner: { id: 'o1', name: 'Owner' },
  _count: { pizzas: 5 },
  createdAt: '2024-01-01',
};

function makePage(items: PizzeriaSummary[], totalPages = 1): Page<PizzeriaSummary> {
  return { items, total: items.length, page: 1, limit: 12, totalPages };
}

describe('PizzeriaListPage', () => {
  let fixture: ComponentFixture<PizzeriaListPage>;
  let el: HTMLElement;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClientTesting(), provideRouter([])],
    });

    fixture = TestBed.createComponent(PizzeriaListPage);
    el = fixture.nativeElement;
    httpTesting = TestBed.inject(HttpTestingController);
    TestBed.flushEffects(); // trigger effect-driven httpResource calls
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should show loading indicator before response arrives', () => {
    expect(el.querySelector('[aria-label="Loading pizzerias"]')).not.toBeNull();
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([]));
  });

  it('should include page=1 and limit=12 in the initial request', () => {
    const req = httpTesting.expectOne((r) => r.url.includes('/api/pizzerias'));
    expect(req.request.params.get('page')).toBe('1');
    expect(req.request.params.get('limit')).toBe('12');
    req.flush(makePage([]));
  });

  it('should render pizzeria names after a successful response', async () => {
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([mockPizzeria]));
    await fixture.whenStable();
    expect(el.textContent).toContain('Pizza Roma');
  });

  it('should render multiple pizzeria cards', async () => {
    const second: PizzeriaSummary = { ...mockPizzeria, id: '2', name: 'Napoli Express' };
    httpTesting
      .expectOne((r) => r.url.includes('/api/pizzerias'))
      .flush(makePage([mockPizzeria, second]));
    await fixture.whenStable();
    expect(el.querySelectorAll('.pizzeria-card').length).toBe(2);
  });

  it('should show error callout on HTTP error', async () => {
    httpTesting
      .expectOne((r) => r.url.includes('/api/pizzerias'))
      .flush('Server error', { status: 500, statusText: 'Internal Server Error' });
    await fixture.whenStable();
    expect(el.querySelector('rw-callout')).not.toBeNull();
  });

  it('should show empty state when items list is empty', async () => {
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([]));
    await fixture.whenStable();
    expect(el.querySelector('rw-empty-state')).not.toBeNull();
  });

  it('should make a new request with updated page param when page changes', async () => {
    httpTesting
      .expectOne((r) => r.url.includes('/api/pizzerias'))
      .flush(makePage([mockPizzeria], 3));
    await fixture.whenStable();

    const pagination = fixture.debugElement.query(By.css('rw-pagination'));
    pagination.triggerEventHandler('pageChange', 2);
    TestBed.flushEffects();

    const req2 = httpTesting.expectOne((r) => r.url.includes('/api/pizzerias'));
    expect(req2.request.params.get('page')).toBe('2');
    req2.flush(makePage([mockPizzeria], 3));
    await fixture.whenStable();
  });

  it('should include search param after debounce when search input is typed', async () => {
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([]));
    await fixture.whenStable();

    const input = el.querySelector<HTMLInputElement>('#pizzeria-search')!;
    input.value = 'roma';
    input.dispatchEvent(new Event('input'));
    await new Promise((resolve) => setTimeout(resolve, 350));
    TestBed.flushEffects();

    const req2 = httpTesting.expectOne((r) => r.url.includes('/api/pizzerias'));
    expect(req2.request.params.get('search')).toBe('roma');
    req2.flush(makePage([]));
    await fixture.whenStable();
  }, 2000);
});
```

### Decision Rule

| Situation                              | Use                                                                         |
| -------------------------------------- | --------------------------------------------------------------------------- |
| Testing page in its routing context    | **RouterTestingHarness** — verifies guards, resolvers, component activation |
| Quick smoke test of page DOM structure | **provideRouter + NO_ERRORS_SCHEMA** — simpler setup, faster execution      |
| New code or shared page component      | **RouterTestingHarness** — starts with the modern approach                  |
| Testing route-sensitive behavior       | **RouterTestingHarness** — redirects, guard pipelines, resolver data flow   |

### Key rules

- Stub dependencies as plain objects with signals (not classes, not mock libraries).
- Call `TestBed.flushEffects()` to trigger effect-driven `httpResource` calls before asserting.
- Test every logical state: loading, empty, error, populated.
- For pagination/search, trigger the child component's event and verify a new HTTP request.
- Use `provideRouter([])` even with empty routes — components may inject `Router`.
- **`NO_ERRORS_SCHEMA` vs real child imports:** Use `NO_ERRORS_SCHEMA` when your test assertions only need this component's own DOM. Use `.overrideComponent()` with explicit `imports: [ChildA, ChildB]` when the test needs child components to actually render (e.g., querying a child's internal `<table>`, clicking a child's `<button>`, or accessing a child's `componentInstance`).
- **Triggering outputs on child components:** Two approaches exist:
  - `fixture.debugElement.query(By.css('rw-pagination')).triggerEventHandler('pageChange', 2)` — fires an event by name
  - `fixture.debugElement.query(By.directive(ChildClass)).componentInstance.someOutput.emit(value)` — accesses the component instance and emits directly. Use this when you need the actual component type.
- **Alignment:** ⚠ Project uses `NO_ERRORS_SCHEMA` where Angular recommends real imports for integration fidelity.
  See `README-TEST-INSIGHTS.md` for the improvement roadmap.

### Angular docs reference: [angular.dev/guide/testing/components-basics](https://angular.dev/guide/testing/components-basics)

---

## Guards

### What to test

- Returns `true` when conditions are met
- Returns `UrlTree` (redirect) when conditions are not met
- Verifies the **specific redirect path** (not just "it redirects")

### Angular Recommended — RouterTestingHarness

Use `RouterTestingHarness` with `provideRouter` containing real route configurations.
Navigate to the protected route and assert whether it loads or redirects. This tests
the full pipeline: guard logic + redirect + component activation.

Reference: `angular-developer` skill `router-testing.md`

```typescript
import { TestBed } from '@angular/core/testing';
import { provideRouter, Router } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { describe, it, expect, beforeEach } from 'vitest';
import { AdminPage } from './admin-page';
import { LoginPage } from '../auth/login-page';
import { authGuard } from './auth.guard';
import { Auth } from '../../services/auth';

describe('authGuard (RouterTestingHarness)', () => {
  let harness: RouterTestingHarness;
  let auth: Auth;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideRouter([
          { path: 'admin', component: AdminPage, canActivate: [authGuard] },
          { path: 'login', component: LoginPage },
        ]),
      ],
    });
    harness = await RouterTestingHarness.create();
    auth = TestBed.inject(Auth);
  });

  it('should allow navigation when authenticated', async () => {
    auth.user.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    const component = await harness.navigateByUrl('/admin', AdminPage);
    expect(component).toBeInstanceOf(AdminPage);
    expect(harness.router.url).toBe('/admin');
  });

  it('should redirect to /login when not authenticated', async () => {
    auth.user.set(null);
    await harness.navigateByUrl('/admin');
    expect(harness.router.url).toBe('/login');
  });
});
```

### Project Pattern — runInInjectionContext + vi.fn()

The realworld-angular project tests guard functions directly via `TestBed.runInInjectionContext()`.
This isolates the guard's allow/deny logic but doesn't test the routing integration.

**IMPORTANT: Angular 22 requires a 3rd argument.** Guards now take `(route, segments, currentSnapshot)`.
All guard invocations in tests must include `{} as PartialMatchRouteSnapshot`.

> **Note on the project's guard signature:** the realworld-angular guards are written as
> zero-argument functions (`CanMatchFn = () => { ... }`). The spec files call them with
> three arguments — TypeScript silently tolerates this because JavaScript ignores extra
> positional arguments. The 3-arg invocation shown below is the canonical Angular 22
> `CanMatchFn` shape and matches the type system, but in practice the project's guards
> don't read any of those arguments; the call is "tolerated over-arg passing" rather than
> an exercise of Angular's full `CanMatchFn` contract.

```typescript
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, UrlTree, PartialMatchRouteSnapshot } from '@angular/router';
import { describe, it, expect, beforeEach, vi, type Mocked } from 'vitest';
import { authGuard, guestGuard } from './auth.guard';
import { Auth } from '../../services/auth';

const authStub: Mocked<Pick<Auth, 'isAuthenticated'>> = {
  isAuthenticated: vi.fn(),
};

describe('authGuard', () => {
  let router: Router;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideRouter([]), { provide: Auth, useValue: authStub }],
    });
    router = TestBed.inject(Router);
  });

  it('should return true when user is authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(true);
    const result = TestBed.runInInjectionContext(() =>
      authGuard({ path: '' }, [], {} as PartialMatchRouteSnapshot),
    );
    expect(result).toBe(true);
  });

  it('should return a UrlTree to /auth/login when not authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(false);
    const result = TestBed.runInInjectionContext(() =>
      authGuard({ path: '' }, [], {} as PartialMatchRouteSnapshot),
    );
    expect(result).toBeInstanceOf(UrlTree);
    expect(router.serializeUrl(result as UrlTree)).toBe('/auth/login');
  });
});

describe('guestGuard', () => {
  let router: Router;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideRouter([]), { provide: Auth, useValue: authStub }],
    });
    router = TestBed.inject(Router);
  });

  it('should return true when user is not authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(false);
    const result = TestBed.runInInjectionContext(() =>
      guestGuard({}, [], {} as PartialMatchRouteSnapshot),
    );
    expect(result).toBe(true);
  });

  it('should return a UrlTree to / when authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(true);
    const result = TestBed.runInInjectionContext(() =>
      guestGuard({}, [], {} as PartialMatchRouteSnapshot),
    );
    expect(result).toBeInstanceOf(UrlTree);
    expect(router.serializeUrl(result as UrlTree)).toBe('/');
  });
});
```

### Async Guard (HTTP-based)

For guards that return `Observable<boolean | UrlTree>` (e.g., checking if a pizzeria exists),
subscribe, flush the HTTP request, then assert on the captured result:

```typescript
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, UrlTree, PartialMatchRouteSnapshot } from '@angular/router';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { Observable } from 'rxjs';
import { noPizzeriaGuard } from './no-pizzeria.guard';

describe('noPizzeriaGuard', () => {
  let router: Router;
  let httpTesting: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideRouter([]), provideHttpClientTesting()],
    });
    router = TestBed.inject(Router);
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should redirect when pizzeria exists', () => {
    let result: unknown;
    (
      TestBed.runInInjectionContext(() =>
        noPizzeriaGuard({ path: '' }, [], {} as PartialMatchRouteSnapshot),
      ) as Observable<boolean | UrlTree>
    ).subscribe((r) => (result = r));
    httpTesting.expectOne('/api/pizzerias/admin/pizzeria').flush(mockPizzeria);
    expect(result).toBeInstanceOf(UrlTree);
    expect(router.serializeUrl(result as UrlTree)).toBe('/pizzerias/admin');
  });

  it('should return true on HTTP 404 (no pizzeria)', () => {
    let result: unknown;
    (
      TestBed.runInInjectionContext(() =>
        noPizzeriaGuard({ path: '' }, [], {} as PartialMatchRouteSnapshot),
      ) as Observable<boolean | UrlTree>
    ).subscribe((r) => (result = r));
    httpTesting.expectOne('/api/pizzerias/admin/pizzeria').flush('Not found', {
      status: 404,
      statusText: 'Not Found',
    });
    expect(result).toBe(true);
  });
});
```

### Decision Rule

| Situation                              | Use                                                              |
| -------------------------------------- | ---------------------------------------------------------------- |
| Testing guard integration with routing | **RouterTestingHarness** — verifies guard + redirect + component |
| Testing guard logic in isolation       | **runInInjectionContext** — faster, simpler setup                |
| Multi-step guards (checkout)           | **runInInjectionContext** with `provideRouter(testRoutes)`       |
| Guard with async logic (HTTP)          | Either — both patterns support async guards                      |

### Key rules

- For `runInInjectionContext` approach: use `vi.fn()` for stub methods — gives you `.mockReturnValue()` control.
- Always assert the **exact redirect URL**, not just `UrlTree` type.
- Use `provideRouter([])` — the real router is needed for `serializeUrl()`.
- For multi-step guards (like checkout), use the real route config with `provideRouter(testRoutes)` so the guard can find prerequisite step URLs.
- **Angular 22+:** Guard functions require 3 arguments — include `{} as PartialMatchRouteSnapshot` as the 3rd argument. The project specs now follow this signature (resolved upstream `8684732`).
- **Alignment:** ⚠ Project uses `runInInjectionContext` where Angular recommends `RouterTestingHarness` for integration tests.

### Angular docs reference: [angular.dev/guide/routing/testing](https://angular.dev/guide/routing/testing)

---

## [Illustrative] Data Resolvers

> **Not based on realworld-angular** — illustrative example generated from Angular official documentation.

### What to test

- Resolver fetches data and returns it to the route
- Resolver handles 404 (returns empty, null, or redirect)
- Resolver handles 500 / network error (returns error state or redirect)
- Resolved data is available to the component via input bindings or `ActivatedRoute.data`

### Angular Recommended

Use `RouterTestingHarness` with `provideRouter` and `resolve` in the route config. Flush
HTTP requests with `HttpTestingController`, then assert the resolved data reaches the
component. Prefer `withComponentInputBinding()` — resolved data maps directly to component
`input()` signals.

Reference: `angular-developer` skill `router-testing.md`

```typescript
import { TestBed } from '@angular/core/testing';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { Component, input, inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';

interface User {
  id: string;
  name: string;
  email: string;
}

// Resolver under test
const userResolver: ResolveFn<User> = (route) => {
  const http = inject(HttpClient);
  const userId = route.paramMap.get('id')!;
  return http.get<User>(`/api/users/${userId}`);
};

// Target component using withComponentInputBinding
@Component({
  template: `<h1>{{ user().name }}</h1>
    <p>{{ user().email }}</p>`,
})
class UserDetailPage {
  user = input.required<User>();
}

const mockUser: User = { id: '1', name: 'Alice', email: 'alice@example.com' };

describe('userResolver (RouterTestingHarness)', () => {
  let harness: RouterTestingHarness;
  let httpTesting: HttpTestingController;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClientTesting(),
        provideRouter(
          [
            {
              path: 'users/:id',
              component: UserDetailPage,
              resolve: { user: userResolver },
            },
          ],
          withComponentInputBinding(),
        ),
      ],
    });
    harness = await RouterTestingHarness.create();
    httpTesting = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTesting.verify();
  });

  it('should resolve user data and pass it to the component', async () => {
    const component = await harness.navigateByUrl('/users/1', UserDetailPage);
    const req = httpTesting.expectOne('/api/users/1');
    req.flush(mockUser);
    harness.detectChanges();

    expect(component.user()).toEqual(mockUser);
    expect(harness.routeNativeElement?.textContent).toContain('Alice');
  });

  it('should handle resolver error (404)', async () => {
    await harness.navigateByUrl('/users/99');
    httpTesting
      .expectOne('/api/users/99')
      .flush('Not found', { status: 404, statusText: 'Not Found' });

    // When a resolver errors, the router cancels navigation.
    // The URL stays at the previous location (root from harness creation).
    // Use withNavigationErrorHandler to test error handling behavior.
    expect(harness.router.url).toBe('/');
  });
});
```

### Key rules

- Use `withComponentInputBinding()` — resolved data maps directly to `input.required<T>()` signals.
- Combine `RouterTestingHarness` + `HttpTestingController` for end-to-end resolver testing.
- Always call `harness.detectChanges()` after flushing HTTP to trigger change detection with new data.
- Test both success (data resolves → component renders) and error (404, 500) paths.
- When a resolver errors, navigation is cancelled and the URL does not advance. Use `withNavigationErrorHandler` for centralized error handling or `catchError` with `RedirectCommand` in the resolver to redirect gracefully.
- Resolvers run before navigation completes — the target component won't render on failure.

### Angular docs reference: [angular.dev/guide/routing/data-resolvers](https://angular.dev/guide/routing/data-resolvers)

---

## Directives

### What to test

- DOM manipulation effect (added/removed elements, style changes)
- Reactivity to input changes (signal updates, value changes)
- Every branch: different roles, else template, null state
- Negative cases: elements WITHOUT the directive are unaffected

### Angular Recommended & Project Pattern

The host component pattern is the canonical approach for both Angular recommended
and the project. No gap.

```typescript
import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';
import { RoleDirective } from './role.directive';
import { Auth } from '../../core/services/auth';
import { User } from '../../core/models/user.model';

const userSignal = signal<User | null>(null);

const authStub = {
  user: userSignal,
};

@Component({
  imports: [RoleDirective],
  template: `
    <span *rwRole="'GUEST'" id="guest-content">Guest only</span>
    <span *rwRole="'CUSTOMER'" id="customer-content">Customer only</span>
    <span *rwRole="'PIZZERIA_ADMIN'" id="admin-content">Admin only</span>
    <span *rwRole="['CUSTOMER', 'PIZZERIA_ADMIN']" id="auth-content">Authenticated</span>
    <span *rwRole="'CUSTOMER'; else guestTpl" id="customer-or-else">Customer</span>
    <ng-template #guestTpl><span id="else-content">Please sign in</span></ng-template>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
class TestHostComponent {}

describe('RoleDirective', () => {
  let fixture: ComponentFixture<TestHostComponent>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [{ provide: Auth, useValue: authStub }],
    });
    userSignal.set(null);
    fixture = TestBed.createComponent(TestHostComponent);
    await fixture.whenStable();
    el = fixture.nativeElement;
  });

  it('should show GUEST content when user is null', () => {
    expect(el.querySelector('#guest-content')).not.toBeNull();
  });

  it('should hide GUEST content when user is authenticated', async () => {
    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#guest-content')).toBeNull();
  });

  it('should show CUSTOMER content when role matches', async () => {
    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#customer-content')).not.toBeNull();
  });

  it('should hide CUSTOMER content when role does not match', () => {
    expect(el.querySelector('#customer-content')).toBeNull();
  });

  it('should show PIZZERIA_ADMIN content for admin user', async () => {
    userSignal.set({ id: '2', email: 'admin@b.com', role: 'PIZZERIA_ADMIN', name: 'Admin' });
    await fixture.whenStable();
    expect(el.querySelector('#admin-content')).not.toBeNull();
  });

  it('should hide PIZZERIA_ADMIN content for non-admin user', async () => {
    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#admin-content')).toBeNull();
  });

  it('should show auth-content for any authenticated role', async () => {
    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#auth-content')).not.toBeNull();

    userSignal.set({ id: '2', email: 'admin@b.com', role: 'PIZZERIA_ADMIN', name: 'Admin' });
    await fixture.whenStable();
    expect(el.querySelector('#auth-content')).not.toBeNull();
  });

  it('should hide auth-content when not authenticated', () => {
    expect(el.querySelector('#auth-content')).toBeNull();
  });

  it('should show else template when CUSTOMER condition is false', () => {
    expect(el.querySelector('#else-content')).not.toBeNull();
    expect(el.querySelector('#customer-or-else')).toBeNull();
  });

  it('should swap to main template and hide else when CUSTOMER condition becomes true', async () => {
    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#customer-or-else')).not.toBeNull();
    expect(el.querySelector('#else-content')).toBeNull();
  });

  it('should react to user signal changes', async () => {
    expect(el.querySelector('#customer-content')).toBeNull();

    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#customer-content')).not.toBeNull();

    userSignal.set(null);
    await fixture.whenStable();
    expect(el.querySelector('#customer-content')).toBeNull();
  });
});
```

### Key rules

- Create a `TestHostComponent` that exercises every usage pattern of the directive.
- Provide a stub for dependencies; control them with signals so you can change state mid-test.
- Test **reactivity** — change a signal, wait for stability, assert the DOM updated.
- Test the `else` template branch if the directive supports one.
- Test both "element should exist" (positive) and "element should be null" (negative) for each mode.
- **Alignment:** ✓ No gap between Angular recommended and project pattern.

### Angular docs reference: [angular.dev/guide/testing/attribute-directives](https://angular.dev/guide/testing/attribute-directives)

---

## Forms & Wizard Services

### What to test

- Initial step / default values
- Computed values derived from form state (tip amount, discount, total)
- Step validation rules (required fields, format checks)
- Step progression (validate → mark success → advance)
- Cross-field effects (e.g., "use same as billing" clears billing fields)

### Angular Recommended

For Angular v22+, use **signal forms** for new form implementations. Signal forms integrate
natively with Angular's reactivity system and can be tested by directly manipulating form
control values and asserting on computed derivations.

Reference: `angular-developer` skill `signal-forms.md`, `effects.md`

### Project Pattern — Real Service, Stubbed External Dependencies

The realworld-angular project tests the wizard service as a real instance with stubbed
dependencies. Form state is manipulated through the service's public API, and effects
are flushed with `TestBed.flushEffects()`.

```typescript
import { TestBed } from '@angular/core/testing';
import { provideRouter, Routes, Router } from '@angular/router';
import { signal } from '@angular/core';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { CheckoutWizard } from './checkout-wizard';
import { checkoutRoutes } from '../checkout.routes';
import { CartStore, CartItem, CartData } from '../../cart/cart.store';
import { OrderApi } from '../../orders/services/order-api';

const cartStoreStub = {
  totalPrice: signal(0),
  pizzeria: signal<{ id: string } | null>(null),
  items: signal<CartItem[]>([]),
  cart: signal<CartData | null>(null),
  isEmpty: signal(true),
  clear: vi.fn(),
};

const orderApiStub = {
  createOrder: vi.fn(),
};

const testRoutes: Routes = [{ path: 'checkout', children: checkoutRoutes }];

describe('CheckoutWizard', () => {
  let service: CheckoutWizard;
  let router: Router;

  beforeEach(async () => {
    cartStoreStub.totalPrice.set(0);
    cartStoreStub.pizzeria.set(null);
    cartStoreStub.items.set([]);
    cartStoreStub.cart.set(null);

    TestBed.configureTestingModule({
      providers: [
        provideRouter(testRoutes),
        CheckoutWizard, // real service
        { provide: CartStore, useValue: cartStoreStub }, // stub
        { provide: OrderApi, useValue: orderApiStub }, // stub
      ],
    });
    service = TestBed.inject(CheckoutWizard);
    router = TestBed.inject(Router);
    await router.navigateByUrl('/checkout/delivery');
  });

  it('should start on delivery step', () => {
    expect(service.activeStep()).toBe('delivery');
  });

  it('should have all step statuses as null initially', () => {
    const status = service.stepStatus();
    expect(status.delivery).toBeNull();
    expect(status.schedule).toBeNull();
    expect(status.review).toBeNull();
  });

  it('should not be submitted initially', () => {
    expect(service.submitted()).toBe(false);
  });

  describe('tipAmount', () => {
    it('should be 0 when tip type is none', () => {
      expect(service.tipAmount()).toBe(0);
    });

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

    it('should compute 20% of total when tip type is twenty', () => {
      cartStoreStub.totalPrice.set(50);
      service.checkoutForm.tip.type().value.set('twenty');
      TestBed.flushEffects();
      expect(service.tipAmount()).toBe(10);
    });

    it('should return custom amount when tip type is custom', () => {
      service.checkoutForm.tip.type().value.set('custom');
      service.checkoutForm.tip.customAmount().value.set(3.5);
      TestBed.flushEffects();
      expect(service.tipAmount()).toBe(3.5);
    });
  });

  describe('discountAmount', () => {
    it('should return discount amount when code has value and discount is set', () => {
      cartStoreStub.totalPrice.set(30);
      service.discount.set(20);
      service.checkoutForm.coupon.code().value.set('SAVE20');
      TestBed.flushEffects();
      expect(service.discountAmount()).toBe(6);
    });

    it('should return 0 when discount is 0', () => {
      cartStoreStub.totalPrice.set(30);
      service.checkoutForm.coupon.code().value.set('SAVE20');
      TestBed.flushEffects();
      expect(service.discountAmount()).toBe(0);
    });

    it('should return 0 when code is empty', () => {
      cartStoreStub.totalPrice.set(30);
      service.discount.set(20);
      TestBed.flushEffects();
      expect(service.discountAmount()).toBe(0);
    });
  });

  describe('totalWithTip', () => {
    it('should equal totalPrice when no tip', () => {
      cartStoreStub.totalPrice.set(30);
      expect(service.totalWithTip()).toBe(30);
    });

    it('should add tip amount to total price', () => {
      cartStoreStub.totalPrice.set(20);
      service.checkoutForm.tip.type().value.set('ten');
      TestBed.flushEffects();
      expect(service.totalWithTip()).toBe(22);
    });
  });

  describe('isStepValid', () => {
    it('should return false for delivery when street is empty', () => {
      TestBed.flushEffects();
      expect(service.isStepValid('delivery')).toBe(false);
    });

    it('should return true for delivery when required fields are filled', () => {
      service.checkoutForm.delivery.street().value.set('123 Main St');
      service.checkoutForm.delivery.location().value.set({ city: 'Rome', country: 'Italy' });
      TestBed.flushEffects();
      expect(service.isStepValid('delivery')).toBe(true);
    });

    it('should return true for schedule when type is asap', () => {
      expect(service.isStepValid('schedule')).toBe(true);
    });
  });

  describe('validateStep', () => {
    it('should validate and navigate on valid delivery', async () => {
      service.checkoutForm.delivery.street().value.set('123 Main St');
      service.checkoutForm.delivery.location().value.set({ city: 'Rome', country: 'Italy' });
      TestBed.flushEffects();

      await service.validateStep('delivery');
      expect(service.stepStatus().delivery).toBe('success');
    });

    it('should not navigate on invalid delivery', async () => {
      await service.validateStep('delivery');
      expect(service.stepStatus().delivery).not.toBe('success');
      expect(service.activeStep()).toBe('delivery');
    });

    it('should validate and navigate on valid schedule (asap)', async () => {
      await service.validateStep('schedule');
      expect(service.stepStatus().schedule).toBe('success');
    });
  });

  describe('billing fields effect', () => {
    it('should clear billing fields when useSameAsBilling is enabled', () => {
      service.checkoutForm.delivery
        .billingLocation()
        .value.set({ city: 'Milan', country: 'Italy' });
      service.checkoutForm.delivery.billingStreet().value.set('456 Oak Ave');
      TestBed.flushEffects();

      service.checkoutForm.delivery.useSameAsBilling().value.set(false);
      TestBed.flushEffects();
      service.checkoutForm.delivery.useSameAsBilling().value.set(true);
      TestBed.flushEffects();

      expect(service.checkoutForm.delivery.billingLocation().value()).toBeNull();
      expect(service.checkoutForm.delivery.billingStreet().value()).toBe('');
    });
  });
});
```

### Key rules

- Use the **real** service under test — only stub what it calls out to (CartStore, OrderApi).
- Mutate the service's own form state directly through its public API.
- `TestBed.flushEffects()` after every form mutation to let computed signals and effects run.
- Test **derived values** (computed signals that depend on form state), not just setters.
- Test **cross-field effects** — changing one field should clear/update another.
- **Alignment:** ✓ Mostly aligned. Angular v22+ signal forms are the recommended approach for new code. The project's real-service-with-stubs pattern is valid for the current form implementation.

---

## [Illustrative] Custom Form Controls

> **Not based on realworld-angular** — illustrative example generated from Angular official documentation.

### What to test

- `writeValue` updates the internal control value and DOM
- User interaction calls `onChange` with the new value
- `registerOnTouched` fires on blur
- `setDisabledState` toggles the disabled mode
- Validation: required, pattern, min/max, custom validators

### Angular Recommended

Create a `TestHostComponent` that uses the custom control inside a signal form. Manipulate
the control via its form API (`setValue`, `disable`) and assert DOM updates and form state
changes. Do not spy on `onChange`/`onTouched` directly — test their effects through form
integration.

Reference: `angular-developer` skill `signal-forms.md`, `testing-fundamentals.md`

**Custom control under test:**

```typescript
// rating-control.ts
import { Component, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
  selector: 'app-rating-control',
  template: `
    <div class="rating" [class.disabled]="isDisabled">
      @for (star of stars; track star) {
        <button
          type="button"
          [class.filled]="star <= value"
          [disabled]="isDisabled"
          (click)="selectRating(star)"
          (blur)="onTouched()"
        >
          {{ star <= value ? '★' : '☆' }}
        </button>
      }
    </div>
  `,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => RatingControl),
      multi: true,
    },
  ],
})
export class RatingControl implements ControlValueAccessor {
  stars = [1, 2, 3, 4, 5];
  value = 0;
  isDisabled = false;
  onChange: (value: number) => void = () => {};
  onTouched: () => void = () => {};

  writeValue(value: number): void {
    this.value = value;
  }

  registerOnChange(fn: (value: number) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled = isDisabled;
  }

  selectRating(star: number): void {
    if (!this.isDisabled) {
      this.value = star;
      this.onChange(star);
    }
  }
}
```

**Test with signal forms:**

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Component, signal } from '@angular/core';
import { form, FormField } from '@angular/forms/signals';
import { describe, it, expect, beforeEach } from 'vitest';
import { RatingControl } from './rating-control';
@Component({
  imports: [FormField, RatingControl],
  template: ` <app-rating-control [formField]="rating" /> `,
})
class TestHostComponent {
  readonly model = signal({ rating: 0 });
  readonly rating = form(this.model).rating;
}

describe('RatingControl', () => {
  let fixture: ComponentFixture<TestHostComponent>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(TestHostComponent);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render stars via writeValue', () => {
    fixture.componentInstance.model.set({ rating: 3 });
    TestBed.flushEffects();
    const filledStars = el.querySelectorAll('.rating .filled');
    expect(filledStars.length).toBe(3);
  });

  it('should call onChange when a star is clicked', () => {
    const buttons = el.querySelectorAll<HTMLButtonElement>('.rating button');
    buttons[4].click(); // select 5th star
    TestBed.flushEffects();
    expect(fixture.componentInstance.rating().value()).toBe(5);
  });

  it('should not select when disabled', () => {
    fixture.componentInstance.rating().disabled.set(true);
    TestBed.flushEffects();
    const buttons = el.querySelectorAll<HTMLButtonElement>('.rating button');
    buttons[2].click();
    TestBed.flushEffects();
    expect(fixture.componentInstance.rating().value()).toBe(0);
  });

  it('should fail validation when value is 0', () => {
    TestBed.flushEffects();
    expect(fixture.componentInstance.rating().errors().length).toBeGreaterThan(0);
  });
});
```

**Test with reactive forms (alternative):**

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { describe, it, expect, beforeEach } from 'vitest';
import { RatingControl } from './rating-control';

@Component({
  imports: [ReactiveFormsModule, RatingControl],
  template: `
    <form [formGroup]="form">
      <app-rating-control formControlName="rating" />
    </form>
  `,
})
class TestHostComponent {
  form = new FormGroup({
    rating: new FormControl(0, { validators: [Validators.required, Validators.min(1)] }),
  });
}

describe('RatingControl (reactive forms)', () => {
  let fixture: ComponentFixture<TestHostComponent>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({});
    fixture = TestBed.createComponent(TestHostComponent);
    el = fixture.nativeElement;
    fixture.detectChanges();
  });

  it('should write value from form to DOM', () => {
    fixture.componentInstance.form.controls.rating.setValue(4);
    fixture.detectChanges();
    const filledStars = el.querySelectorAll('.rating .filled');
    expect(filledStars.length).toBe(4);
  });

  it('should update form when star is clicked', () => {
    el.querySelectorAll<HTMLButtonElement>('.rating button')[0].click();
    fixture.detectChanges();
    expect(fixture.componentInstance.form.controls.rating.value).toBe(1);
  });
});
```

### Key rules

- Create a `TestHostComponent` that wraps the custom control in a real form (signal forms for Angular v22+, reactive forms for v21 and earlier).
- Signal forms: create the form with `form(modelSignal)`, bind controls with `FormField`, and call `TestBed.flushEffects()` after mutations.
- Reactive forms: use `ReactiveFormsModule`, call `fixture.detectChanges()` after mutations.
- Test `writeValue` by setting the form control's value and asserting DOM output.
- Test `onChange` by interacting with the DOM and asserting the form control's value updated.
- Test `setDisabledState` by disabling the form control and asserting buttons are disabled.
- Test validation by asserting `control.hasError('required')`, `control.valid`, etc.
- Do NOT test `registerOnChange` or `registerOnTouched` directly — they are framework internals. Test their effects through form integration.

### Angular docs reference: [angular.dev/guide/forms/custom-form-controls](https://angular.dev/guide/forms/custom-form-controls)

---

## Route Config Files

### What to test

Route config files (`*.routes.ts`) contain only declarative route definitions — no runtime logic. They are **NOT tested**.

What you test instead:

- **Guards** that protect those routes → guard spec
- **Components** that are loaded by those routes → component spec
- **Route parameter reading** in components → component spec with `provideRouter`

**Do not write tests for `*.routes.ts` files.**

---

## Quick Reference Table

| Unit                | Angular Recommended                          | Project Pattern                          | Key Difference           |
| ------------------- | -------------------------------------------- | ---------------------------------------- | ------------------------ |
| Service             | HttpTestingController                        | HttpTestingController                    | ✓ Same                   |
| Component           | Component Harnesses                          | querySelector + NO_ERRORS_SCHEMA         | Harness vs raw DOM       |
| Dialog              | DialogRef stub + DIALOG_DATA                 | DialogRef stub + DIALOG_DATA             | ✓ Same                   |
| @defer              | DeferBlockBehavior.Manual + render()         | —                                        | Illustrative only        |
| Page                | RouterTestingHarness + real imports          | provideRouter + NO_ERRORS_SCHEMA         | Integration vs isolation |
| Guard               | RouterTestingHarness                         | runInInjectionContext + vi.fn()          | Full pipeline vs unit    |
| Data Resolver       | RouterTestingHarness + HttpTestingController | - (illustrative)                         | -                        |
| Interceptor         | withInterceptors + real HttpClient           | withInterceptors + real HttpClient       | ✓ Same                   |
| Pipe                | new Pipe()                                   | new Pipe()                               | ✓ Same                   |
| Directive           | Host component                               | Host component                           | ✓ Same                   |
| Store               | httpResource patterns                        | httpTesting.match()                      | ✓ Mostly same            |
| Wizard              | Real service + stubs                         | Real service + stubs                     | ✓ Same                   |
| Custom Form Control | TestHostComponent + signal forms             | —                                        | Illustrative only        |
| linkedSignal        | `linkedSignal()` + `TestBed.flushEffects()`  | —                                        | Illustrative only        |
| httpResource        | `HttpTestingController` + `{ injector }`     | `HttpTestingController` + `{ injector }` | ✓ Same                   |
| resource            | `runInInjectionContext` + mock loader        | —                                        | Illustrative only        |
| effect              | `runInInjectionContext` + `flushEffects()`   | —                                        | Illustrative only        |
| Signal Output       | `.subscribe()` on `output()` emitter         | —                                        | Illustrative only        |
| Host Bindings       | `nativeElement` attribute/class/style checks | —                                        | Illustrative only        |

---

## Global Setup (Optional)

> **Unverified for `@angular/build:unit-test`:** the `providersFile` option below is shown as
> a possible configuration for the project's test builder, but it has not been validated
> against the builder's actual schema. Treat the `angular.json` snippet as illustrative —
> consult the builder's schema (`@angular/build:unit-test`) before relying on it.

To avoid repeating `provideHttpClientTesting()` in every spec, create a global
providers file:

```typescript
// src/test-providers.ts
import { provideHttpClientTesting } from '@angular/common/http/testing';

const testProviders = [provideHttpClientTesting()];
export default testProviders;
```

Then reference it in `angular.json`:

```json
{
  "projects": {
    "your-project": {
      "architect": {
        "test": {
          "builder": "@angular/build:unit-test",
          "options": {
            "providersFile": "src/test-providers.ts"
          }
        }
      }
    }
  }
}
```

The realworld-angular suite does **not** use this — it explicitly provides
`provideHttpClientTesting()` per spec for self-contained clarity. Both
approaches are valid.

---

## One-Sentence Summary Per Unit

| Unit                | The test should answer this question                                                        |
| ------------------- | ------------------------------------------------------------------------------------------- |
| Service             | "Did it call the right endpoint with the right data and update state correctly?"            |
| Component           | "Given these inputs, does it render the right DOM with the right attributes?"               |
| Dialog              | "Given injected data, does it render correctly and close with the right result?"            |
| @defer              | "Does each state (placeholder/loading/complete/error) render the correct content?"          |
| Page                | "For each logical state (loading/empty/error/data), does it show the correct UI?"           |
| Guard               | "Does it allow or redirect, and redirect exactly where?"                                    |
| Data Resolver       | "Does it fetch data and provide it to the component, and handle errors gracefully?"         |
| Interceptor         | "Did it modify (or not modify) the outgoing request as expected?"                           |
| Pipe                | "Given this input, does it produce this output?"                                            |
| Directive           | "Does it manipulate the DOM correctly and react to state changes?"                          |
| Store               | "Do mutations produce correct state and trigger correct side effects?"                      |
| Wizard              | "Do the form rules, computed values, and validation logic work correctly?"                  |
| Custom Form Control | "Does it integrate with the form API: write value, report changes, and validate?"           |
| linkedSignal        | "Does it default correctly, allow overrides, and reset when its source changes?"            |
| httpResource        | "Does it fetch data, expose the response on value()/error(), and reload on source changes?" |
| effect              | "Does it run when tracked signals change, and clean up correctly between runs?"             |
| Signal Output       | "Does the component emit the correct value when an event occurs?"                           |
| Host Bindings       | "Do the root element's attributes, classes, and styles reflect the component state?"        |
