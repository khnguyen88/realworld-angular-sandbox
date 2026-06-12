# Testing Docs Vetting Spec

**Date:** 2026-06-11
**Status:** Draft pending user review
**Owner:** TBD

## 1. Problem

The sandbox testing documentation is strong but should be tightened before it is treated as an industry-standard reference for Angular + Vitest + PrimeNG testing.

The current docs mix three concerns:

1. `README-TEST-GUIDE.md` explains Angular recommended patterns and how the realworld-angular project currently tests.
2. `README-TEST-PRIMENG-AGENT-GUIDE.md` gives PrimeNG v20+ test recipes for LLMs.
3. `README-SYSTEM-DESIGN-CHRONOLOGY.md` records the test-suite evolution and current red suite status.

The user reported that a bunch of `realworld-angular` tests are failing. The docs need to make the distinction clear: documentation quality is not the same as suite greenness. The docs should not imply the current suite is trustworthy just because it contains many specs and follows many good patterns.

## 2. Goal

Vet and update the three target README files so they provide an industry-standard testing reference while accurately describing the current failing suite.

The result should help a human or LLM write better Angular tests and understand the current project state without overstating quality.

## 3. Scope

### In scope

- Review and update only these files:
  - `README-TEST-GUIDE.md`
  - `README-TEST-PRIMENG-AGENT-GUIDE.md`
  - `README-SYSTEM-DESIGN-CHRONOLOGY.md`
- Use Angular documentation / MCP guidance to validate claims about Angular testing APIs and recommended patterns.
- Use PrimeNG MCP guidance to validate PrimeNG-specific testing claims where applicable.
- Add explicit current test-status language based on the latest available run data.
- Tighten guidance around test isolation, request handling, `TestBed` hygiene, route integration, component harnesses, accessibility assertions, and signal/effect flushing.
- Keep the work documentation-only unless the user later approves source/test fixes.

### Out of scope

- Fixing failing `realworld-angular` specs.
- Adding new test code.
- Changing `package.json`, `angular.json`, CI, or lint rules.
- Rewriting the whole testing documentation family.
- Adding coverage tooling or e2e tests.

## 4. Non-goals

- Do not claim the suite is green.
- Do not imply the docs prove production readiness.
- Do not overcorrect project patterns that are valid shallow unit-test choices.
- Do not replace every `NO_ERRORS_SCHEMA` example with `RouterTestingHarness`; the guide should explain when each is appropriate.
- Do not make PrimeNG guidance version-specific beyond what the MCP confirms.

## 5. Design Principles

### 5.1 Separate pattern quality from suite status

The docs should say:

- The pattern guidance is aligned with Angular recommendations in many areas.
- The current upstream suite is red.
- The red status is caused by concrete test isolation, request handling, fixture/provider drift, and expectation drift issues.
- A reader should use the guide to write better tests, not assume the current suite is green.

### 5.2 Prefer precise, actionable guidance

Avoid vague statements like “write industry-standard tests.” Replace them with a checklist:

- Deterministic HTTP isolation with `HttpTestingController`.
- `httpTesting.verify()` in `afterEach`.
- No leaked requests.
- Real route integration tests when routing behavior matters.
- Real child imports when integration fidelity matters.
- Component harnesses for high-value shared components.
- Accessibility assertions for roles, labels, ARIA state, and keyboard-relevant behavior.
- `TestBed.flushEffects()` for signal/effect-driven state.
- `fixture.whenStable()` after async input/state changes.
- `TestBed.resetTestingModule()` only when reconfiguring providers inside the same `describe`.
- Test user-facing behavior, not private implementation details.

### 5.3 Keep Angular and PrimeNG guidance current

Angular claims should be grounded in official docs or MCP search results. PrimeNG claims should be grounded in the PrimeNG MCP because selectors, events, and template syntax can change between versions.

### 5.4 Do not overstate PrimeNG requirements

The current PrimeNG guide says `provideAnimationsAsync()` is mandatory for every PrimeNG test. That is too broad. The revised guidance should say:

- Use `provideAnimationsAsync()` when the PrimeNG component or interaction path depends on animation events.
- Prefer testing without it first for simple components, then add it if the component throws animation-related errors or interactions fail.
- Avoid `NoopAnimationsModule` when testing components that rely on animation events.

## 6. Proposed Documentation Changes

### 6.1 `README-TEST-GUIDE.md`

Add or revise these sections:

1. **Current Testing Reality** near the top:
   - Correct command: `pnpm --dir realworld-angular run test`.
   - Current status: red.
   - Latest known result: `32/59` specs pass, `27/59` specs fail, `120` failed tests.
   - Primary failure clusters: unhandled HTTP requests, `TestBed` already instantiated, checkout fixture/provider drift, checkout guard expectation drift.
   - Explicit note: this guide documents recommended patterns and project patterns; it does not claim the suite is green.

2. **Industry-Standard Testing Checklist**:
   - HTTP isolation and verification.
   - User-facing assertions.
   - Accessibility assertions.
   - Route integration for route-sensitive behavior.
   - Real imports for integration tests.
   - Signal/effect flushing.
   - Test isolation hygiene.
   - Negative paths and empty/error states.
   - No hardcoded mocks where real child integration is the point.

3. **Clarify `NO_ERRORS_SCHEMA`**:
   - Keep it as valid for shallow leaf components.
   - Warn that it hides integration problems.
   - Recommend real child imports when the test needs child behavior.

4. **Clarify `RouterTestingHarness`**:
   - Keep `runInInjectionContext()` as valid for pure guard logic.
   - Recommend `RouterTestingHarness` when the behavior under test is navigation, redirect, guard pipeline, or resolver-to-component data flow.

5. **Clarify component harnesses**:
   - Keep querySelector examples as valid for one-off components.
   - Recommend harnesses for high-value shared components consumed by many tests.

6. **Tighten `httpResource` and stores guidance**:
   - Prefer `TestBed.flushEffects()` over `TestBed.tick()` for effect-driven resource tests.
   - Keep `HttpTestingController` as the HTTP mock.
   - Keep `httpTesting.match()` as a project innovation for multi-request scenarios.

### 6.2 `README-TEST-PRIMENG-AGENT-GUIDE.md`

Revise these areas:

1. **Universal setup**:
   - Replace “`provideAnimationsAsync()` is mandatory for PrimeNG v20+” with conditional guidance.
   - Say `NoopAnimationsModule` is wrong only when the component path depends on animation events.
   - Add “start without extra animation setup for simple components; add `provideAnimationsAsync()` if PrimeNG throws animation-related errors or interactions fail.”

2. **Theme CSS**:
   - Clarify that jsdom has no real CSS layout.
   - Theme CSS is needed when tests assert classes/styles or DOM produced by themed templates.
   - Do not rely on layout-dependent behavior in jsdom.

3. **Component selectors**:
   - Mark selectors such as `.p-paginator-next`, `.p-dialog-header-close`, and `.p-fileupload-upload` as version/theme-dependent.
   - Recommend querying rendered DOM after opening/triggering the component, then using stable attributes/roles where possible.

4. **Portal/overlay behavior**:
   - Reinforce that toasts, dialogs opened via `DialogService`, and overlays may render outside `fixture.nativeElement`.
   - Query `document.body` for portal-rendered DOM.

5. **MCP preflight**:
   - Keep the PrimeNG MCP directive.
   - Add that the MCP should be used before asserting component-specific selectors, events, or template syntax.

6. **Current suite relevance**:
   - Add a note that the realworld-angular suite is currently red, so this cookbook is a pattern guide, not proof that every PrimeNG test in the suite passes.

### 6.3 `README-SYSTEM-DESIGN-CHRONOLOGY.md`

Revise these areas:

1. **Current test-status framing**:
   - Add a short “Testing status today” section near the top.
   - State that the suite is red and summarize the current failure clusters.
   - Avoid presenting the historical test count as evidence of greenness.

2. **Test-suite timeline**:
   - Keep the historical timeline.
   - Add a note that after the 2026-06-11 run, the suite compiles and runs but exits red.
   - Preserve the distinction between historical test creation and current test health.

3. **Failure interpretation**:
   - State that current failures are mostly test isolation/request handling/provider drift, not a lack of test files.
   - Mention checkout fixture/provider drift separately because it is a concrete source mismatch.

4. **Industry-standard testing lens**:
   - Add a concise paragraph explaining what would make the suite more trustworthy:
     - green suite,
     - request isolation,
     - route integration tests,
     - harnesses for shared components,
     - coverage measurement,
     - accessibility checks.

## 7. Verification Plan

Before claiming the docs are complete:

### 7.1 Placeholder and consistency checks

Run searches for:

- `TBD`
- `TODO`
- `FIXME`
- `mandatory` in the PrimeNG guide
- `NoopAnimationsModule`
- `RouterTestingHarness`
- `NO_ERRORS_SCHEMA`
- `provideAnimationsAsync()`

Expected result:

- No placeholder markers.
- PrimeNG guidance is conditional, not absolute.
- Angular guidance distinguishes recommended integration patterns from valid shallow unit-test patterns.

### 7.2 Angular API checks

Use Angular MCP documentation search for any Angular APIs explicitly named in the updated sections:

- `HttpTestingController`
- `provideHttpClientTesting`
- `TestBed.flushEffects`
- `RouterTestingHarness`
- `DeferBlockBehavior`
- `withComponentInputBinding`
- `CanMatchFn`
- `ComponentHarness`

Fix any drift in wording, import path, or signature.

### 7.3 PrimeNG checks

Use PrimeNG MCP guidance for PrimeNG claims that remain component-specific. At minimum, confirm that the guide does not hardcode stale selectors or events as universal.

### 7.4 Test command check

Run or cite the current command:

```bash
pnpm --dir realworld-angular run test
```

If the full suite is too noisy, document the known current red status and failure clusters without claiming a fresh local run was green.

## 8. Success Criteria

The work is successful when:

- The three target docs clearly state the current suite is red.
- The docs provide an explicit industry-standard testing checklist.
- Angular recommended vs project pattern guidance is accurate and nuanced.
- PrimeNG guidance no longer overstates animation-provider requirements.
- The docs distinguish shallow unit tests from integration tests.
- The docs distinguish documentation quality from actual suite greenness.
- Placeholder scans and API checks pass.

## 9. Open Questions

None required before drafting the implementation plan.

## 10. Next Step

After user approval, invoke the writing-plans skill and create an ordered implementation plan for editing the three README files and running the verification checks.
