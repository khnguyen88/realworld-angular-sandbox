# Test Documentation Update — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update three testing docs with Angular skill/MCP cross-check findings: GUIDE gets dual-pattern rewrite, INSIGHTS gets MCP cross-check section, TESTING gets alignment badges.

**Architecture:** No code changes — three markdown files rewritten in place. GUIDE is the largest change (~400 lines). INSIGHTS gets a new section (~150 lines). TESTING gets refinements (~30 lines). Cross-links added to all three.

**Tech Stack:** Markdown, Git

---

## File Map

| File | Action | Expected Lines |
|------|--------|---------------|
| `README-TEST-GUIDE.md` | Major rewrite | ~600 → ~750 |
| `README-TEST-INSIGHTS.md` | Restructure + new section | ~200 → ~350 |
| `README-TESTING.md` | Refinements | ~480 → ~510 |

---

### Task 1: Reorder GUIDE — move pipes to section 2

**Files:**
- Rename: `README-TEST-GUIDE.md` (read existing, rewrite entirely in subsequent tasks)

- [ ] **Step 1: Read current GUIDE for baseline**

Read `README-TEST-GUIDE.md` in full to confirm current state. Already done — the file is 953 lines.

- [ ] **Step 2: Write the new GUIDE header with cross-reference block**

Replace everything before the Table of Contents. Write:

```markdown
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
```

- [ ] **Step 3: Update Decision Flow section**

```markdown
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
```

- [ ] **Step 4: Rewrite the Pipes section (new section 2)**

Replace the old Pipes section (currently section 8) with this content, placed immediately after Decision Flow:

```markdown
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
```

- [ ] **Step 5: Commit**

```bash
git add README-TEST-GUIDE.md
git commit -m "docs: reorder guide and add cross-reference header, move pipes to section 2"
```

---

### Task 2: Rewrite Services and Interceptors sections

**Files:**
- Modify: `README-TEST-GUIDE.md`

- [ ] **Step 1: Update Services section with dual-pattern structure**

Replace the existing Services section:

```markdown
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

reference: `angular-developer` skill `testing-fundamentals.md`

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
```

- [ ] **Step 2: Update Interceptors section with dual-pattern structure**

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add README-TEST-GUIDE.md
git commit -m "docs: add dual-pattern structure to services and interceptors sections"
```

---

### Task 3: Rewrite Stores and Components sections

**Files:**
- Modify: `README-TEST-GUIDE.md`

- [ ] **Step 1: Update Stores section**

Replace the existing Stores section with:

```markdown
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
```

- [ ] **Step 2: Rewrite Components section with harnesses**

Replace the existing Components section with dual-pattern content:

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add README-TEST-GUIDE.md
git commit -m "docs: add dual-pattern components section with harnesses and rewrite stores"
```

---

### Task 4: Rewrite Page Components and Guards sections

**Files:**
- Modify: `README-TEST-GUIDE.md`

- [ ] **Step 1: Rewrite Page Components with RouterTestingHarness**

Replace the Page Components section:

```markdown
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
```

- [ ] **Step 2: Rewrite Guards section with RouterTestingHarness**

Replace the Guards section (keeping async guard pattern and RouterTestingHarness reference):

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add README-TEST-GUIDE.md
git commit -m "docs: rewrite page components and guards with RouterTestingHarness and Angular 22 signatures"
```

---

### Task 5: Rewrite Directives, Forms, Route Config, Quick Reference sections

**Files:**
- Modify: `README-TEST-GUIDE.md`

- [ ] **Step 1: Rewrite Directives section (unchanged structure)**

Keep existing content but add alignment badge:

```markdown
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
```

- [ ] **Step 2: Rewrite Forms section with signal-forms reference**

```markdown
## Forms & Wizard Services

### What to test

- Initial step / default values
- Computed values derived from form state (tip amount, discount, total)
- Step validation rules (required fields, format checks)
- Step progression (validate → mark success → advance)
- Cross-field effects (e.g., "use same as billing" clears billing fields)

### Angular Recommended — Signal Forms

Angular v21+ recommends signal forms for new form testing. Use signal-based form APIs
with `TestBed.flushEffects()` to trigger computed signal updates.

Reference: `angular-developer` skill `signal-forms.md`, `effects.md`

### Project Pattern — Real Service, Stubbed Dependencies

The realworld-angular project uses the real wizard service with stubbed external
dependencies (CartStore, OrderApi). The form state is mutated directly through
the service's public API, and `TestBed.flushEffects()` triggers computed signal updates.

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
- **Alignment:** ✓ Mostly aligned. The project uses signal forms internally. New code should
  reference the Angular skill's `signal-forms.md` for the latest signal-form testing patterns.
```

- [ ] **Step 3: Rewrite Route Config (unchanged) + Quick Reference (dual-column)**

Route Config stays the same. Replace Quick Reference with:

```markdown
## Quick Reference Table

| Unit | Angular Recommended | Project Pattern | Alignment |
|------|-------------------|-----------------|-----------|
| **Service (API)** | `HttpTestingController` — intercept requests, assert method/body, flush response | Same | ✓ |
| **Service (pure logic)** | `TestBed.inject()` → call method → assert return | Same | ✓ |
| **Presentational component** | `ComponentHarness` — loader.getHarness(ButtonHarness) → interact | `querySelector` + `NO_ERRORS_SCHEMA` → componentRef.setInput() | ⚠ |
| **Page component** | `RouterTestingHarness` + real child imports | `provideRouter([])` + `NO_ERRORS_SCHEMA` | ⚠ |
| **Guard** | `RouterTestingHarness` — navigateByUrl('/admin') → assert URL | `runInInjectionContext()` + `vi.fn()` — 3 args | ⚠ |
| **Interceptor** | `provideHttpClient(withInterceptors([...]))` → real HttpClient | Same | ✓ |
| **Pipe** | `new MyPipe()` → `.transform()` → assert output | Same | ✓ |
| **Directive** | Host component → change signal → `whenStable()` → assert DOM | Same | ✓ |
| **Store** | `TestBed.flushEffects()` + `HttpTestingController` | Same + `httpTesting.match()` | ✓ |
| **Wizard / Form service** | Signal forms + real service + stubs | Real service + stubs | ✓ |

### Alignment Summary

| Status | Count | Categories |
|--------|-------|------------|
| ✓ Aligned | 7 | Services, Interceptors, Pipes, Directives, Stores, Forms, Route Config |
| ⚠ Misaligned | 3 | Components, Pages, Guards |

See `README-TEST-INSIGHTS.md` for the improvement roadmap.

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
```

- [ ] **Step 4: Commit**

```bash
git add README-TEST-GUIDE.md
git commit -m "docs: finalize guide with directives, forms, and dual-column quick reference"
```

---

### Task 6: Update README-TEST-INSIGHTS.md

**Files:**
- Modify: `README-TEST-INSIGHTS.md`

- [ ] **Step 1: Read current INSIGHTS**

Already read — 202 lines, 7 sections.

- [ ] **Step 2: Write the new INSIGHTS content**

Replace the entire file with:

```markdown
# Test Coverage & Unit Test Quality — Insights

> **Status snapshot (2026-06-08):** The test suite is comprehensive in scope and well-structured, but it is **not currently green**. 18 TypeScript compile errors prevent `pnpm run test` from producing any results. All stem from Angular 22.0's `CanActivateFn` / `CanMatchFn` signature change. This document evaluates the suite against two external standards: Angular official docs (via MCP `search_documentation`) and Angular skill references.

---

## TL;DR

| Question | Answer |
| --- | --- |
| How many test files? | **60 `*.spec.ts`** co-located with source. |
| How much test code? | **~5,188 lines** of test code vs. **~3,743 lines** of source. |
| Is the suite green? | **No** — `pnpm run test` fails at the TypeScript build step with **18 errors across 5 guard spec files**. |
| Angular Skill/MCP Cross-Check | **7/10 categories aligned** with official recommendations. 2 categories have actionable gaps (components, guards), 1 category blocked (guard signatures outdated). |
| How does it perform on the unit-test axis? | **Strong** in pattern discipline and breadth, but **failing** in Angular version compatibility and alignment with modern practices. |
| Is coverage measured? | **No** — no `vitest.config.ts`, no `@vitest/coverage-v8`, no thresholds in `package.json`. |
| Are there other test types? | **None** — no e2e, no integration, no a11y, no visual regression. |

---

## 1. Project Context (from `README.md`)

The project is a **learning / reference implementation** of a RealWorld Angular SPA (Angular 22, standalone components, signals, lazy routes, SSE). It targets a deployed API at `api.realworldangular.org` and is **explicitly a playground, not a real marketplace**.

That framing matters for the conclusions below: this is reference code whose purpose is partly to *demonstrate* testing patterns, so the quality of the *patterns* themselves matters as much as the percentage coverage.

---

## 2. Current Run Status — RED

`pnpm run test` (i.e. `ng test --watch=false`) currently **fails to compile**. 18 TypeScript errors, all `TS2554` ("Expected 3 arguments, but got 2"):

| File | Errors | Root cause |
| --- | --- | --- |
| `core/guards/auth/auth.guard.spec.ts` | 4 | Angular 22.0 changed `CanActivateFn` / `CanMatchFn` to require a 3rd argument (`currentSnapshot: PartialMatchRouteSnapshot`). Guard specs call guards with only 2 args (`route`, `segments`). |
| `core/guards/role/role.guard.spec.ts` | 4 | Same — `roleGuard([...])(route, segments)` missing `currentSnapshot`. |
| `features/checkout/guards/cart-not-empty.guard.spec.ts` | 2 | Same — `cartNotEmptyGuard(route, segments)` missing `currentSnapshot`. |
| `features/checkout/guards/checkout-step.guard.spec.ts` | 5 | Same — `checkoutStepGuard(step)(route, segments)` missing `currentSnapshot`. |
| `features/pizzerias/guards/no-pizzeria.guard.spec.ts` | 3 | Same — `noPizzeriaGuard(route, segments)` missing `currentSnapshot`. |

**Pattern:** Angular 22.0 introduced a breaking change to the functional guard signature. The production guards compile fine (they match the new signature), but the test invocations pass only 2 arguments — the old Angular 21 signature. All 18 errors are in 5 guard spec files; no other test files are affected.

**Hidden errors:** Once the 18 guard-signature errors are fixed, the original fixture-drift errors from the 2026-06-03 snapshot (`TS2739` mock-model mismatches + `TS2339` `canDeactivate`) will likely re-surface. The TypeScript compiler stops at the guard specs first, so these errors are currently invisible.

**Lint status (unchanged):** `pnpm run lint` produces 19 errors (19 errors, 0 warnings) across 8 files — 14 `@typescript-eslint/no-explicit-any`, 1 `no-unused-vars`, 6 `no-empty-function` (IntersectionObserver stubs). These are pre-existing upstream issues, not introduced by the sync.

> **Bottom line:** Right now you can't run the suite. The fix is mechanical: add a 3rd `{} as PartialMatchRouteSnapshot` argument to every guard invocation in the 5 affected spec files (~18 call sites).

---

## 3. Angular Skill/MCP Cross-Check

The following table compares each test category against Angular official recommendations
(sourced from `angular-developer` skill references and `search_documentation` MCP tool).

| Category | Project Pattern | Angular Recommendation | Alignment | Priority |
|----------|----------------|----------------------|-----------|----------|
| Services | `HttpTestingController` + `provideHttpClientTesting()` | `HttpTestingController` | ✓ Aligned | — |
| Interceptors | `provideHttpClient(withInterceptors([...]))` + real `HttpClient` | Same | ✓ Aligned | — |
| Pipes | `new Pipe()` no TestBed | `new Pipe()` no TestBed | ✓ Aligned | — |
| Directives | Host component with `signal()` stub | Host component | ✓ Aligned | — |
| Stores | `TestBed.flushEffects()` + `httpTesting.match()` | `httpResource` testing | ✓ Mostly aligned | Low |
| Forms | Real service + plain stubs | Signal forms + real service | ✓ Mostly aligned | Low |
| Components | `querySelector` + `NO_ERRORS_SCHEMA` | Component Harnesses | ⚠ Misaligned | Medium |
| Pages | `provideRouter([])` + `NO_ERRORS_SCHEMA` | `RouterTestingHarness` + real imports | ⚠ Misaligned | Medium |
| Guards | `runInInjectionContext()` with 2 args (outdated) | `RouterTestingHarness` with 3 args (Angular 22) | ✗ Blocked | High |
| Route Config | No tests | No tests | ✓ Aligned | — |

**Score: 7/10 categories aligned, 2 with actionable gaps, 1 blocked.**

### Detail on Misaligned Categories

**Components (⚠):** Angular recommends Component Harnesses (`TestbedHarnessEnvironment`) as the standard way to interact with components in tests. The project uses raw `querySelector` and sets inputs via `componentRef.setInput()`. Harnesses provide better refactoring resilience — template changes don't break tests. Mitigation: add harnesses to high-value shared components (Button, Input, Modal) consumed by many tests.

**Pages (⚠):** Angular recommends `RouterTestingHarness` with real child component imports for page tests. The project uses `provideRouter([])` and `NO_ERRORS_SCHEMA`, which verifies page structure but not child component integration. Mitigation: adopt `RouterTestingHarness` for critical page flows.

**Guards (✗):** Two issues: (1) the project uses `runInInjectionContext()` where `RouterTestingHarness` is recommended for integration-testing guards with their routes, and (2) the 2-argument calls are incompatible with Angular 22's 3-argument signature. This is the highest-priority fix.

---

## 4. Unit-Test Quality — Strengths

What the spec files *do* well (sampled across `cart.store.spec.ts`, `auth.spec.ts`, `auth.guard.spec.ts`, `modal.spec.ts`):

### 4.1 Patterns are consistent and idiomatic

- **HTTP services** uniformly use `HttpTestingController` + `provideHttpClientTesting()`, with `httpTesting.verify()` in `afterEach` to catch leaked requests. This is the right pattern and it's used everywhere.
- **Guards** are tested as functional units via `TestBed.runInInjectionContext()` with `vi.fn()`-stubbed dependencies. They assert both the truthy and `UrlTree` branches and even assert the *serialized* URL (e.g. `/auth/login`), which catches routing regressions.
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
- `credentials.interceptor.spec.ts` covers the negative case (Photon API requests should *not* receive `withCredentials`).

### 4.5 Reactive primitives are well exercised

The `cart.store.spec.ts` is the standout here — it tests the `httpResource` cart-sync effect under `addItem`, `updateQuantity`, `removeItem`, `clear`, and the cross-pizzeria reset case. That's the kind of behavior that's easy to leave uncovered, and it's covered.

### 4.6 Validated against official Angular docs

Cross-checked all 10 test categories against `angular-developer` skill references and MCP `search_documentation`. 7 of 10 categories are fully aligned with official recommendations. See Section 3 for the detailed breakdown.

---

## 5. Unit-Test Quality — Weaknesses

### Blocking (must fix to run tests)

**5.1 Angular version compatibility — 18 guard signature errors**
The 18 `TS2554` errors all stem from the Angular 21 → 22 upgrade. Angular 22.0 changed `CanActivateFn` and `CanMatchFn` to accept a 3rd `currentSnapshot: PartialMatchRouteSnapshot` argument. The production guards were updated to match, but the spec files still call guards with the old 2-argument signature.

**5.2 Hidden fixture-drift errors**
Once the guard errors are fixed, 5 additional TypeScript errors will re-surface: `TS2739` mock-model mismatches (mock objects missing `tipAmount`, `scheduledAt` fields) and `TS2339` `canDeactivate` reference in `checkout-page.spec.ts`. These are currently masked because the compiler stops at the guard specs first.

### Structural (design improvements)

**5.3 No component harnesses**
The project uses `querySelector` for DOM interaction across all 34 component specs. Angular recommends Component Harnesses as the standard approach. Harnesses insulate tests from internal template refactors — changing a CSS class or element structure in the component doesn't break tests using harnesses. The highest-value targets for harness adoption are Button, Input, and Modal (the most widely consumed shared components).

**5.4 No RouterTestingHarness**
Guard and page tests don't use `RouterTestingHarness`, which Angular recommends as the standard tool for testing routing behavior. The project's `runInInjectionContext()` approach tests guards in isolation but doesn't verify that guards actually protect routes in a real navigation flow.

**5.5 No code-coverage measurement**
There is no `vitest.config.ts`, no coverage script in `package.json`, no `coverage/` directory, no thresholds. For a reference project, this is a real gap — readers can't see the actual numbers.

**5.6 Heavy reliance on `NO_ERRORS_SCHEMA`**
For shared / leaf components, this is fine — they really do have stub children. But for **page components** (e.g. `login-page.spec.ts`, `cart-page.spec.ts`) it means the test is verifying the page's own template renders the right *structural shape* (form, inputs, submit) but not that the child components actually integrate correctly.

**5.7 Coverage gaps beyond unit tests**
`README-TESTING.md` already calls these out, but they bear repeating: no e2e, no integration tests against real API, no accessibility tests, no visual regression, no route-integration tests.

**5.8 The pipe test imports `environment` from the file path, not the symbol**
`catalog-image-url.pipe.spec.ts` imports `'../../../environments/environment'` and uses `environment.apiBaseUrl`. The test runs against the default `environment.ts` (not `.development.ts`). If those two diverge, the test will silently exercise the wrong base URL.

**5.9 The test count is the metric, not the coverage**
With 60 specs at ~86 lines each on average, this *looks* thorough. But without a coverage report, you can't tell whether the suite has 80% line coverage or 35%. The file count is a proxy, and a noisy one.

---

## 6. Improvement Roadmap

### Tier 1 — Unblock the test suite

1. **Fix the 18 guard-spec errors.** Add the 3rd `currentSnapshot` argument to every guard invocation across the 5 affected spec files. This is ~18 mechanical changes and unblocks the test suite.
2. **Fix the re-surfaced fixture-drift errors.** Once the guard errors are resolved, update the mock fixtures for `mockOrder` / `AdminOrderListItem` (add `tipAmount`, `scheduledAt`) and resolve the `canDeactivate` reference in `checkout-page.spec.ts`.

### Tier 2 — Align with Angular recommendations

3. **Add component harnesses to high-value shared components.** Start with Button, Input, and Modal — the components consumed by the most tests. Create harness files in `testing/` subdirectories. See `README-TEST-GUIDE.md` for the pattern.
4. **Add RouterTestingHarness examples for guard integration tests.** Demonstrate the full routing pipeline for at least one guard to establish the pattern. See `README-TEST-GUIDE.md` for the reference implementation.
5. **Add signal-forms testing patterns** for new form tests. Reference the `angular-developer` skill's `signal-forms.md`.

### Tier 3 — Measure and protect

6. **Add coverage.** Install `@vitest/coverage-v8`, add a `test:coverage` script, and generate a report. Even a single run committed to the repo as an artifact answers "how well is this tested?" with data instead of vibes.
7. **Add a CI guard.** A minimal GitHub Actions job (or equivalent) that runs `pnpm install && pnpm run test` on every PR would have caught both the Angular 22 signature change and the original fixture drift.
8. **Add 1–2 smoke e2e tests** with Playwright for the *browse → add-to-cart* flow. The project is integrated against a real API, so this is high-value and low-effort.
9. **Consider a shared test-fixture library** in `src/app/core/testing/` so model additions don't require touching every spec.
10. **Add a single accessibility assertion** (`axe.run()`) to one page spec to establish the pattern; expand from there.

---

## 7. One-line verdict

The unit-test *discipline* here is genuinely good — patterns, structure, and breadth are all in order — but the suite is currently **red from an Angular 22 guard-signature change (18 errors), has a hidden layer of fixture-drift errors underneath, has no coverage measurement, and is the only layer of testing**. The MCP/skill cross-check reveals 7/10 categories are aligned with Angular recommendations, with 2 categories (components, pages) having actionable gaps and 1 (guards) blocked. Fix the guard specs, then the fixtures, add coverage, and the story changes from "looks committed" to "actually trustworthy."

---

## Appendix: Data Sources

- `README.md` — project description, roles, route map
- `README-TESTING.md` — author's own testing documentation
- `README-TEST-GUIDE.md` — Angular recommended + project pattern guide
- `package.json` — scripts and dev dependencies (Angular 22.0.0, Vitest 4.1.6, TypeScript 6.0.3)
- `pnpm exec ng test --watch=false` — current run output (failed build, 18 TS2554 errors across 5 guard spec files)
- `pnpm exec ng lint` — current run output (19 errors, 0 warnings, across 8 files)
- `angular-developer` skill references: `testing-fundamentals.md`, `component-harnesses.md`, `router-testing.md`, `resource.md`, `signal-forms.md`
- MCP `search_documentation` — Angular 22 official testing documentation
- `find src -name "*.spec.ts" | wc -l` → 60
- `find src -name "*.ts" -not -name "*.spec.ts" | wc -l` → 84
- `wc -l` of all spec files → 5,188 lines
- `wc -l` of all source files → 3,743 lines
```

- [ ] **Step 3: Commit**

```bash
git add README-TEST-INSIGHTS.md
git commit -m "docs: restructure insights with MCP/skill cross-check and tiered improvement roadmap"
```

---

### Task 7: Update README-TESTING.md

**Files:**
- Modify: `README-TESTING.md`

- [ ] **Step 1: Add cross-reference header**

Insert after the title/description paragraph, before the Table of Contents:

```markdown
> **Testing Docs Index:**
> - **README-TEST-GUIDE.md** — How to write tests (Angular recommended + project patterns)
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — This file: factual inventory of what exists (60 specs, categories, patterns)
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution
```

- [ ] **Step 2: Add alignment badges to pattern subsections**

For each pattern subsection in the Testing Patterns section, add an alignment badge line after the subsection title:

**Services & APIs** — add after the title:
```
> **Angular Alignment:** ✓ Fully aligned with official recommendations
```

**Stores** — add after the title:
```
> **Angular Alignment:** ✓ Fully aligned. The `httpTesting.match()` pattern is a project innovation not directly covered by Angular docs but functionally correct.
```

**Interceptors** — add after the title:
```
> **Angular Alignment:** ✓ Fully aligned with official recommendations
```

**Functional Guards** — add after the title, plus Angular 22 note:
```
> **Angular Alignment:** ⚠ Works but has a better alternative. The `runInInjectionContext()` approach tests guard logic in isolation but Angular recommends `RouterTestingHarness` for integration testing guards with their routes. Also, the current specs use the Angular 21 2-argument signature — Angular 22 requires a 3rd `currentSnapshot` argument. See `README-TEST-GUIDE.md` for both patterns.
```

**Components** — add after the title:
```
> **Angular Alignment:** ⚠ Works but has a better alternative. Angular recommends Component Harnesses (`TestbedHarnessEnvironment`) as the standard way to interact with components in tests. The project uses `querySelector` which is simpler but more brittle against template refactors. See `README-TEST-GUIDE.md` for both patterns.
```

**Dialogs & Overlays** — add after the title:
```
> **Angular Alignment:** ✓ Fully aligned. The `DIALOG_DATA` + `DialogRef` pattern is the standard approach.
```

**Directives** — add after the title:
```
> **Angular Alignment:** ✓ Fully aligned. The host component pattern is the canonical approach for testing structural directives.
```

**Pipes** — add after the title:
```
> **Angular Alignment:** ✓ Fully aligned. Instantiate directly with `new Pipe()` — no TestBed needed.
```

- [ ] **Step 3: Update Coverage Gap Analysis**

Add to the coverage gap table entries:

Under "Route integration" row, change status from "Partial" to:
```
| **Route integration**    | Partial             | Guide now documents `RouterTestingHarness` pattern in `README-TEST-GUIDE.md`. Guards tested with `runInInjectionContext()` cover logic but not full integration. |
```

Add a new row:
```
| **Component harnesses**  | Missing             | No harness usage in 34+ component specs. Guide documents the recommended pattern. See `README-TEST-INSIGHTS.md` for prioritization. |
```

Update the Recommendations section (3 bullet points → 4 bullet points):

```markdown
### Recommendations

If expanding test coverage:

1. **E2E** — Add Playwright (preferred for modern Angular) or Cypress for critical user journeys: browse pizzerias, add to cart, checkout flow, admin panel CRUD, invite-token registration.

2. **Integration** — Add a small suite that hits the deployed API (`api.realworldangular.org`) to verify contract compatibility. These can share the same `describe`/`it` Vitest syntax since Vitest supports async tests natively.

3. **Accessibility** — Integrate `axe-core` into component tests or add a dedicated a11y check in CI. The `web-accessibility-auditor` superpowers skill can also audit pages on demand.

4. **Coverage** — Add Vitest coverage configuration (`coverage.provider: 'v8'` or `istanbul`) with minimum thresholds in CI.

For a prioritized improvement roadmap with timelines, see `README-TEST-INSIGHTS.md`.
```

- [ ] **Step 4: Commit**

```bash
git add README-TESTING.md
git commit -m "docs: add alignment badges, cross-references, and update coverage gaps"
```

---

### Task 8: Cross-link all three documents

**Files:**
- Verify: `README-TEST-GUIDE.md`, `README-TEST-INSIGHTS.md`, `README-TESTING.md`

- [ ] **Step 1: Verify the cross-reference header exists in all three files**

```bash
grep -n "Testing Docs Index" README-TEST-GUIDE.md README-TEST-INSIGHTS.md README-TESTING.md
```

Expected output: All three files should show the header block.

- [ ] **Step 2: Verify no broken internal links**

```bash
grep -c "README-TEST" README-TEST-GUIDE.md
grep -c "README-TEST" README-TEST-INSIGHTS.md
grep -c "README-TEST" README-TESTING.md
```

Expected: Each file references the other two (plus CHRONOLOGY).

- [ ] **Step 3: Verify alignment summary sections are consistent**

- GUIDE: Check that 7 ✓, 3 ⚠ matches INSIGHTS
- TESTING: Check that each alignment badge matches the GUIDE/INSIGHTS alignment table
- INSIGHTS: Check that tiered roadmap priorities match the gap analysis

- [ ] **Step 4: Commit**

```bash
git add README-TEST-GUIDE.md README-TEST-INSIGHTS.md README-TESTING.md
git commit -m "docs: cross-link all three testing documents"
```

---

### Task 9: Verify — read all three files for final consistency

- [ ] **Step 1: Verify GUIDE has all 11 sections**

Read `README-TEST-GUIDE.md` and check the table of contents against the actual sections.

- [ ] **Step 2: Verify INSIGHTS has all 7 sections**

Read `README-TEST-INSIGHTS.md` and check section headings.

- [ ] **Step 3: Verify TESTING has all alignment badges**

Read `README-TESTING.md` and check each pattern subsection has an alignment badge.

- [ ] **Step 4: Commit (if any fixes)**

```bash
git add README-TEST-GUIDE.md README-TEST-INSIGHTS.md README-TESTING.md
git commit -m "docs: final verification fixes for test documentation update"
```
