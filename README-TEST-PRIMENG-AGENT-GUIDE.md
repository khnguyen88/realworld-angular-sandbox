# PrimeNG v20+ Test Cookbook (for LLMs)

> **Testing Docs Index:**
>
> - **README-TEST-AGENT-GUIDE.md** — Main LLM-portable test creation guide
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — This file: PrimeNG v20+ companion cookbook
> - **README-TEST-GUIDE.md** — Human-facing tour of realworld-angular test patterns
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution

## Who This File Is For

You are an LLM writing tests for an Angular + Vitest codebase that uses **PrimeNG** for UI primitives. The main test creation guide (`README-TEST-AGENT-GUIDE.md`) covers the standard patterns; this file covers the **PrimeNG-specific** setup, service stubs, and per-component patterns.

## How to Use This File

1. **Confirm the PrimeNG version** (see §1).
2. **Apply the universal setup** (§2) in every test that uses PrimeNG components.
3. **For each PrimeNG component in the code**, find the matching recipe in §4-§13.
4. **For the current API of any component**, query `https://primeng.org/mcp` before writing assertions. The MCP returns the current selector, events, and template syntax.

> **primeng.org MCP:** before writing assertions for any component in §4-§13, query `https://primeng.org/mcp` for the current `<ComponentName>` API. The patterns below are version-stable; the API details are not.

## Table of Contents

- [§1. Pre-flight: Confirm PrimeNG Version](#1-pre-flight-confirm-primeng-version)
- [§2. Universal Test Setup](#2-universal-test-setup)
- [§3. Service Stubs](#3-service-stubs)
- [§4. p-table](#4-p-table)
- [§5. p-dialog](#5-p-dialog)
- [§6. p-select / p-dropdown](#6-p-select--p-dropdown)
- [§7. p-datepicker / p-calendar](#7-p-datepicker--p-calendar)
- [§8. p-confirmpopup](#8-p-confirmpopup)
- [§9. p-toast](#9-p-toast)
- [§10. p-inputtext, p-button, p-checkbox](#10-p-inputtext-p-button-p-checkbox)
- [§11. p-fileupload](#11-p-fileupload)
- [§12. Renames from v17/v18](#12-renames-from-v17v18)
- [§13. Common Pitfalls](#13-common-pitfalls)

## 1. Pre-flight: Confirm PrimeNG Version

Open `package.json` and check `primeng` in `dependencies`. Confirm the major version:

- **v20+** — this guide. Signal-based components, async animations.
- **v17/v18** — same patterns, but the renamed components still use the old names. See §12.
- **v16 or earlier** — `BrowserAnimationsModule` (not async); no signal components. Stop and ask the user.

Also confirm `@angular/core` is **v20+** — PrimeNG v20 requires Angular 20+.

## 2. Universal Test Setup

Every PrimeNG test starts from this base. Customize per-component below.

### 2.1 The provider block

```typescript
TestBed.configureTestingModule({
  providers: [
    provideAnimationsAsync(),
    // ... per-component providers
  ],
}).overrideComponent(<ComponentUnderTest>, {
  set: { imports: [<PrimeNGModules>, <OtherChildren>] },
});
```

`provideAnimationsAsync()` is **mandatory** for PrimeNG v20+. PrimeNG components subscribe to animation events; without the provider, you get cryptic `NG0201` errors or silent failures.

`NoopAnimationsModule` is the **wrong choice** — it suppresses the animation events PrimeNG components depend on for transitions and open/close state.

### 2.2 Theme CSS in jsdom

PrimeNG components render with theme-dependent CSS classes. In `angular.json`, the test target's `options.styles` should include the theme:

```json
"test": {
  "builder": "@angular/build:unit-test",
  "options": {
    "styles": ["src/styles.css"]
  }
}
```

If `src/styles.css` doesn't import a PrimeNG theme, add one:

```css
@import 'primeng/resources/themes/lara-light-blue/theme.css';
```

(Check the project's actual theme import path; `lara-light-blue` is a common default but not universal.)

### 2.3 What you can skip

- `BrowserAnimationsModule` — replaced by `provideAnimationsAsync()`.
- `NoopAnimationsModule` — see §2.1.
- `FormsModule` / `ReactiveFormsModule` — only if the component under test uses ngModel or form controls. PrimeNG's own components handle their internal state.

## 3. Service Stubs

PrimeNG components inject a few shared services. Stub them at the providers level.

### 3.1 `MessageService`

Used by `p-toast`, `p-confirmpopup`, and any component that emits transient messages.

```typescript
{ provide: MessageService, useValue: { add: vi.fn() } }
```

Assert on the stub:

```typescript
const messageService = TestBed.inject(MessageService);
expect(messageService.add).toHaveBeenCalledWith({
  severity: 'success',
  summary: 'Saved',
  detail: '...',
});
```

### 3.2 `ConfirmationService`

Used by `p-confirmpopup` and any component that triggers a confirmation dialog.

```typescript
{ provide: ConfirmationService, useValue: { confirm: vi.fn() } }
```

Assert on the stub, including the accept/reject callbacks:

```typescript
const confirmationService = TestBed.inject(ConfirmationService);
expect(confirmationService.confirm).toHaveBeenCalled();
const call = confirmationService.confirm.mock.calls[0][0];
call.accept(); // trigger the accept path
expect(<accept-side-effect>).toBe(<expected>);
```

### 3.3 `DialogService`

Used by any component that programmatically opens a dialog.

```typescript
const ref = { close: vi.fn(), onClose: of(<result>) };
{ provide: DialogService, useValue: { open: vi.fn().mockReturnValue(ref) } }
```

Assert that `open` was called with the right config:

```typescript
const dialogService = TestBed.inject(DialogService);
expect(dialogService.open).toHaveBeenCalledWith(<Component>, expect.objectContaining({ header: '...' }));
```

### 3.4 `DynamicDialogRef`

Used inside a PrimeNG dialog opened via `DialogService`. The parent component stubs `DialogService`; the dialog itself injects `DynamicDialogRef`.

```typescript
{ provide: DynamicDialogRef, useValue: { close: vi.fn() } }
```

If the dialog awaits `ref.onClose`, stub the observable:

```typescript
{ provide: DynamicDialogRef, useValue: { close: vi.fn(), onClose: of(<result>) } }
```

## 4. p-table

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Table` API — selector (`p-table`), events (`onPage`, `onSort`, `onFilter`), and template syntax (`<ng-template pTemplate="header">` vs the new signal-based form). The patterns below are version-stable; the API details are not.

### 4.1 What to test

- Rows render correctly (column values from data)
- Pagination: clicking next/prev triggers the lazy load event with the correct page index
- Sorting: clicking a column header triggers the sort event
- Filtering: typing in a filter input triggers the filter event
- Empty state: a table with zero rows renders the empty message
- Loading state: a `p-table` with `[loading]="true"` shows the spinner

### 4.2 Pre-flight

- Identify the data source: is it `[value]` bound to an array, or `[lazy]="true"` with `(onLazyLoad)`?
- List the columns and their data fields.
- Identify the pagination config: `[paginator]="true"`, `[rows]`, `[first]`.
- Note the event handlers: `(onPage)`, `(onSort)`, `(onFilter)`, `(onLazyLoad)`.

### 4.3 Recipe template (client-side table)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { TableModule } from 'primeng/table';
import { describe, it, expect, beforeEach } from 'vitest';
import { <TableHostComponent> } from '<relative-path>';

const <mockRows> = [<row-shape>];

describe('<TableHostComponent>', () => {
  let fixture: ComponentFixture<<TableHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<TableHostComponent>, {
      set: { imports: [TableModule] },
    });
    fixture = TestBed.createComponent(<TableHostComponent>);
    fixture.componentRef.setInput('rows', <mockRows>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <expected-cell-text> for each row', () => {
    expect(el.textContent).toContain(<expected-text>);
  });

  it('should show <empty-message> when rows are empty', async () => {
    fixture.componentRef.setInput('rows', []);
    await fixture.whenStable();
    expect(el.textContent).toContain('<empty-message>');
  });
});
```

### 4.4 Recipe template (server-side / lazy table)

```typescript
beforeEach(async () => {
  TestBed.configureTestingModule({
    providers: [provideAnimationsAsync(), provideHttpClientTesting()],
  }).overrideComponent(<TableHostComponent>, {
    set: { imports: [TableModule] },
  });
  fixture = TestBed.createComponent(<TableHostComponent>);
  el = fixture.nativeElement;
  httpTesting = TestBed.inject(HttpTestingController);
  await fixture.whenStable();
});

it('should request the first page on init', () => {
  const req = httpTesting.expectOne((r) => r.url.includes('<data-url>'));
  expect(req.request.params.get('page')).toBe('1');
  req.flush(<paged-response>);
});

it('should request page 2 when paginator advances', async () => {
  httpTesting.expectOne((r) => r.url.includes('<data-url>')).flush(<paged-response-page-1>);
  await fixture.whenStable();

  // Find the paginator next button and click it
  const nextButton = el.querySelector<HTMLButtonElement>('.p-paginator-next')!;
  nextButton.click();
  await fixture.whenStable();

  const req2 = httpTesting.expectOne((r) => r.url.includes('<data-url>'));
  expect(req2.request.params.get('page')).toBe('2');
  req2.flush(<paged-response-page-2>);
});
```

> **Note on the next-page click:** the exact selector depends on the PrimeNG theme. `.p-paginator-next` is the v17/v18/v20 default. If the project's theme overrides it, query the rendered DOM (`el.querySelectorAll('.p-paginator button')`) to find the next button.

### 4.5 Common variants

- **Sortable column** — click the header `<th>` and assert the sort event fired with the right field and direction.
- **Filterable column** — set the filter value on the component instance, dispatch the input event, assert the filter event fired.
- **Selection** — click a row checkbox, assert the selection signal updated.

### 4.6 Pitfalls

- **Forgetting `provideAnimationsAsync()`** — `p-table` paginator and sort UI use animations; without the provider, the test runs but interactions silently fail.
- **Asserting on `p-table` before the table initializes** — `p-table` lazy-loads on the first change detection cycle. Always `await fixture.whenStable()` before querying rows.
- **Selecting the wrong paginator button** — themes vary. Use `el.querySelector('.p-paginator-next')` as a starting point; fall back to other selectors if it's null.
- **Server-side table: asserting only on the first request** — pagination tests must flush the first request, advance the page, then flush the second.

## 5. p-dialog

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Dialog` API — selector (`p-dialog`), visibility binding (`[visible]`), events (`onShow`, `onHide`), and the close mechanism (header close button, ESC key, backdrop click).

### 5.1 What to test

- Dialog opens when `[visible]` becomes `true`
- Dialog closes when the user clicks the close button or backdrop
- Dialog content renders correctly when open
- Dialog opened via `DialogService.open()` returns the right `DynamicDialogRef`

### 5.2 Pre-flight

- Identify the visibility trigger: signal-based (`[visible]="signal()"`) or input-based.
- Note the close handler: `(visibleChange)` callback, internal state, or `DialogService` ref.
- Identify what content the dialog renders (slot, template, child component).

### 5.3 Recipe template (declarative dialog)

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { DialogModule } from 'primeng/dialog';
import { ButtonModule } from 'primeng/button';
import { describe, it, expect, beforeEach } from 'vitest';
import { <DialogHostComponent> } from '<relative-path>';

describe('<DialogHostComponent>', () => {
  let fixture: ComponentFixture<<DialogHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<DialogHostComponent>, {
      set: { imports: [DialogModule, ButtonModule] },
    });
    fixture = TestBed.createComponent(<DialogHostComponent>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should NOT render dialog content when closed', () => {
    expect(el.querySelector('.p-dialog')).toBeNull();
  });

  it('should render dialog content when opened', async () => {
    fixture.componentRef.setInput('visible', true);
    await fixture.whenStable();
    expect(el.querySelector('.p-dialog')).not.toBeNull();
    expect(el.textContent).toContain('<expected-content>');
  });

  it('should close when close button is clicked', async () => {
    fixture.componentRef.setInput('visible', true);
    await fixture.whenStable();
    const closeButton = el.querySelector<HTMLButtonElement>('.p-dialog-header-close')!;
    closeButton.click();
    await fixture.whenStable();
    expect(fixture.componentInstance.visible()).toBe(false);
  });
});
```

### 5.4 Common variants

- **Dialog opened via `DialogService.open()`** — the parent component test stubs `DialogService` with `{ open: vi.fn().mockReturnValue(<ref>) }`. Assert on the stub's `open` call args and the ref's `close` method.
- **Dialog with form** — combine the dialog recipe with §3.10 Forms from the main guide.
- **Dialog without header (no close button)** — test ESC keypress or backdrop click instead.

### 5.5 Pitfalls

- **Querying `.p-dialog` before the dialog is open** — PrimeNG only inserts the dialog DOM when `visible` is true. Use `setInput('visible', true)` first, then `whenStable()`, then query.
- **Missing `provideAnimationsAsync()`** — the dialog open/close transitions don't run; assertions on transition state fail.
- **Clicking the close button that doesn't exist** — if the dialog has no header (`[showHeader]="false"`), there's no `.p-dialog-header-close`. Use ESC keypress or backdrop click instead.

## 6. p-select / p-dropdown

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `Select` API (v20+) or `Dropdown` API (v17/v18). Confirm the selector, the `options` array shape (`{ label, value }`), the `[(ngModel)]` or signal form integration, and the `onChange` event payload.

### 6.1 What to test

- Renders the placeholder when no value is selected
- Renders the selected value's label when a value is bound
- Opens the panel when clicked
- Selecting an option fires the change event with the right value

### 6.2 Pre-flight

- Identify the data input: signal-based `options()` or `@Input() options`.
- Note the change handler: `(onChange)` callback, signal form integration, or two-way `[(ngModel)]`.
- Identify the value type: simple (`string`), object (`{ id, label }`), or nested.

### 6.3 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { SelectModule } from 'primeng/select';
import { describe, it, expect, beforeEach } from 'vitest';
import { <SelectHostComponent> } from '<relative-path>';

const <mockOptions> = [{ label: 'A', value: 'a' }, { label: 'B', value: 'b' }];

describe('<SelectHostComponent>', () => {
  let fixture: ComponentFixture<<SelectHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<SelectHostComponent>, {
      set: { imports: [SelectModule] },
    });
    fixture = TestBed.createComponent(<SelectHostComponent>);
    fixture.componentRef.setInput('options', <mockOptions>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <placeholder> when no value is selected', () => {
    expect(el.textContent).toContain('<placeholder>');
  });

  it('should render <selected-label> when a value is bound', async () => {
    fixture.componentRef.setInput('value', 'a');
    await fixture.whenStable();
    expect(el.textContent).toContain('A');
  });
});
```

### 6.4 Common variants

- **Select inside a form (signal forms)** — the value binding is `<p-select [formField]="'myField'" />`. Use the form's API to set the value and assert.
- **Select with object values** — the value is the full object, not a primitive. The test passes the object, the select compares by reference (or by a custom comparator).
- **Multi-select (`p-multiselect`)** — separate component; similar pattern but value is an array.

### 6.5 Pitfalls

- **Forgetting to import `SelectModule`** — the component renders as a blank `<p-select>` element. The override must include the module.
- **Asserting on the option list before the panel is open** — PrimeNG renders options only when the panel is open. To assert on options, click to open first.
- **Wrong value type** — if `value` is an object, the test must pass the same object reference, not a copy.

## 7. p-datepicker / p-calendar

> **primeng.org MCP:** query `https://primeng.org/mcp` for the current `DatePicker` API (v20+) or `Calendar` API (v17/v18). Confirm the selector, the date format (`dateFormat`), the inline vs popup mode, and the change event payload (`Date` object or string).

### 7.1 What to test

- Renders the input with the bound date formatted correctly
- Opens the calendar panel when the input is clicked
- Selecting a date updates the value
- Clearing the date (X button) sets the value to null

### 7.2 Pre-flight

- Identify the input format (`dateFormat="yy-mm-dd"` etc.).
- Note the value type: `Date` object, ISO string, or timestamp.
- Identify any min/max date constraints.

### 7.3 Recipe template

```typescript
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { DatePickerModule } from 'primeng/datepicker';
import { describe, it, expect, beforeEach } from 'vitest';
import { <DatePickerHostComponent> } from '<relative-path>';

describe('<DatePickerHostComponent>', () => {
  let fixture: ComponentFixture<<DatePickerHostComponent>>;
  let el: HTMLElement;

  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [provideAnimationsAsync()],
    }).overrideComponent(<DatePickerHostComponent>, {
      set: { imports: [DatePickerModule] },
    });
    fixture = TestBed.createComponent(<DatePickerHostComponent>);
    el = fixture.nativeElement;
    await fixture.whenStable();
  });

  it('should render <input-class> input element', () => {
    expect(el.querySelector('.<input-class>')).not.toBeNull();
  });

  it('should set the input value to the formatted date', async () => {
    fixture.componentRef.setInput('value', new Date('2026-06-10'));
    await fixture.whenStable();
    const input = el.querySelector<HTMLInputElement>('.<input-class>')!;
    expect(input.value).toContain('2026');
  });
});
```

### 7.4 Common variants

- **Inline datepicker** — the calendar is always visible; no open/close.
- **Range selection** — `[selectionMode]="range"`; value is a tuple `[Date, Date]`.
- **Time picker** — `[showTime]="true"`; value includes hours/minutes.

### 7.5 Pitfalls

- **Timezone issues** — `new Date('2026-06-10')` is parsed as UTC midnight; the formatted output depends on the local timezone. If the test fails on the date string, use `new Date(2026, 5, 10)` (local time).
- **Asserting on the calendar panel before it's open** — like `p-dialog`, the panel only renders when open.

## 8. p-confirmpopup

## 9. p-toast

## 10. p-inputtext, p-button, p-checkbox

## 11. p-fileupload

## 12. Renames from v17/v18

## 13. Common Pitfalls
