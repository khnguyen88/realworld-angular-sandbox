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

## 5. p-dialog

## 6. p-select / p-dropdown

## 7. p-datepicker / p-calendar

## 8. p-confirmpopup

## 9. p-toast

## 10. p-inputtext, p-button, p-checkbox

## 11. p-fileupload

## 12. Renames from v17/v18

## 13. Common Pitfalls
