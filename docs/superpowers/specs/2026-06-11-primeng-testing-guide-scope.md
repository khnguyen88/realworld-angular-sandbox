# PrimeNG Testing Guide Scope Spec

## Goal

Update `README-TEST-PRIMENG-AGENT-GUIDE.md` so it clearly targets the sandbox's current testing context: **Angular 22 + PrimeNG v20+**, while preserving older PrimeNG v17/v18 rename notes as compatibility context.

## Scope

The guide should remain a focused cookbook for LLM agents writing tests against Angular + Vitest components that use PrimeNG UI primitives. It should not become a general PrimeNG testing guide or attempt to fix the upstream test suite.

## Required Changes

1. Rename the guide from **PrimeNG v20+ Test Cookbook** to an Angular 22 + PrimeNG v20+ scoped title.
2. Update the audience/intro language to say the current sandbox target is Angular 22 + PrimeNG v20+, with legacy v17/v18 notes where relevant.
3. Update pre-flight guidance so agents confirm both `@angular/core` and `primeng` versions, treating Angular 22 + PrimeNG v20+ as the primary path.
4. Soften PrimeNG MCP guidance:
   - Query the configured PrimeNG MCP when available.
   - If MCP resources/tools are not visible in the session, fall back to the versioned component docs or the current component source.
   - Do not imply the MCP is always active merely because it is configured.
5. Keep animation guidance conditional:
   - `provideAnimationsAsync()` is required only when the component path depends on animation events.
   - Start without extra animation setup for simple rendering tests.
   - `NoopAnimationsModule` is discouraged only for tests that depend on animation events, transitions, open/close state, or portal behavior.
6. Preserve the current-suite caveat:
   - The upstream suite may be red.
   - The cookbook is a pattern guide, not proof every PrimeNG test passes.
7. Update cross-links and TL;DR references so `README-TEST-AGENT-GUIDE.md` and `README-TEST-GUIDE.md` point to the same current-target wording.

## Out of Scope

- Rewriting component recipes from scratch.
- Fixing upstream test failures.
- Adding new PrimeNG component recipes beyond the existing cookbook.
- Changing test implementation code.

## Acceptance Criteria

- A reader can immediately tell the guide targets Angular 22 + PrimeNG v20+ for this sandbox.
- Legacy PrimeNG v17/v18 rename guidance remains available but clearly secondary.
- MCP guidance is accurate for the current session behavior: configured does not always mean visible/usable.
- Animation guidance is not overbroad.
- Current suite relevance caveat remains intact.
