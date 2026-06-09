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
- [Dialogs & Overlays](#dialogs--overlays)
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
- **Alignment:** ✓ Mostly aligned. The project's `httpTesting.match()` pattern is a useful
  innovation not directly covered by Angular docs.

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
    return (await host.hasClass('btn--loading')) || (await host.getAttribute('aria-busy')) === 'true';
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

### Decision Rule

| Situation | Use |
|-----------|-----|
| Shared component library (Button, Input, Modal) | **Harnesses** — consumed by many tests, template changes cascade |
| One-off page component | **querySelector** — harness overhead not justified for a single consumer |
| Test needs to verify a child component's internal DOM | **querySelector** or `fixture.debugElement.query(By.directive(...))` |
| New project or new feature | **Harnesses** — start with the modern approach |

### NO_ERRORS_SCHEMA Guidance

- **Use when:** Testing a leaf component in isolation where child components have their own tests.
- **Avoid when:** Testing integration between a parent and its children. Use explicit `imports: [ChildA, ChildB]` instead.
- Angular docs warn against blanket `NO_ERRORS_SCHEMA` usage — it hides real template errors.

### Key rules

- Use `NO_ERRORS_SCHEMA` to ignore child component selectors. Each component has its own tests.
- Set signal-based inputs with `fixture.componentRef.setInput('name', value)`.
- `await fixture.whenStable()` after every async change (input set, state toggle).
- Test accessibility attributes (`aria-*`, `role`) as assertions — not an afterthought.
- **Alignment:** ⚠ Project uses `querySelector` where Angular recommends harnesses.
  See `README-TEST-INSIGHTS.md` for the improvement roadmap.

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

  it('should render the title and message from data', () => {
    expect(el.textContent).toContain('Are you sure?');
    expect(el.textContent).toContain('This action cannot be undone.');
  });

  it('should not show message element when message is not provided', async () => {
    // Reconfigure TestBed with different data
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

const mockPizza: Pizza = {
  id: 'pizza1', name: 'Margherita', basePrice: 9.5,
  image: 'marg.jpg', createdAt: '2024-01-01',
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
    TestBed.resetTestingModule();
    closeFn = vi.fn();
    TestBed.configureTestingModule({
      providers: [
        provideHttpClientTesting(),
        { provide: DialogRef, useValue: { close: closeFn } },
        { provide: DIALOG_DATA, useValue: dialogData },
      ],
      // Use real imports for form integration
      imports: [PizzaOrderFormDialog],
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
    httpTesting.expectOne('/api/options/sizes').flush([]);
    httpTesting.expectOne('/api/options/toppings').flush([]);
    await fixture.whenStable();
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
- Use `TestBed.resetTestingModule()` when reconfiguring providers with different data within the same `describe`.
- For dialogs with real forms, use real `imports` instead of `NO_ERRORS_SCHEMA` so that `FormRoot` and `FormField` directives wire up correctly.
- Test the close flow: user action → `expect(closeFn).toHaveBeenCalled()`.
- Test ARIA: dialog panel should have `role="document"` or `role="dialog"`, close button should have `aria-label`.
- **Alignment:** ✓ Project pattern matches Angular recommended for dialog testing. Both use `DialogRef` + `DIALOG_DATA` stubs.

### Angular docs reference: [material.angular.io/cdk/dialog/overview](https://material.angular.io/cdk/dialog/overview)

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

const mockPizzeria: PizzeriaSummary = { /* ... */ };
function makePage(items: PizzeriaSummary[], totalPages = 1): Page<PizzeriaSummary> { /* ... */ }

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
    httpTesting
      .expectOne((r) => r.url.includes('/api/pizzerias'))
      .flush(makePage([mockPizzeria]));
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
import { By } from '@angular/platform-browser';

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

### Decision Rule

| Situation | Use |
|-----------|-----|
| Testing page in its routing context | **RouterTestingHarness** — verifies guards, resolvers, component activation |
| Quick smoke test of page DOM structure | **provideRouter + NO_ERRORS_SCHEMA** — simpler setup, faster execution |
| New code or shared page component | **RouterTestingHarness** — starts with modern approach |

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

```typescript
import { TestBed } from '@angular/core/testing';
import { Router, provideRouter, UrlTree, PartialMatchRouteSnapshot } from '@angular/router';
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
      authGuard(
        { path: '' } as Route,
        [] as unknown as UrlSegment[],
        {} as PartialMatchRouteSnapshot,
      ),
    );
    expect(result).toBe(true);
  });

  // Not authenticated → redirect to login
  it('should return a UrlTree to /auth/login when not authenticated', () => {
    authStub.isAuthenticated.mockReturnValue(false);
    const result = TestBed.runInInjectionContext(() =>
      authGuard(
        { path: '' } as Route,
        [] as unknown as UrlSegment[],
        {} as PartialMatchRouteSnapshot,
      ),
    );
    expect(result).toBeInstanceOf(UrlTree);
    expect(router.serializeUrl(result as UrlTree)).toBe('/auth/login');
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
        noPizzeriaGuard(
          { path: '' } as Route,
          [] as unknown as UrlSegment[],
          {} as PartialMatchRouteSnapshot,
        ),
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
        noPizzeriaGuard(
          { path: '' } as Route,
          [] as unknown as UrlSegment[],
          {} as PartialMatchRouteSnapshot,
        ),
      ) as Observable<boolean | UrlTree>
    ).subscribe((r) => (result = r));
    httpTesting.expectOne('/api/pizzerias/admin/pizzeria').flush('Not found', {
      status: 404, statusText: 'Not Found',
    });
    expect(result).toBe(true);
  });
});
```

### Decision Rule

| Situation | Use |
|-----------|-----|
| Testing guard integration with routing | **RouterTestingHarness** — verifies guard + redirect + component |
| Testing guard logic in isolation | **runInInjectionContext** — faster, simpler setup |
| Multi-step guards (checkout) | **runInInjectionContext** with `provideRouter(testRoutes)` |
| Guard with async logic (HTTP) | Either — both patterns support async guards |

### Key rules

- For `runInInjectionContext` approach: use `vi.fn()` for stub methods — gives you `.mockReturnValue()` control.
- Always assert the **exact redirect URL**, not just `UrlTree` type.
- Use `provideRouter([])` — the real router is needed for `serializeUrl()`.
- For multi-step guards (like checkout), use the real route config with `provideRouter(testRoutes)` so the guard can find prerequisite step URLs.
- **CRITICAL for Angular 22+:** Guard functions now take 3 arguments — include `{} as PartialMatchRouteSnapshot` as the 3rd argument in all test invocations.
- **Alignment:** ⚠ Project uses `runInInjectionContext` where Angular recommends `RouterTestingHarness` for integration tests. Guard specs also need the Angular 22 3-argument signature update (see `README-TEST-INSIGHTS.md`).

### Angular docs reference: [angular.dev/guide/routing/testing](https://angular.dev/guide/routing/testing)

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

For Angular v21+, use **signal forms** for new form implementations. Signal forms integrate
natively with Angular's reactivity system and can be tested by directly manipulating form
control values and asserting on computed derivations.

Reference: `angular-developer` skill `signal-forms.md`, `effects.md`

### Project Pattern — Real Service, Stubbed External Dependencies

The realworld-angular project tests the wizard service as a real instance with stubbed
dependencies. Form state is manipulated through the service's public API, and effects
are flushed with `TestBed.flushEffects()`.

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
- **Alignment:** ✓ Mostly aligned. Angular v21+ signal forms are the recommended approach for new code. The project's real-service-with-stubs pattern is valid for the current form implementation.

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

| Unit | Angular Recommended | Project Pattern | Key Difference |
|------|-------------------|-----------------|----------------|
| Service | HttpTestingController | HttpTestingController | ✓ Same |
| Component | Component Harnesses | querySelector + NO_ERRORS_SCHEMA | Harness vs raw DOM |
| Page | RouterTestingHarness + real imports | provideRouter + NO_ERRORS_SCHEMA | Integration vs isolation |
| Guard | RouterTestingHarness | runInInjectionContext + vi.fn() | Full pipeline vs unit |
| Interceptor | withInterceptors + real HttpClient | withInterceptors + real HttpClient | ✓ Same |
| Pipe | new Pipe() | new Pipe() | ✓ Same |
| Directive | Host component | Host component | ✓ Same |
| Store | httpResource patterns | httpTesting.match() | ✓ Mostly same |
| Wizard | Real service + stubs | Real service + stubs | ✓ Same |

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
