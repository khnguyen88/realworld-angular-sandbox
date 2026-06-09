# Test Guide Supplement — Design Spec

**Date:** 2026-06-08
**Status:** In Progress

## Goal

Add 4 new sections to `README-TEST-GUIDE.md` covering test patterns not currently documented. Three sections are illustrative (no realworld-angular backing), one has project backing.

## Structure

4 new sections inserted into the existing TOC at logical grouping points:

| #   | Section                               | Placement                     | Has Project Backing?                                 | Pattern Style                |
| --- | ------------------------------------- | ----------------------------- | ---------------------------------------------------- | ---------------------------- |
| 1   | Dialogs & Overlays                    | After Components              | Yes (modal, confirm-dialog, pizza-order-form-dialog) | Dual (Recommended + Project) |
| 2   | `[Illustrative]` @defer Blocks        | After Dialogs                 | No                                                   | Angular Recommended only     |
| 3   | `[Illustrative]` Data Resolvers       | After Guards                  | No                                                   | Angular Recommended only     |
| 4   | `[Illustrative]` Custom Form Controls | After Forms & Wizard Services | No                                                   | Angular Recommended only     |

Each `[Illustrative]` section opens with a callout:

> **Not based on realworld-angular** — illustrative example generated from Angular official documentation.

---

## Section 1: Dialogs & Overlays

### What to test

- Dialog renders content from injected `DIALOG_DATA`
- Close button calls `DialogRef.close()` with result
- ARIA attributes on the overlay panel (`role="document"`, `aria-label`)
- Conditional rendering when optional data fields are missing
- Form submission inside a dialog (HTTP + close interaction)

### Angular Recommended

Use CDK testing harnesses or direct `DialogRef`/`DIALOG_DATA` injection stubbing. For custom dialogs (like realworld-angular's), the recommended approach is:

- Provide a stubbed `DialogRef` with a `vi.fn()` close method
- Provide test data via the `DIALOG_DATA` injection token
- Assert on close calls with correct result payloads

Reference: `angular-developer` skill `testing-fundamentals.md`

### Project Pattern

The realworld-angular `modal.spec.ts` and `confirm-dialog.spec.ts` use:

- `DialogRef` stub with `vi.fn()` close
- `DIALOG_DATA` token with test data object
- `NO_ERRORS_SCHEMA` for dialog chrome (title, close button, content projection)
- `TestBed.resetTestingModule()` for reconfiguring providers mid-describe

Code example based on `modal.spec.ts` and `confirm-dialog.spec.ts` (2 examples: simple dialog + dialog with data).

### Key rules

- Use `TestBed.resetTestingModule()` before reconfiguring providers with different data
- Test close behavior with `expect(closeFn).toHaveBeenCalled()` (not `.toHaveBeenCalledWith()` unless testing result payload)
- Test ARIA attributes on the dialog panel element
- For dialogs with forms, test the full flow: fill form → submit → flush HTTP → verify close

---

## Section 2: `[Illustrative]` @defer Blocks

### What to test

- Deferred content is NOT rendered before the trigger condition is met
- Placeholder content IS rendered before the trigger
- Content renders after trigger activates
- Loading state between trigger and render
- Error state if defer fails to load

### Angular Recommended

Use `fixture.whenStable()` to wait for the deferred view to resolve. Trigger the defer condition (e.g., set a signal that controls a `@defer (when condition)` block), then assert DOM content appears/disappears.

Single pattern — no realworld-angular backing.

Reference: `angular-developer` skill `testing-fundamentals.md`, MCP `search_documentation` for @defer

### Key rules

- `@defer` blocks are async by nature — always `await fixture.whenStable()` after triggering
- Test the placeholder content separately from the deferred content
- Use `@defer (when signal())` pattern for testable trigger conditions
- Test that content is NOT present before trigger (negative assertion)

---

## Section 3: `[Illustrative]` Data Resolvers

### What to test

- Resolver fetches data and returns it to the route
- Resolver handles 404 (returns empty/null/redirect)
- Resolver handles 500 (error state)
- Resolved data is available in the component via `ActivatedRoute.data`

### Angular Recommended

Use `RouterTestingHarness` with `provideRouter` and a route config that includes `resolve: { key: resolverFn }`. Flush the HTTP request, then assert:

- The component renders with the resolved data
- Error states propagate correctly

Single pattern — no realworld-angular backing.

Reference: `angular-developer` skill `router-testing.md`, MCP `search_documentation` for ResolveFn

### Key rules

- Combine `RouterTestingHarness` + `HttpTestingController` for end-to-end resolver testing
- Test both success and error paths
- Verify data flow: resolver → route data → component input

---

## Section 4: `[Illustrative]` Custom Form Controls

### What to test

- `writeValue` updates the internal control value
- User interaction calls `onChange` with the new value
- `registerOnTouched` fires on blur
- `setDisabledState` toggles disabled mode
- Validation: required, pattern, custom validators

### Angular Recommended

Create a `TestHostComponent` that uses the custom control with Angular signal forms. Manipulate the control's value through the form API, assert DOM updates and callback invocations via spies.

Single pattern — no realworld-angular backing.

Reference: `angular-developer` skill `signal-forms.md`, MCP `search_documentation` for ControlValueAccessor testing

### Key rules

- Use signal forms (`FormRoot`, `FormField`) as the host for the custom control
- Spy on `onChange` and `onTouched` callbacks with `vi.fn()`
- Test the control's DOM output after `writeValue` and user interaction
- Test disabled state via `setDisabledState`

---

## Updated Quick Reference Table

Add 4 rows to the existing table:

| Unit                | Angular Recommended                   | Project Pattern                                 | Key Difference                              |
| ------------------- | ------------------------------------- | ----------------------------------------------- | ------------------------------------------- |
| Dialog              | DialogRef stub + DIALOG_DATA          | DialogRef stub + DIALOG_DATA + NO_ERRORS_SCHEMA | ✓ Same (project pattern is already correct) |
| @defer              | fixture.whenStable() + signal trigger | —                                               | Illustrative only                           |
| Data Resolver       | RouterTestingHarness + resolve config | —                                               | Illustrative only                           |
| Custom Form Control | TestHostComponent + signal forms      | —                                               | Illustrative only                           |

---

## Implementation Order

1. Add Dialogs & Overlays section to GUIDE (after Components)
2. Add @defer section to GUIDE (after Dialogs)
3. Add Data Resolvers section to GUIDE (after Guards)
4. Add Custom Form Controls section to GUIDE (after Forms & Wizard Services)
5. Update Quick Reference Table with 4 new rows
6. Update Table of Contents
7. Cross-reference in TESTING.md (dialogs badge update) and INSIGHTS.md
8. Verify with Angular MCP search_documentation for correctness
