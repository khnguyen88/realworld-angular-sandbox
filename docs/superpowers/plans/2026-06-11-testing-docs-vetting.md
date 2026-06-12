# Testing Docs Vetting Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the three testing-related README documents so they accurately describe the current red test suite and provide clearer industry-standard Angular/Vitest/PrimeNG testing guidance.

**Architecture:** This is a documentation-only change. The plan edits `README-TEST-GUIDE.md`, `README-TEST-PRIMENG-AGENT-GUIDE.md`, and `README-SYSTEM-DESIGN-CHRONOLOGY.md` in focused passes: first add current-suite reality, then tighten Angular guidance, then tighten PrimeNG guidance, then verify with searches and API checks.

**Tech Stack:** Markdown, Angular 22, Vitest/jsdom, Angular MCP documentation search, PrimeNG MCP guidance.

---

### Task 1: Add current test-status framing to the human Angular test guide

**Files:**

- Modify: `README-TEST-GUIDE.md:1-52`
- Test: `README-TEST-GUIDE.md` Markdown consistency checks

- [ ] **Step 1: Insert current testing reality after the project-pattern note**

Add this block after the existing note ending at line 27 and before the `---` at line 29:

````markdown
## Current Testing Reality

The upstream `realworld-angular` test suite currently compiles and runs but is **red**.
Run the suite with:

```bash
pnpm --dir realworld-angular run test
```
````

Latest known result: **32/59 specs pass, 27/59 specs fail, 120 tests fail**. The dominant failure clusters are unhandled HTTP requests, `TestBed` already-instantiated errors, checkout fixture/provider drift, and checkout guard expectation drift.

This guide documents Angular-recommended patterns and the project's current test patterns. It does **not** claim the suite is green or production-ready. Use the checklist below to write better tests; treat the current suite status as a separate cleanup task.

````

- [ ] **Step 2: Add industry-standard testing checklist after the current-state block**

Insert this block after the Current Testing Reality section and before the Table of Contents:

```markdown
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
- **No stale providers:** use `TestBed.resetTestingModule()` only when reconfiguring providers inside the same `describe`.
````

- [ ] **Step 3: Update the Table of Contents**

Replace the Table of Contents block from lines 31-50 with:

```markdown
## Table of Contents

- [Current Testing Reality](#current-testing-reality)
- [Industry-Standard Testing Checklist](#industry-standard-testing-checklist)
- [Decision Flow: What Do I Test?](#decision-flow-what-do-i-test)
- [Pipes](#pipes)
- [Services](#services)
- [Interceptors](#interceptors)
- [Stores / State](#stores--state)
- [[Illustrative] Reactive Primitives](#illustrative-reactive-primitives)
- [[Illustrative] httpResource (with real API hit)](#illustrative-httpresource-with-real-api-hit)
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

- [ ] **Step 4: Tighten the `NO_ERRORS_SCHEMA` guidance**

Replace the existing `NO_ERRORS_SCHEMA Guidance` block in the Components section with:

```markdown
### NO_ERRORS_SCHEMA Guidance

- **Use when:** testing a leaf component in isolation where child components have their own tests.
- **Avoid when:** the test needs to verify parent/child integration. Use explicit `imports: [ChildA, ChildB]` instead.
- **Angular docs warn** that blanket `NO_ERRORS_SCHEMA` usage hides real template errors.
- **Project reality:** the current suite uses shallow rendering heavily, which is valid for leaf components but means page specs do not prove child integration.
```

- [ ] **Step 5: Tighten the `RouterTestingHarness` decision rule**

Replace the Decision Rule table in the Page Components section with:

```markdown
### Decision Rule

| Situation                              | Use                                                                         |
| -------------------------------------- | --------------------------------------------------------------------------- |
| Testing page in its routing context    | **RouterTestingHarness** — verifies guards, resolvers, component activation |
| Quick smoke test of page DOM structure | **provideRouter + NO_ERRORS_SCHEMA** — simpler setup, faster execution      |
| New code or shared page component      | **RouterTestingHarness** — starts with the modern approach                  |
| Testing route-sensitive behavior       | **RouterTestingHarness** — redirects, guard pipelines, resolver data flow   |
```

- [ ] **Step 6: Tighten component harness guidance**

Replace the Decision Rule table in the Components section with:

```markdown
### Decision Rule

| Situation                                             | Use                                                                      |
| ----------------------------------------------------- | ------------------------------------------------------------------------ |
| Shared component library (Button, Input, Modal)       | **Harnesses** — consumed by many tests, template changes cascade         |
| One-off page component                                | **querySelector** — harness overhead not justified for a single consumer |
| Test needs to verify a child component's internal DOM | **querySelector** or `fixture.debugElement.query(By.directive(...))`     |
| New project or new feature                            | **Harnesses** — start with the modern approach                           |
```

- [ ] **Step 7: Tighten `httpResource` guidance**

In the `[Illustrative] httpResource (with real API hit)` section, replace the paragraph that says:

```markdown
The pattern matches the project's existing `HttpTestingController` usage exactly. The
only thing that differs from a plain service test is the `injector` option, which binds
the resource to the test's `TestBed` injector so it sees the mock backend.
```

with:

```markdown
The pattern matches the project's existing `HttpTestingController` usage exactly. Use
`TestBed.flushEffects()` for effect-driven `httpResource` behavior, then assert on the
resource signals after stabilization. The `injector` option binds the resource to the
test's `TestBed` injector so it sees the mock backend.
```

- [ ] **Step 8: Update the Quick Reference Table rows for current nuance**

Replace the rows for Component, Page, Guard, Store, and Custom Form Control with:

```markdown
| Component | Component Harnesses | querySelector + NO_ERRORS_SCHEMA | Harness vs raw DOM |
| Page | RouterTestingHarness + real imports | provideRouter + NO_ERRORS_SCHEMA | Integration vs isolation |
| Guard | RouterTestingHarness | runInInjectionContext + vi.fn() | Full pipeline vs unit |
| Store | `flushEffects()` + `HttpTestingController` | `httpTesting.match()` | Mostly same |
| Custom Form Control | TestHostComponent + signal forms | — | Illustrative only |
```

- [ ] **Step 9: Run a focused Markdown check**

Run:

```bash
python - <<'PY'
from pathlib import Path
p = Path('README-TEST-GUIDE.md')
text = p.read_text(encoding='utf-8')
required = [
    'Current Testing Reality',
    'Industry-Standard Testing Checklist',
    'RouterTestingHarness',
    'NO_ERRORS_SCHEMA',
    'TestBed.flushEffects()',
]
missing = [item for item in required if item not in text]
if missing:
    raise SystemExit(f'Missing required guide text: {missing}')
if 'TBD' in text or 'TODO' in text or 'FIXME' in text:
    raise SystemExit('Placeholder marker found')
print('README-TEST-GUIDE.md checks passed')
PY
```

Expected output:

```text
README-TEST-GUIDE.md checks passed
```

- [ ] **Step 10: Commit**

Run:

```bash
git add README-TEST-GUIDE.md
git commit -m "docs: tighten Angular testing guide status and checklist"
```

Expected output: commit created for `README-TEST-GUIDE.md` only.

---

### Task 2: Tighten PrimeNG cookbook setup and selector guidance

**Files:**

- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:15-97`
- Test: `README-TEST-PRIMENG-AGENT-GUIDE.md` Markdown consistency checks

- [ ] **Step 1: Add current suite relevance near the top**

Insert this block after the MCP note at line 22 and before the Table of Contents:

```markdown
## Current Suite Relevance

The realworld-angular suite is currently red, so this cookbook is a pattern guide, not proof that every PrimeNG test in the suite passes. Use it to write clearer PrimeNG tests, then validate against the current test run and fix request isolation or fixture drift in the affected specs separately.
```

- [ ] **Step 2: Add the section to the Table of Contents**

Insert this item after the MCP note section and before `§1`:

```markdown
- [Current Suite Relevance](#current-suite-relevance)
```

- [ ] **Step 3: Replace mandatory animation setup wording**

Replace lines 52-69:

````markdown
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
````

`provideAnimationsAsync()` is **mandatory** for PrimeNG v20+. PrimeNG components subscribe to animation events; without the provider, you get cryptic `NG0201` errors or silent failures.

`NoopAnimationsModule` is the **wrong choice** — it suppresses the animation events PrimeNG components depend on for transitions and open/close state.

````

with:

```markdown
Every PrimeNG test starts from this base. Customize per-component below.

### 2.1 The provider block

```typescript
TestBed.configureTestingModule({
  providers: [
    // provideAnimationsAsync() when the component path depends on animation events
    // ... per-component providers
  ],
}).overrideComponent(<ComponentUnderTest>, {
  set: { imports: [<PrimeNGModules>, <OtherChildren>] },
});
````

Use `provideAnimationsAsync()` when the PrimeNG component or interaction path depends on animation events. Start without extra animation setup for simple components, then add `provideAnimationsAsync()` if PrimeNG throws animation-related errors or interactions fail.

Avoid `NoopAnimationsModule` when testing components that rely on animation events for transitions, open/close state, or portal behavior. It is not automatically wrong for every PrimeNG test, but it can suppress the events a component depends on.

````

- [ ] **Step 4: Clarify theme CSS in jsdom**

Replace the Theme CSS in jsdom paragraph after the CSS import with:

```markdown
jsdom has no real CSS layout engine. Theme CSS is needed when tests assert PrimeNG classes, themed DOM, or style-dependent template output. Do not rely on layout-dependent behavior such as measured size, scroll position, or visual placement in jsdom.
````

- [ ] **Step 5: Replace brittle selector guidance in p-table**

In the `p-table` section, replace the note after the server-side recipe:

```markdown
> **Note on the next-page click:** the exact selector depends on the PrimeNG theme. `.p-paginator-next` is the v17/v18/v20 default. If the project's theme overrides it, query the rendered DOM (`el.querySelectorAll('.p-paginator button')`) to find the next button.
```

with:

```markdown
> **Note on the next-page click:** paginator selectors are version/theme-dependent. Prefer stable attributes or roles when available. If the theme changes `.p-paginator-next`, query the rendered paginator after the table is open, then click the button by role/text or the closest stable wrapper.
```

- [ ] **Step 6: Replace brittle dialog selector guidance**

In the `p-dialog` Common variants section, replace:

```markdown
- **Dialog without header (no close button)** — test ESC keypress or backdrop click instead.
```

with:

```markdown
- **Dialog without header (no close button)** — test ESC keypress or backdrop click instead. Do not assume `.p-dialog-header-close` exists; query the rendered dialog after opening and choose the closest stable close trigger.
```

- [ ] **Step 7: Replace brittle fileupload selector guidance**

In the `p-fileupload` section, replace the final pitfall bullet:

```markdown
- **Wrong button selector** — `.p-fileupload-upload` is the v17+ default. The cancel button is `.p-fileupload-cancel`.
```

with:

```markdown
- **Wrong button selector** — upload/cancel selectors are version/theme-dependent. Query the rendered file upload after it is initialized and prefer stable labels/roles when available.
```

- [ ] **Step 8: Add a selector stability pitfall**

In the Common Pitfalls section, add this bullet after the `MessageService` bullet:

```markdown
- **Using brittle PrimeNG class selectors everywhere** — component classes vary by PrimeNG version and theme. Query the rendered DOM after opening/triggering the component, then prefer stable attributes, roles, labels, or the closest stable wrapper.
```

- [ ] **Step 9: Run a focused Markdown check**

Run:

```bash
python - <<'PY'
from pathlib import Path
p = Path('README-TEST-PRIMENG-AGENT-GUIDE.md')
text = p.read_text(encoding='utf-8')
required = [
    'Current Suite Relevance',
    'Use `provideAnimationsAsync()` when the PrimeNG component or interaction path depends on animation events',
    'jsdom has no real CSS layout engine',
    'version/theme-dependent',
]
missing = [item for item in required if item not in text]
if missing:
    raise SystemExit(f'Missing required PrimeNG guide text: {missing}')
if any(marker in text for marker in ['TBD', 'TODO', 'FIXME']):
    raise SystemExit('Placeholder marker found')
if '`provideAnimationsAsync()` is **mandatory**' in text:
    raise SystemExit('Mandatory animation wording still present')
print('README-TEST-PRIMENG-AGENT-GUIDE.md checks passed')
PY
```

Expected output:

```text
README-TEST-PRIMENG-AGENT-GUIDE.md checks passed
```

- [ ] **Step 10: Commit**

Run:

```bash
git add README-TEST-PRIMENG-AGENT-GUIDE.md
git commit -m "docs: tighten PrimeNG testing cookbook guidance"
```

Expected output: commit created for `README-TEST-PRIMENG-AGENT-GUIDE.md` only.

---

### Task 3: Add current testing lens to the system design chronology

**Files:**

- Modify: `README-SYSTEM-DESIGN-CHRONOLOGY.md:1-25`
- Test: `README-SYSTEM-DESIGN-CHRONOLOGY.md` Markdown consistency checks

- [ ] **Step 1: Add testing status today after the intro**

Insert this block after line 9 and before the `---` at line 11:

````markdown
## Testing Status Today

The test suite currently **compiles and runs but exits red**. The latest known run is:

```bash
pnpm --dir realworld-angular run test
```
````

Result: **32/59 specs pass, 27/59 specs fail, 120 tests fail**.

The current failures are mostly test isolation and request-handling drift: unhandled HTTP requests for option/image endpoints, `TestBed` already-instantiated errors after failed specs, checkout fixture/provider drift, and checkout guard expectation drift. This is not a lack of test files; it is a cleanup task to make the existing tests deterministic and isolated.

From an industry-standard testing lens, the next trust builders are: green suite, deterministic HTTP isolation, route integration tests where routing behavior matters, component harnesses for high-value shared components, coverage measurement, and accessibility checks.

````

- [ ] **Step 2: Add a status note to the Overall Timeline**

Insert this row at the top of the Overall Timeline table, before the May 14 row:

```markdown
| Jun 11    | Status     | 0       | **Current suite health snapshot.** Documentation now records that the suite compiles and runs but is red: 32/59 specs pass, 27 fail, 120 tests fail. Failures are mostly request isolation, `TestBed` hygiene, checkout fixture/provider drift, and guard expectation drift. |
````

- [ ] **Step 3: Update the test-suite timeline wording**

Replace the Test Suite row in the Cross-Cutting Timelines table at lines 524-532 with:

```markdown
| Phase      | Spec Files | Net Change | Key Event                                                                                                                                                                                                                                                                                             |
| ---------- | ---------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **P1**     | 10         | +10        | Initial auto-generated specs (auth.guard, checkout-deactivate, role.guard, credentials.interceptor, auth, photon-api, pizzeria-api, cart.store, app)                                                                                                                                                  |
| **P2**     | 0          | −10        | All 10 specs deleted (`cdbf77a`)                                                                                                                                                                                                                                                                      |
| **P3**     | 54         | +54        | Complete test suite written (`70dae9c`) — 45 new + 9 re-created                                                                                                                                                                                                                                       |
| **P4**     | 54         | 0          | ~40 specs refactored for quality                                                                                                                                                                                                                                                                      |
| **P5**     | 60         | +6         | New specs for checkout wizard components, checkout-step guard, checkout-wizard, load-more. (Also: checkout-deactivate spec permanently removed, net +4 to 58, plus app.spec never re-created = 57... but the suite is at 60 because some features had specs that never went through the delete cycle) |
| **Jun 11** | 59         | 0          | Current health snapshot: suite compiles and runs but exits red. Cleanup should focus on request isolation, `TestBed` hygiene, checkout fixture/provider drift, and guard expectation drift before adding more tests.                                                                                  |
```

- [ ] **Step 4: Add a final current-status note before the final summary**

Insert this block before `## 12. Unified Project Timeline (All Features)`:

```markdown
## 11.1 Current Testing Health

The historical timeline shows strong test creation discipline: the project added specs across services, stores, guards, pages, components, directives, and pipes. That history does not mean the suite is green today.

The 2026-06-11 health snapshot is red: **32/59 specs pass, 27 fail, 120 tests fail**. The most important interpretation is that the project has many tests, but many of them are not yet deterministic in the current upstream state. The next quality step is not simply adding more tests; it is fixing isolation, request handling, fixture/provider drift, and route expectation drift so the existing suite can become trustworthy.
```

- [ ] **Step 5: Run a focused Markdown check**

Run:

```bash
python - <<'PY'
from pathlib import Path
p = Path('README-SYSTEM-DESIGN-CHRONOLOGY.md')
text = p.read_text(encoding='utf-8')
required = [
    'Testing Status Today',
    '32/59 specs pass, 27/59 specs fail, 120 tests fail',
    'Current Testing Health',
    'request isolation',
    'TestBed',
]
missing = [item for item in required if item not in text]
if missing:
    raise SystemExit(f'Missing required chronology text: {missing}')
if any(marker in text for marker in ['TBD', 'TODO', 'FIXME']):
    raise SystemExit('Placeholder marker found')
print('README-SYSTEM-DESIGN-CHRONOLOGY.md checks passed')
PY
```

Expected output:

```text
README-SYSTEM-DESIGN-CHRONOLOGY.md checks passed
```

- [ ] **Step 6: Commit**

Run:

```bash
git add README-SYSTEM-DESIGN-CHRONOLOGY.md
git commit -m "docs: record current test-suite health in chronology"
```

Expected output: commit created for `README-SYSTEM-DESIGN-CHRONOLOGY.md` only.

---

### Task 4: Validate Angular and PrimeNG documentation claims

**Files:**

- Modify as needed:
  - `README-TEST-GUIDE.md`
  - `README-TEST-PRIMENG-AGENT-GUIDE.md`
  - `README-SYSTEM-DESIGN-CHRONOLOGY.md`
- Test: MCP documentation checks and Markdown scans

- [ ] **Step 1: Check Angular testing APIs**

Use the Angular MCP `search_documentation` tool for these exact queries against the workspace Angular version:

```text
HttpTestingController
provideHttpClientTesting
TestBed.flushEffects
RouterTestingHarness
DeferBlockBehavior
withComponentInputBinding
CanMatchFn
ComponentHarness
```

Expected result: the docs use the correct API names and do not claim unsupported signatures.

- [ ] **Step 2: Fix Angular wording if any API check reveals drift**

If an API check shows drift, edit only the affected sentence. Do not rewrite sections. Use `Edit` with the exact old sentence and a corrected sentence.

- [ ] **Step 3: Check PrimeNG guidance**

Use the PrimeNG MCP guidance for component-specific claims around:

```text
Table paginator
Dialog close behavior
Select/Dropdown
DatePicker/Calendar
ConfirmPopup
Toast portal behavior
FileUpload buttons
```

Expected result: the cookbook does not hardcode stale selectors or events as universal.

- [ ] **Step 4: Fix PrimeNG wording if any component check reveals drift**

If a PrimeNG check shows a selector/event is stale, replace absolute wording with version/theme-dependent wording and MCP preflight language.

- [ ] **Step 5: Run aggregate placeholder and wording scans**

Run:

```bash
python - <<'PY'
from pathlib import Path
files = [
    Path('README-TEST-GUIDE.md'),
    Path('README-TEST-PRIMENG-AGENT-GUIDE.md'),
    Path('README-SYSTEM-DESIGN-CHRONOLOGY.md'),
]
for p in files:
    text = p.read_text(encoding='utf-8')
    for marker in ['TBD', 'TODO', 'FIXME']:
        if marker in text:
            raise SystemExit(f'{marker} found in {p}')
    if 'does not claim the suite is green' not in text and p.name == 'README-TEST-GUIDE.md':
        raise SystemExit(f'Missing suite greenness disclaimer in {p}')
    if 'Current Suite Relevance' not in text and p.name == 'README-TEST-PRIMENG-AGENT-GUIDE.md':
        raise SystemExit(f'Missing current suite relevance in {p}')
    if 'Testing Status Today' not in text and p.name == 'README-SYSTEM-DESIGN-CHRONOLOGY.md':
        raise SystemExit(f'Missing current testing status in {p}')
print('Aggregate docs checks passed')
PY
```

Expected output:

```text
Aggregate docs checks passed
```

- [ ] **Step 6: Commit any verification fixes**

If Step 2 or Step 4 required edits, run:

```bash
git add README-TEST-GUIDE.md README-TEST-PRIMENG-AGENT-GUIDE.md README-SYSTEM-DESIGN-CHRONOLOGY.md
git commit -m "docs: fix testing guidance drift found during verification"
```

Expected output if fixes existed: commit created with documentation fixes. If no fixes existed, skip this step and say no verification-fix commit was needed.

---

### Task 5: Final verification and handoff

**Files:**

- Verify:
  - `README-TEST-GUIDE.md`
  - `README-TEST-PRIMENG-AGENT-GUIDE.md`
  - `README-SYSTEM-DESIGN-CHRONOLOGY.md`

- [ ] **Step 1: Run final scan for required status language**

Run:

```bash
python - <<'PY'
from pathlib import Path
checks = {
    'README-TEST-GUIDE.md': [
        'Current Testing Reality',
        'Industry-Standard Testing Checklist',
        '32/59 specs pass, 27/59 specs fail, 120 tests fail',
        'does not claim the suite is green',
    ],
    'README-TEST-PRIMENG-AGENT-GUIDE.md': [
        'Current Suite Relevance',
        'Use `provideAnimationsAsync()` when the PrimeNG component or interaction path depends on animation events',
        'jsdom has no real CSS layout engine',
        'version/theme-dependent',
    ],
    'README-SYSTEM-DESIGN-CHRONOLOGY.md': [
        'Testing Status Today',
        'Current Testing Health',
        '32/59 specs pass, 27/59 specs fail, 120 tests fail',
        'request isolation',
    ],
}
for filename, required in checks.items():
    text = Path(filename).read_text(encoding='utf-8')
    missing = [item for item in required if item not in text]
    if missing:
        raise SystemExit(f'{filename} missing: {missing}')
print('Final required-status scan passed')
PY
```

Expected output:

```text
Final required-status scan passed
```

- [ ] **Step 2: Run final placeholder scan**

Run:

```bash
python - <<'PY'
from pathlib import Path
for p in [
    Path('README-TEST-GUIDE.md'),
    Path('README-TEST-PRIMENG-AGENT-GUIDE.md'),
    Path('README-SYSTEM-DESIGN-CHRONOLOGY.md'),
]:
    text = p.read_text(encoding='utf-8')
    if any(marker in text for marker in ['TBD', 'TODO', 'FIXME']):
        raise SystemExit(f'Placeholder marker found in {p}')
print('Final placeholder scan passed')
PY
```

Expected output:

```text
Final placeholder scan passed
```

- [ ] **Step 3: Review git diff**

Run:

```bash
git diff -- README-TEST-GUIDE.md README-TEST-PRIMENG-AGENT-GUIDE.md README-SYSTEM-DESIGN-CHRONOLOGY.md
```

Expected result: only the three target documentation files changed, with no source/test changes.

- [ ] **Step 4: Report completion**

Report:

- files changed,
- commits created,
- verification commands passed,
- whether the full test suite was run,
- that the work did not fix the failing tests unless the user separately approves that follow-up.
