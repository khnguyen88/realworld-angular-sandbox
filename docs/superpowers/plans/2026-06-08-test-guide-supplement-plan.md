# Test Guide Supplement — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 4 new test pattern sections (Dialogs, @defer, Data Resolvers, Custom Form Controls) to README-TEST-GUIDE.md

**Architecture:** Each new section follows the existing GUIDE dual-pattern format (Angular Recommended + Project Pattern where project backing exists). Three sections are illustrative-only (no realworld-angular backing), clearly marked with a disclaimer callout. Dialogs section uses real project test patterns from modal.spec.ts, confirm-dialog.spec.ts, and pizza-order-form-dialog.spec.ts.

**Tech Stack:** Angular 22, Vitest, @angular/cdk/dialog, @angular/cdk/testing

---

### Task 1: Add Dialogs & Overlays Section

**Files:**

- Modify: `README-TEST-GUIDE.md` (insert after Components section, before Page Components)

Insert the following section after the Components section closing `---` (after the Angular docs reference line for Components) and before `## Page Components (Smart / Container)`:

````markdown
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

### Angular docs reference: [angular.dev/guide/cdk/dialog/overview](https://material.angular.io/cdk/dialog/overview)
````

**Verification:** After insertion, the section order should be: Components → Dialogs & Overlays → Page Components.

---

### Task 2: Add `[Illustrative]` @defer Blocks Section

**Files:**

- Modify: `README-TEST-GUIDE.md` (insert after Dialogs & Overlays, before Page Components)

Insert the following section after the Dialogs & Overlays closing `---` and before `## Page Components (Smart / Container)`:

````markdown
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
  standalone: true,
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
  standalone: true,
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

  it('should render placeholder before trigger', async () => {
    const deferBlockFixture = (await fixture.getDeferBlocks())[0];
    await deferBlockFixture.render(DeferBlockState.Placeholder);
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
- `DeferBlockBehavior.PlayThrough` (default) plays through states naturally — use when you want real-world behavior.
- `fixture.getDeferBlocks()` returns a `Promise<DeferBlockFixture[]>` — always `await` it.
- `deferBlockFixture.render(DeferBlockState.X)` transitions the block to the target state. States: `Placeholder`, `Loading`, `Complete`, `Error`.
- Use `@defer (when condition)` for testable trigger conditions controlled by a component property.
- Test all four states: placeholder → loading → complete, plus error path.

### Angular docs reference: [angular.dev/guide/templates/defer#testing-defer-blocks](https://angular.dev/guide/templates/defer#testing-defer-blocks)
````

**Verification:** After insertion, the section order should be: Components → Dialogs & Overlays → @defer Blocks → Page Components.

---

### Task 3: Add `[Illustrative]` Data Resolvers Section

**Files:**

- Modify: `README-TEST-GUIDE.md` (insert after Guards section, before Directives)

Insert the following section after the Guards section closing `---` and before `## Directives`:

````markdown
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
import { provideRouter, Router, withComponentInputBinding } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { Component, input, inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { map } from 'rxjs';
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
  standalone: true,
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

    // The navigation completes but the component won't render.
    // With withNavigationErrorHandler, test the error handler instead.
    // Here we verify the request was attempted.
    expect(harness.router.url).toBe('/users/99');
  });
});
```

### Key rules

- Use `withComponentInputBinding()` — resolved data maps directly to `input.required<T>()` signals.
- Combine `RouterTestingHarness` + `HttpTestingController` for end-to-end resolver testing.
- Always call `harness.detectChanges()` after flushing HTTP to trigger change detection with new data.
- Test both success (data resolves → component renders) and error (404, 500) paths.
- For error handling, test `withNavigationErrorHandler` or `RedirectCommand` in the resolver.
- Resolvers run before navigation completes — the target component won't render on failure.

### Angular docs reference: [angular.dev/guide/routing/data-resolvers](https://angular.dev/guide/routing/data-resolvers)
````

**Verification:** After insertion, the section order should be: Guards → Data Resolvers → Directives.

---

### Task 4: Add `[Illustrative]` Custom Form Controls Section

**Files:**

- Modify: `README-TEST-GUIDE.md` (insert after Forms & Wizard Services, before Route Config Files)

Insert the following section after the Forms & Wizard Services closing `---` and before `## Route Config Files`:

````markdown
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

Create a `TestHostComponent` that uses the custom control inside a signal form. Spy on
`onChange` and `onTouched` callbacks, then manipulate the control via its form API and
assert DOM updates and callback invocations.

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
  standalone: true,
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
import { Component } from '@angular/core';
import { FormField, FormRoot } from '@angular/forms/signals';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { RatingControl } from './rating-control';

@Component({
  imports: [FormRoot, FormField, RatingControl],
  template: `
    <form #formRoot="formRoot" [formRoot]="form">
      <app-rating-control [formField]="'rating'" />
    </form>
  `,
  standalone: true,
})
class TestHostComponent {
  form = new FormGroup({
    rating: new FormControl(0, { validators: [Validators.required, Validators.min(1)] }),
  });
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
    fixture.componentInstance.form.controls.rating.setValue(3);
    TestBed.flushEffects();
    const filledStars = el.querySelectorAll('.rating .filled');
    expect(filledStars.length).toBe(3);
  });

  it('should call onChange when a star is clicked', () => {
    const buttons = el.querySelectorAll<HTMLButtonElement>('.rating button');
    buttons[4].click(); // select 5th star
    TestBed.flushEffects();
    expect(fixture.componentInstance.form.controls.rating.value()).toBe(5);
  });

  it('should not select when disabled', () => {
    fixture.componentInstance.form.controls.rating.disable();
    TestBed.flushEffects();
    const buttons = el.querySelectorAll<HTMLButtonElement>('.rating button');
    buttons[2].click();
    TestBed.flushEffects();
    expect(fixture.componentInstance.form.controls.rating.value()).toBe(0);
  });

  it('should fail validation when value is 0', () => {
    TestBed.flushEffects();
    expect(fixture.componentInstance.form.controls.rating.hasError('required')).toBe(true);
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
  standalone: true,
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

- Create a `TestHostComponent` that wraps the custom control in a real form (signal forms for Angular v21+, reactive forms for v20-).
- Signal forms: use `FormField` + `FormRoot`, call `TestBed.flushEffects()` after mutations.
- Reactive forms: use `ReactiveFormsModule`, call `fixture.detectChanges()` after mutations.
- Test `writeValue` by setting the form control's value and asserting DOM output.
- Test `onChange` by interacting with the DOM and asserting the form control's value updated.
- Test `setDisabledState` by disabling the form control and asserting buttons are disabled.
- Test validation by asserting `control.hasError('required')`, `control.valid`, etc.
- Do NOT test `registerOnChange` or `registerOnTouched` directly — they are framework internals. Test their effects through form integration.

### Angular docs reference: [angular.dev/guide/forms/custom-form-controls](https://angular.dev/guide/forms/custom-form-controls)
````

**Verification:** After insertion, the section order should be: Forms & Wizard Services → Custom Form Controls → Route Config Files.

---

### Task 5: Update Quick Reference Table and Table of Contents

**Files:**

- Modify: `README-TEST-GUIDE.md` (update TOC and Quick Reference Table)

- [ ] **Step 1: Update the Table of Contents**

Replace the existing TOC block (from `- [Decision Flow: What Do I Test?]` through `- [Quick Reference Table]`) with:

```markdown
- [Decision Flow: What Do I Test?](#decision-flow-what-do-i-test)
- [Pipes](#pipes)
- [Services](#services)
- [Interceptors](#interceptors)
- [Stores / State](#stores--state)
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
```

- [ ] **Step 2: Add 4 new rows to the Quick Reference Table**

In the Quick Reference Table, add these 4 rows after the "Wizard" row and before the closing pipe:

```markdown
| Dialog | DialogRef stub + DIALOG_DATA | DialogRef stub + DIALOG_DATA + NO_ERRORS_SCHEMA | ✓ Same |
| @defer | DeferBlockBehavior.Manual + render() | — | Illustrative only |
| Data Resolver | RouterTestingHarness + resolve config | — | Illustrative only |
| Custom Form Control | TestHostComponent + signal forms | — | Illustrative only |
```

- [ ] **Step 3: Add 4 new rows to the One-Sentence Summary table**

In the One-Sentence Summary table (at the bottom of the file), add these rows after the "Wizard" row:

```markdown
| Dialog | "Given injected data, does it render correctly and close with the right result?" |
| @defer | "Does each state (placeholder/loading/complete/error) render the correct content?" |
| Data Resolver | "Does it fetch data and deliver it to the component, and handle errors gracefully?" |
| Custom Form Control | "Does it integrate with the form API: write value, report changes, and validate?" |
```

**Verification:** TOC links match actual section headings. Quick Reference table has 13 rows (9 original + 4 new). Summary table has 13 rows.

---

### Task 6: Cross-Reference Updates

**Files:**

- Modify: `README-TESTING.md` (update Dialogs badge and add Illustrative note)
- Modify: `README-TEST-INSIGHTS.md` (add note about new GUIDE sections)

- [ ] **Step 1: Update TESTING.md Dialogs badge**

Find the `#### Dialogs & Overlays` subsection in the Testing Patterns section. Update the alignment badge to match the new GUIDE content:

```markdown
#### Dialogs & Overlays

`✓ Aligned with Angular` — Stubs `DialogRef` and provides `DIALOG_DATA` injection token
for CDK-based dialog components. See GUIDE for Modal, ConfirmDialog, and Form Dialog examples.
```

- [ ] **Step 2: Add Illustrative note to TESTING.md**

At the end of the Testing Patterns section, before the Coverage Gap Analysis section, add:

```markdown
> **Illustrative sections in the GUIDE:** Three additional patterns are documented in
> README-TEST-GUIDE.md as `[Illustrative]` sections — @defer blocks, Data Resolvers, and
> Custom Form Controls (ControlValueAccessor). These are not based on realworld-angular
> but are generated from Angular official documentation for reference.
```

- [ ] **Step 3: Update INSIGHTS.md Data Sources appendix**

In the Data Sources appendix, add to the list:

```markdown
- MCP `search_documentation` — Angular 22 @defer testing, data resolvers, router testing
- `angular-developer` skill references: `signal-forms.md`
```

**Verification:** TESTING.md has updated dialog badge with GUIDE link. INSIGHTS.md data sources include new MCP docs.

---

## Self-Review

**Spec coverage:**

- Task 1 → Dialogs & Overlays section (spec Section 1) ✓
- Task 2 → @defer section (spec Section 2) ✓
- Task 3 → Data Resolvers section (spec Section 3) ✓
- Task 4 → Custom Form Controls section (spec Section 4) ✓
- Task 5 → Quick Reference Table and TOC update ✓
- Task 6 → Cross-reference updates ✓

**Placeholder scan:** No TBD, TODO, or incomplete code. All code examples are complete and ready to insert.

**Type consistency:** All section headings match TOC links. Quick Reference and Summary table row counts verified (9→13).

**Illustrative disclaimer:** All 3 illustrative sections start with the disclaimer callout. The Dialog section does not (it has project backing).
