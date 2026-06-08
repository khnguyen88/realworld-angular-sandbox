# Angular Test Guide

A practical walkthrough of what to test and how to write it, based on the
[realworld-angular](https://github.com/realworld-angular/realworld-angular)
test suite and Angular's official testing documentation.

> **Testing Docs Index:**
> - **README-TEST-GUIDE.md** — This file: how to write tests (Angular recommended + project patterns)
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists (60 specs, categories, patterns)
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

Angular CLI projects now default to **Vitest** with **jsdom**. Run tests with
`ng test`.

Each section below shows two approaches: the **Angular Recommended** way
(per official docs and the Angular skill references) and the **Project Pattern**
(how realworld-angular currently tests). Choose based on whether you're writing
new tests or maintaining existing ones.

---

## Table of Contents

- [Decision Flow: What Do I Test?](#decision-flow-what-do-i-test)
- [Pipes](#pipes)
- [Services](#services)
- [Interceptors](#interceptors)
- [Stores / State](#stores--state)
- [Components](#components)
- [Page Components (Smart / Container)](#page-components-smart--container)
- [Guards](#guards)
- [Directives](#directives)
- [Forms & Wizard Services](#forms--wizard-services)
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
├── Reactive state with computed signals → Store test
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

  it('should encode special characters in the filename', () => {
    const result = pipe.transform('my pizza #1.jpg', 'pizza');
    expect(result).toContain(encodeURIComponent('my pizza #1.jpg'));
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

### Pattern

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { Auth } from './auth';

const mockUser: User = { id: '1', email: 'test@example.com', role: 'CUSTOMER', name: 'Test' };

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
    httpTesting.verify();   // catches leaked requests
  });

  // Initial state
  it('should have null user initially', () => {
    expect(service.user()).toBeNull();
  });

  // Success path
  it('should POST credentials and update user signal', () => {
    service.login('user@example.com', 'password').subscribe();
    const req = httpTesting.expectOne('/api/auth/login');
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({ email: 'user@example.com', password: 'password' });
    req.flush(mockUser);                          // respond with success
    expect(service.user()).toEqual(mockUser);
  });

  // Error path
  it('should keep user null on error', () => {
    service.init().subscribe();
    const req = httpTesting.expectOne('/api/auth/me');
    req.flush('Unauthorized', { status: 401, statusText: 'Unauthorized' });
    expect(service.user()).toBeNull();
  });
});
```

### Key rules

- Always use `TestBed.inject()` — never `new Auth(httpClient)`. DI wiring must go through TestBed.
- Always call `httpTesting.verify()` in `afterEach` to catch un-flushed requests.
- Test **all four assertions** per endpoint: URL, method, body, and post-response state.
- Test **both** the success and error branches of every HTTP call.

### Angular docs reference: [angular.dev/guide/testing/services](https://angular.dev/guide/testing/services)

---

## Components

### What to test

- Renders the correct DOM structure given its inputs
- Applies correct CSS classes based on input values
- Shows/hides elements based on state
- Emits outputs on user interaction
- Sets correct ARIA attributes (accessibility is a first-class assertion)
- Disabled / loading / active states

### Pattern — Presentational Component

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

  // Existence
  it('should render a button element', () => {
    expect(buttonEl).not.toBeNull();
  });

  // CSS classes from inputs
  it('should apply variant and palette classes', async () => {
    fixture.componentRef.setInput('variant', 'outlined');
    fixture.componentRef.setInput('palette', 'danger');
    await fixture.whenStable();
    expect(buttonEl.className).toContain('btn--outlined-danger');
  });

  // Disabled state
  it('should be disabled when isDisabled is true', async () => {
    fixture.componentRef.setInput('isDisabled', true);
    await fixture.whenStable();
    expect(buttonEl.disabled).toBe(true);
  });

  // Loading state + accessibility
  it('should show loading spinner and set aria-busy', async () => {
    fixture.componentRef.setInput('isLoading', true);
    await fixture.whenStable();
    expect(buttonEl.querySelector('.btn-spinner')).not.toBeNull();
    expect(buttonEl.getAttribute('aria-busy')).toBe('true');
  });
});
```

### Key rules

- Use `NO_ERRORS_SCHEMA` to ignore child component selectors. Each component has its own tests.
- Set signal-based inputs with `fixture.componentRef.setInput('name', value)`.
- `await fixture.whenStable()` after every async change (input set, state toggle).
- Test accessibility attributes (`aria-*`, `role`) as assertions — not an afterthought.
- Use `el.querySelector()` for DOM access; it's simpler and just as correct as `By.css()`.

### Angular docs reference: [angular.dev/guide/testing/components-basics](https://angular.dev/guide/testing/components-basics)

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

### Pattern — Page with HTTP data

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { provideRouter } from '@angular/router';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { PizzeriaListPage } from './pizzeria-list-page';

const mockPizzeria: PizzeriaSummary = {
  id: '1', name: 'Pizza Roma', city: 'Rome', country: 'Italy',
  image: 'roma.jpg', owner: { id: 'o1', name: 'Owner' },
  _count: { pizzas: 5 }, createdAt: '2024-01-01',
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
    TestBed.flushEffects();      // trigger effect-driven httpResource calls
  });

  afterEach(() => {
    httpTesting.verify();
  });

  // LOADING state
  it('should show loading indicator before response arrives', () => {
    expect(el.querySelector('[aria-label="Loading pizzerias"]')).not.toBeNull();
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([]));
  });

  // POPULATED state
  it('should render pizzeria names after a successful response', async () => {
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([mockPizzeria]));
    await fixture.whenStable();
    expect(el.textContent).toContain('Pizza Roma');
  });

  // ERROR state
  it('should show error callout on HTTP error', async () => {
    httpTesting
      .expectOne((r) => r.url.includes('/api/pizzerias'))
      .flush('Server error', { status: 500, statusText: 'Internal Server Error' });
    await fixture.whenStable();
    expect(el.querySelector('rw-callout')).not.toBeNull();
  });

  // EMPTY state
  it('should show empty state when items list is empty', async () => {
    httpTesting.expectOne((r) => r.url.includes('/api/pizzerias')).flush(makePage([]));
    await fixture.whenStable();
    expect(el.querySelector('rw-empty-state')).not.toBeNull();
  });

  // Pagination interaction
  it('should make a new request with updated page param when page changes', async () => {
    httpTesting
      .expectOne((r) => r.url.includes('/api/pizzerias'))
      .flush(makePage([mockPizzeria], 3));
    await fixture.whenStable();

    // Trigger the child component's output
    const pagination = fixture.debugElement.query(By.css('rw-pagination'));
    pagination.triggerEventHandler('pageChange', 2);
    TestBed.flushEffects();

    const req2 = httpTesting.expectOne((r) => r.url.includes('/api/pizzerias'));
    expect(req2.request.params.get('page')).toBe('2');
    req2.flush(makePage([mockPizzeria], 3));
    await fixture.whenStable();
  });
});
```

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

---

## Guards

### What to test

- Returns `true` when conditions are met
- Returns `UrlTree` (redirect) when conditions are not met
- Verifies the **specific redirect path** (not just "it redirects")

### Pattern — Functional Guard

```typescript
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, UrlTree } from '@angular/router';
import { describe, it, expect, beforeEach, vi, type Mocked } from 'vitest';
import { authGuard } from './auth.guard';
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

  // Authenticated → allow
  it('should return true when user is authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(true);
    const result = TestBed.runInInjectionContext(() =>
      authGuard({ path: '' } as Route, [] as unknown as UrlSegment[]),
    );
    expect(result).toBe(true);
  });

  // Not authenticated → redirect to login
  it('should return a UrlTree to /auth/login when not authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(false);
    const result = TestBed.runInInjectionContext(() =>
      authGuard({ path: '' } as Route, [] as unknown as UrlSegment[]),
    );
    expect(result).toBeInstanceOf(UrlTree);
    expect(router.serializeUrl(result as UrlTree)).toBe('/auth/login');
  });
});
```

### Pattern — Async Guard (makes HTTP calls)

Some guards make their own HTTP requests (e.g., to check if a pizzeria exists).
These return `Observable<boolean | UrlTree>`. The test subscribes, then flushes the
HTTP request:

```typescript
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, UrlTree } from '@angular/router';
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
        noPizzeriaGuard({ path: '' } as Route, [] as unknown as UrlSegment[]),
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
        noPizzeriaGuard({ path: '' } as Route, [] as unknown as UrlSegment[]),
      ) as Observable<boolean | UrlTree>
    ).subscribe((r) => (result = r));
    httpTesting.expectOne('/api/pizzerias/admin/pizzeria').flush('Not found', {
      status: 404, statusText: 'Not Found',
    });
    expect(result).toBe(true);
  });
});
```

### Key rules

- Use `vi.fn()` for stub methods — gives you `.mockReturnValue()` control per test.
- Use `TestBed.runInInjectionContext()` for calling functional guards (they need DI).
- Always assert the **exact redirect URL**, not just `UrlTree` type.
- Use `provideRouter([])` — the real router is needed for `serializeUrl()`.
- For multi-step guards (like checkout), use the real route config with `provideRouter(testRoutes)` so the guard can find prerequisite step URLs.
- For guards that return `Observable` (async guards making HTTP calls), subscribe with `let result: unknown`, flush the request, then assert on the captured result.

### RouterTestingHarness (Recommended by Angular)

The patterns above use `runInInjectionContext()` because that's what the realworld-angular
project adopted. The Angular skill, however, recommends **`RouterTestingHarness`** as the
primary tool for routing tests. It provides a higher-level API that navigates through real
routes and returns activated component instances:

```typescript
import { RouterTestingHarness } from '@angular/router/testing';

let harness: RouterTestingHarness;

beforeEach(async () => {
  TestBed.configureTestingModule({
    providers: [provideRouter([
      { path: '', component: Dashboard },
      { path: 'heroes/:id', component: HeroDetail },
    ])],
  });
  harness = await RouterTestingHarness.create();
});

it('should navigate and return component instance', async () => {
  const dashboard = await harness.navigateByUrl('/', Dashboard);
  dashboard.selectHero({ id: 42 });
  await harness.fixture.whenStable();
  expect(harness.router.url).toEqual('/heroes/42');
});
```

Use `RouterTestingHarness` for new code when you want to test the full routing pipeline
(guards + resolvers + component activation) in a single test. Use the `runInInjectionContext()`
approach when you only need to test a guard's allow/deny logic in isolation.

### Angular docs reference: [angular.dev/guide/routing/testing](https://angular.dev/guide/routing/testing)

---

## Interceptors

### What to test

- Modifies the outgoing request correctly (e.g., adds headers, transforms URL)
- Does NOT modify requests it should skip
- Handles response transformations (if applicable)

### Pattern — Functional Interceptor

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

  it('should not add withCredentials to Photon external API', () => {
    http.get('https://photon.komoot.io/api/?q=rome').subscribe();
    const req = httpTesting.expectOne('https://photon.komoot.io/api/?q=rome');
    expect(req.request.withCredentials).toBe(false);
    req.flush({});
  });
});
```

### Key rules

- Register the interceptor with `provideHttpClient(withInterceptors([...]))` — it runs through the real pipeline.
- Use a real `HttpClient` to make requests that pass through the interceptor.
- Test the request's **side effects** — modified headers, URL, `withCredentials`, etc.
- Test both "should modify" and "should not modify" branches.

---

## Directives

### What to test

- DOM manipulation effect (added/removed elements, style changes)
- Reactivity to input changes (signal updates, value changes)
- Every branch: different roles, else template, null state
- Negative cases: elements WITHOUT the directive are unaffected

### Pattern — Host Component

```typescript
import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { describe, it, expect, beforeEach } from 'vitest';
import { RoleDirective } from './role.directive';
import { Auth } from '../../core/services/auth';

const userSignal = signal<User | null>(null);
const authStub = { user: userSignal };

@Component({
  imports: [RoleDirective],
  template: `
    <span *rwRole="'GUEST'" id="guest-content">Guest only</span>
    <span *rwRole="'CUSTOMER'" id="customer-content">Customer only</span>
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

  // Shows when condition matches
  it('should show GUEST content when user is null', () => {
    expect(el.querySelector('#guest-content')).not.toBeNull();
  });

  // Hides when condition doesn't match
  it('should hide GUEST content when user is authenticated', async () => {
    userSignal.set({ id: '1', email: 'a@b.com', role: 'CUSTOMER', name: 'Test' });
    await fixture.whenStable();
    expect(el.querySelector('#guest-content')).toBeNull();
  });

  // Shows else template when condition is false
  it('should show else template when condition is false', () => {
    expect(el.querySelector('#else-content')).not.toBeNull();
    expect(el.querySelector('#customer-or-else')).toBeNull();
  });

  // Reacts to signal changes
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

### Angular docs reference: [angular.dev/guide/testing/attribute-directives](https://angular.dev/guide/testing/attribute-directives)

---

## Stores / State

### What to test

- Initial state (empty items, null values, isEmpty = true)
- Adding items (state mutates correctly, derived signals update)
- Removing items (state mutates, edge case: removing last item)
- Cross-entity constraints (e.g., can't add items from different pizzerias)
- Side effects (HTTP requests triggered by state changes)
- Negative: no HTTP when state is empty

### Pattern — Store with httpResource

```typescript
import { TestBed } from '@angular/core/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { CartStore, CartData } from './cart.store';

const mockCartData: CartData = {
  pizzeria: { id: 'p1', name: 'Roma', image: 'roma.jpg' },
  items: [{ id: 'item1', pizza: { id: 'pizza1', name: 'Margherita', ... }, quantity: 2, ... }],
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

    it('should increment quantity when adding same item', () => {
      store.addItem('pizza1', 1, 's1', [], 'p1');
      store.addItem('pizza1', 2, 's1', [], 'p1');
      expect(store.items().length).toBe(1);
      expect(store.items()[0].quantity).toBe(3);
    });

    it('should clear and reset when adding item from different pizzeria', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      store.addItem('pizza2', 1, null, [], 'p2');
      expect(store.pizzeria()).toEqual({ id: 'p2' });
      expect(store.items().length).toBe(1);
    });
  });

  describe('removeItem()', () => {
    it('should clear pizzeria when last item is removed', () => {
      store.addItem('pizza1', 1, null, [], 'p1');
      // flush any httpResource-triggered requests
      httpTesting.match((r) => r.url.includes('/api/orders/cart'))
        .forEach((r) => r.flush(mockCartData));
      const itemId = store.items()[0].id;
      store.removeItem(itemId);
      expect(store.pizzeria()).toBeNull();
    });
  });
});
```

### Key rules

- `TestBed.flushEffects()` after state changes to trigger effect-driven HTTP.
- `httpTesting.match()` for multi-request scenarios — flush all pending cart requests at once.
- `httpTesting.expectNone()` for asserting no requests should fire.
- Test **domain constraints** (same pizzeria, quantity merges) — these are the business rules.

---

## Forms & Wizard Services

### What to test

- Initial step / default values
- Computed values derived from form state (tip amount, discount, total)
- Step validation rules (required fields, format checks)
- Step progression (validate → mark success → advance)
- Cross-field effects (e.g., "use same as billing" clears billing fields)

### Pattern — Real Service, Stubbed External Dependencies

```typescript
import { TestBed } from '@angular/core/testing';
import { provideRouter, Routes } from '@angular/router';
import { signal } from '@angular/core';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { CheckoutWizard } from './checkout-wizard';
import { checkoutRoutes } from '../checkout.routes';
import { CartStore } from '../../cart/cart.store';
import { OrderApi } from '../../orders/order-api';

const cartStoreStub = {
  totalPrice: signal(30),
  pizzeria: signal<{ id: string } | null>({ id: 'p1' }),
  items: signal([] as any[]),
  cart: signal<any>(null),
  isEmpty: signal(false),
  clear: vi.fn(),
};

const orderApiStub = { createOrder: vi.fn() };
const testRoutes: Routes = [{ path: 'checkout', children: checkoutRoutes }];

describe('CheckoutWizard', () => {
  let service: CheckoutWizard;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [
        provideRouter(testRoutes),
        CheckoutWizard,                                   // real service
        { provide: CartStore, useValue: cartStoreStub },   // stub
        { provide: OrderApi, useValue: orderApiStub },     // stub
      ],
    });
    service = TestBed.inject(CheckoutWizard);
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
  });

  describe('billing fields effect', () => {
    it('should clear billing fields when useSameAsBilling is enabled', () => {
      service.checkoutForm.delivery.billingLocation().value.set({ city: 'Milan', country: 'Italy' });
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

---

## Route Config Files

### What to test

Route config files (`*.routes.ts`) contain only declarative route definitions — no runtime logic. They are **NOT tested**. Testing them would be testing Angular's router, not your code.

What you test instead:
- **Guards** that protect those routes → guard spec
- **Components** that are loaded by those routes → component spec
- **Route parameter reading** in components → component spec with `provideRouter`

**Do not write tests for `*.routes.ts` files.**

---

## Quick Reference Table

| Unit | TestBed? | Provide | Stub Strategy | Key Pattern |
|------|----------|---------|---------------|-------------|
| **Service (API)** | Yes | `provideHttpClientTesting()` | None — test real HTTP contract | `httpTesting.expectOne()` → assert method/body → `flush()` → assert state |
| **Service (pure logic)** | Yes | Nothing | Stub dependencies with `useValue` | `TestBed.inject()` → call method → assert return |
| **Presentational component** | Yes | Nothing | `NO_ERRORS_SCHEMA` for child components | `componentRef.setInput()` → `whenStable()` → DOM query → assert |
| **Page component** | Yes | `provideHttpClientTesting()` + `provideRouter([])` | Plain object stubs with signals | Control stub signals → `flushEffects()` → assert DOM states |
| **Guard** | Yes | `provideRouter([])` | `vi.fn()` stubs via `useValue` | `runInInjectionContext()` → assert `true` or `UrlTree` path |
| **Interceptor** | Yes | `provideHttpClient(withInterceptors([...]))` | None — test real pipeline | Real `HttpClient.get()` → assert request properties |
| **Pipe** | **No** | N/A | N/A | `new MyPipe()` → `.transform()` → assert output |
| **Directive** | Yes | Stub dependencies | Signal-based stubs | Host component → change signal → `whenStable()` → assert DOM |
| **Store** | Yes | `provideHttpClientTesting()` | None for store, flush HTTP side-effects | Mutate → `flushEffects()` → assert signals → `httpTesting.match().flush()` |
| **Wizard / Form service** | Yes | `provideRouter(testRoutes)` | Plain object stubs for external deps | Real service → mutate form state → `flushEffects()` → assert computed |

---

## Global Setup (Optional)

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

| Unit | The test should answer this question |
|------|--------------------------------------|
| Service | "Did it call the right endpoint with the right data and update state correctly?" |
| Component | "Given these inputs, does it render the right DOM with the right attributes?" |
| Page | "For each logical state (loading/empty/error/data), does it show the correct UI?" |
| Guard | "Does it allow or redirect, and redirect exactly where?" |
| Interceptor | "Did it modify (or not modify) the outgoing request as expected?" |
| Pipe | "Given this input, does it produce this output?" |
| Directive | "Does it manipulate the DOM correctly and react to state changes?" |
| Store | "Do mutations produce correct state and trigger correct side effects?" |
| Wizard | "Do the form rules, computed values, and validation logic work correctly?" |
