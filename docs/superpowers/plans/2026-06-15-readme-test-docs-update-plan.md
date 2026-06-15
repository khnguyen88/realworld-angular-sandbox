:# README Test Documentation Update — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the six README test documentation files in `C:\_AAA\JVR\realworld-angular-sandbox` so they accurately describe the current realworld-angular test suite (59/59 specs pass, 350/350 tests) and reflect current Angular 22 + Vitest best practices and PrimeNG v20+ testing patterns.

**Architecture:** The work is read-only documentation maintenance. Each README is updated by a dedicated subagent that reads the current spec files, compares against existing doc content, and rewrites sections that are factually wrong or contain stale code examples. No production code or test code changes.

**Tech Stack:** Markdown, Angular 22, Vitest 4, jsdom, `@angular/build:unit-test`, `@angular/common/http/testing`, PrimeNG v20+.

---

## File Structure

The plan modifies these six existing Markdown files in `C:\_AAA\JVR\realworld-angular-sandbox`:

| File                                 | Responsibility                                            | Update Strategy                                                                                                                           |
| ------------------------------------ | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `README-TEST-INSIGHTS.md`            | Quality evaluation & improvement roadmap                  | Purely factual refresh from current run and spec inventory.                                                                               |
| `README-TESTING.md`                  | Factual inventory of the test suite                       | Purely factual refresh: counts, run results, inventory tables, code snippets from real specs.                                             |
| `README-TEST-CHRONOLOGY.md`          | Test creation history & evolution                         | Add new phase for the latest green run; correct totals.                                                                                   |
| `README-TEST-GUIDE.md`               | Human-facing tour of Angular + realworld-angular patterns | Refresh real-world examples; keep `[Illustrative]` sections backed by Angular docs/skills.                                                |
| `README-TEST-AGENT-GUIDE.md`         | LLM-portable recipe book for Angular + Vitest             | Update recipes to current Angular 22 + Vitest conventions; use real-world-angular examples only when aligned with official best practice. |
| `README-TEST-PRIMENG-AGENT-GUIDE.md` | PrimeNG v20+ testing cookbook                             | Update to current PrimeNG v20+ patterns; verify via PrimeNG MCP and Angular skills.                                                       |

---

## Pre-Flight: Gather Current State

**Task 0: Confirm current test suite output and spec inventory**

- [ ] **Step 1: Run the test suite and capture output**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox\realworld-angular"
  pnpm run test
  ```

  Expected output contains:

  ```
  Test Files  59 passed (59)
       Tests  350 passed (350)
  ```

- [ ] **Step 2: Record current repo HEAD for chronology**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git rev-parse HEAD
  ```

  Expected output: `f1593bffe76e89c906afcaf7a9a2f1c45fdcebef` (or later).

- [ ] **Step 3: Count spec files by category**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox\realworld-angular"
  Get-ChildItem -Recurse -Filter *.spec.ts | Measure-Object
  ```

  Expected count: 59.

---

## Task 1: Update README-TESTING.md (Factual Inventory)

**Files:**

- Modify: `C:\_AAA\JVR\realworld-angular-sandbox\README-TESTING.md`
- Read: `C:\_AAA\JVR\realworld-angular-sandbox\realworld-angular\src\**\*.spec.ts`

- [ ] **Step 1: Update the header and latest-run section**

  Change:

  ```markdown
  - **README-TESTING.md** — This file: factual inventory of what exists (59 specs, categories, patterns; latest run 58/59 specs pass)
  ```

  To:

  ```markdown
  - **README-TESTING.md** — This file: factual inventory of what exists (59 specs, categories, patterns; latest run 59/59 specs pass)
  ```

- [ ] **Step 2: Rewrite the latest fresh sync test run block**

  Replace the existing "Latest Fresh Sync Test Run" section (lines ~73-99) with:

  ````markdown
  ### Latest Fresh Sync Test Run

  After syncing the upstream clone to GitHub HEAD `f1593bffe76e89c906afcaf7a9a2f1c45fdcebef`, the fresh full test run was:

  ```bash
  pnpm run test
  ```
  ````

  Result: **exit=0**.

  | Scope      | Result                    |
  | ---------- | ------------------------- |
  | Spec files | **59 passed**, 59 total   |
  | Tests      | **350 passed**, 350 total |
  | Duration   | ~14.5s                    |

  The inventory below describes the existing test suite structure. The suite is fully green.

  ```

  ```

- [ ] **Step 3: Remove the failing-spec table and failure-mode notes**

  Delete the table that lists `photon-location-field.spec.ts` and the "Common failure modes" paragraph. The suite no longer has failing tests.

- [ ] **Step 4: Refresh inventory counts and tables**

  Verify each category still maps to the current file list. The expected category counts after re-audit are:

  | Category                | Count | Files                                                                                                                                                                                                                                                                                                                                                                                     |
  | ----------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | Service tests           | 5     | `auth.spec.ts`, `order-api.spec.ts`, `pizzeria-api.spec.ts`, `pizza-api.spec.ts`, `checkout-wizard.spec.ts`                                                                                                                                                                                                                                                                               |
  | Store tests             | 1     | `cart.store.spec.ts`                                                                                                                                                                                                                                                                                                                                                                      |
  | Interceptor tests       | 2     | `credentials.interceptor.spec.ts`, `base-url.interceptor.spec.ts`                                                                                                                                                                                                                                                                                                                         |
  | Guard tests             | 5     | `auth.guard.spec.ts` (covers `authGuard` and `guestGuard`), `role.guard.spec.ts`, `cart-not-empty.guard.spec.ts`, `checkout-step.guard.spec.ts`, `no-pizzeria.guard.spec.ts`                                                                                                                                                                                                              |
  | Shared component tests  | 16    | `button`, `input`, `textarea`, `modal`, `spinner`, `callout`, `confirm-dialog`, `empty-state`, `hero-banner`, `image-picker`, `load-more`, `pagination`, `photon-location-field`, `pizza-logo`, `avatar`, `status-badge`                                                                                                                                                                  |
  | Feature page tests      | 17    | `login-page`, `register-page`, `cart-page`, `checkout-page`, `order-list-page`, `order-details-page`, `admin-order-list-page`, `pizzeria-list-page`, `pizzeria-details-page`, `admin-pizza-list-page`, `admin-pizzeria-configuration-page`, `admin-pizzeria-details-page`, `admin-pizzeria-form-page`, `profile-page`, `not-found-page`, `unauthorized-page`, `terms-and-conditions-page` |
  | Feature component tests | 9     | `checkout-delivery-step`, `checkout-progress-stepper`, `checkout-review-step`, `checkout-schedule-step`, `pizza-order-form-dialog`, `pizza-size-option-field`, `admin-pizza-form-dialog`, `admin-pizza-row`, `admin-order-row`                                                                                                                                                            |
  | Layout component tests  | 2     | `footer.spec.ts`, `header.spec.ts`                                                                                                                                                                                                                                                                                                                                                        |
  | Directive tests         | 1     | `role.directive.spec.ts`                                                                                                                                                                                                                                                                                                                                                                  |
  | Pipe tests              | 1     | `catalog-image-url.pipe.spec.ts`                                                                                                                                                                                                                                                                                                                                                          |

  If the real inventory differs, update the table to match.

- [ ] **Step 5: Replace stale code snippets with current spec excerpts**

  Read the following representative spec files and update the matching example blocks in `README-TESTING.md`:
  - `src/app/core/services/auth.spec.ts` → Services example
  - `src/app/features/cart/cart.store.spec.ts` → Stores example
  - `src/app/core/interceptors/credentials.interceptor.spec.ts` → Interceptors example
  - `src/app/core/guards/auth/auth.guard.spec.ts` → Guards example
  - `src/app/shared/components/button/button.spec.ts` → Components example
  - `src/app/features/auth/pages/login-page/login-page.spec.ts` → Page component example
  - `src/app/shared/components/confirm-dialog/confirm-dialog.spec.ts` → Dialogs example
  - `src/app/shared/directives/role.directive.spec.ts` → Directives example
  - `src/app/shared/pipes/catalog-image-url.pipe.spec.ts` → Pipes example

  For each, copy the actual imports, mock shapes, and key assertions. Do not invent code.

- [ ] **Step 6: Update coverage gap analysis if needed**

  The suite status is now fully green. Keep the coverage gap table but update the Route integration row:

  | Gap                       | Status         | Notes                                                                                                                                                        |
  | ------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | **E2E tests**             | Missing        | No Cypress, Playwright, or Selenium setup. Full user flows (browse → add to cart → checkout → track order) are not tested end-to-end.                        |
  | **Integration tests**     | Missing        | All HTTP calls are mocked with `HttpTestingController`. No tests hit the real API at `api.realworldangular.org`.                                             |
  | **Visual regression**     | Missing        | No screenshot comparison tools (Percy, Chromatic, etc.).                                                                                                     |
  | **Performance tests**     | Missing        | No Lighthouse CI, bundle size budgets for tests, or benchmark tests.                                                                                         |
  | **Accessibility tests**   | Missing        | No `axe-core`, `pa11y`, or Angular CDK a11y test helpers.                                                                                                    |
  | **Route integration**     | Partial        | Guide documents `RouterTestingHarness` pattern in `README-TEST-GUIDE.md`. Guards tested with `runInInjectionContext()` cover logic but not full integration. |
  | **Component harnesses**   | Missing        | No harness usage in 59 component specs. Guide documents the recommended pattern. See `README-TEST-INSIGHTS.md` for prioritization.                           |
  | **Test coverage reports** | Not configured | No coverage thresholds or reporting scripts defined.                                                                                                         |

  Update the component-harness row count from "34+ component specs" to "59 component specs" if that is the only change.

- [ ] **Step 7: Commit the updated README-TESTING.md**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git add README-TESTING.md
  git commit -m "docs: refresh factual test inventory for green 59/59 suite"
  ```

---

## Task 2: Update README-TEST-INSIGHTS.md (Quality Evaluation)

**Files:**

- Modify: `C:\_AAA\JVR\realworld-angular-sandbox\README-TEST-INSIGHTS.md`
- Read: output from `pnpm run test`, `pnpm exec ng lint`

- [ ] **Step 1: Update the status snapshot and TL;DR**

  Replace the 2026-06-15 status snapshot with:

  ```markdown
  > **Status snapshot (2026-06-15):** Upstream realworld-angular was synced to GitHub HEAD `f1593bffe76e89c906afcaf7a9a2f1c45fdcebef`. The suite compiles and passes completely. The latest local run is fully green: **59/59 specs pass, 350/350 tests pass**. No remaining failures.
  ```

  Update the TL;DR table:

  | Question                                   | Answer                                                                                            |
  | ------------------------------------------ | ------------------------------------------------------------------------------------------------- |
  | How many test files?                       | **59 `*.spec.ts`** co-located with source.                                                        |
  | How much test code?                        | **~5,175 lines** of test code vs. **~3,820 lines** of source.                                     |
  | Is the suite green?                        | **Yes** — `pnpm run test` exits 0: **59/59 specs pass, 350/350 tests pass**.                      |
  | Angular Skill/MCP Cross-Check              | **7/10 categories aligned** with official recommendations. 3 categories have gaps.                |
  | How does it perform on the unit-test axis? | **Strong** in pattern discipline and breadth, with known gaps in harnesses and route integration. |
  | Is coverage measured?                      | **No** — no `vitest.config.ts`, no `@vitest/coverage-v8`, no thresholds.                          |
  | Are there other test types?                | **None** — no e2e, integration, a11y, or visual regression tests.                                 |

- [ ] **Step 2: Rewrite Section 2 — Current Run Status**

  Replace the "ALMOST GREEN" section with:

  ```markdown
  ## 2. Current Run Status — GREEN

  `pnpm run test` (i.e. `ng test`) compiles, runs, and exits 0. Results from the latest local run:

  | Metric     | Value                   |
  | ---------- | ----------------------- |
  | Spec files | **59**                  |
  | Passed     | **59 specs, 350 tests** |
  | Failed     | **0 specs, 0 tests**    |
  | Duration   | ~14.5s                  |

  The earlier Photon request isolation failure and broad `TestBed` cascade failures have been resolved upstream. The suite is fully green.
  ```

  Delete the failing-spec table and root-cause analysis.

- [ ] **Step 3: Update Section 3 alignment scores**

  If the spec inventory changed, update the alignment table counts. Keep the 7/10 score unless the MCP/skill cross-check reveals a new gap. Document any new findings from `search_documentation` or `angular-developer` skill references.

- [ ] **Step 4: Update Section 5 weaknesses**

  Remove or reframe the "blocking" subsection because there are no blocking failures. Move the remaining structural items into Tier 2/Tier 3 of Section 6.

- [ ] **Step 5: Refresh roadmap tiers**

  Tier 1 is now empty (no failures). Re-label it:

  ```markdown
  ### Tier 1 — Maintain green suite

  1. Keep `pnpm run test` passing on every upstream sync.
  ```

  Keep Tier 2 and Tier 3 as-is unless the MCP cross-check suggests reordering.

- [ ] **Step 6: Update data sources in appendix**

  Update the test-run data source to the current HEAD and fully-green result. Update the `find`/`wc -l` numbers if they changed.

- [ ] **Step 7: Commit the updated README-TEST-INSIGHTS.md**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git add README-TEST-INSIGHTS.md
  git commit -m "docs: update quality insights for fully green suite"
  ```

---

## Task 3: Update README-TEST-CHRONOLOGY.md (History)

**Files:**

- Modify: `C:\_AAA\JVR\realworld-angular-sandbox\README-TEST-CHRONOLOGY.md`

- [ ] **Step 1: Correct the totals**

  Update the Quick Reference table:

  | Phase  | Date          | Time (Local) | Commit                                   | Action                                                       | Specs    |
  | ------ | ------------- | ------------ | ---------------------------------------- | ------------------------------------------------------------ | -------- |
  | **1**  | 2026-05-14    | 23:12 CEST   | `a1eb73e` — init                         | Created 9 skeleton specs                                     | +9       |
  | **2**  | 2026-05-18    | 00:57 CEST   | `43a4c77` — base URL interceptor         | Added 1 interceptor spec amid implementation work            | +1       |
  | **3a** | 2026-05-19    | 01:52 CEST   | `cdbf77a` — remove obsolete specs        | **Deleted all 10** Phase 1+2 specs                           | −10      |
  | **3b** | 2026-05-19    | 12:14 CEST   | `70dae9c` — add unit tests               | **Replaced with 54** comprehensive specs                     | +54      |
  | **4**  | 2026-05-23    | 00:19 CEST   | `bd72c32` — pizzeria details enhancement | Added `load-more.spec.ts` alongside new component            | +1       |
  | **5**  | 2026-05-26    | 12:41 CEST   | `b7f434b` — checkout flow enhancement    | Added 6 checkout specs, deleted `checkout-deactivate` guard  | +6 −1    |
  | **6**  | 2026-05-27+   | —            | `7d23826`, `3322c2d` — coupon features   | Refactored/extended existing specs for coupon code           | 0 net    |
  | **7**  | 2026-05-19→27 | —            | 8 refactor commits                       | Enhanced existing specs (linting, type safety, mock cleanup) | 0 net    |
  | **8**  | 2026-06-11    | 10:27 Local  | `420001d` — upstream sync to GitHub HEAD | Ran full test suite after sync; documented failures          | 59 specs |
  | **9**  | 2026-06-15    | Local        | `f1593bf` — green suite baseline         | Upstream resolved remaining failures; suite now 59/59 green  | 59 specs |

  Update the text below the table:

  ```markdown
  **Historical final count:** 59 spec files with 350 individual `it()` test blocks.
  **Current observed count:** 59 spec files with 350 individual `it()` test blocks, as reported by the 2026-06-15 test run.
  ```

- [ ] **Step 2: Add Phase 9 section**

  Add after the existing Phase 8:

  ```markdown
  ## Phase 9: Upstream Green Baseline — 2026-06-15 Local

  **Commit context:** `f1593bf` — current sandbox HEAD after upstream sync  
  **Command:** `pnpm run test`  
  **Result:** passed with exit code `0`; the suite is fully green.  
  **Observed totals:** 0 failed spec files, 59 passed spec files; 0 failed tests, 350 passed tests.

  The upstream project resolved the remaining `PhotonLocationField` request isolation failure. No local documentation changes affected the suite.

  ### Evaluation

  This phase records the post-sync health of the upstream clone after the final failure was resolved. The current state is: the synced app builds its application bundle and starts the Vitest run, and every test passes. This is the baseline for future documentation updates.
  ```

- [ ] **Step 3: Update the feature cross-reference totals**

  Ensure the "Total Specs" column still sums to 59 and matches the categories in `README-TESTING.md`.

- [ ] **Step 4: Commit the updated README-TEST-CHRONOLOGY.md**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git add README-TEST-CHRONOLOGY.md
  git commit -m "docs: add Phase 9 green baseline and correct test totals"
  ```

---

## Task 4: Update README-TEST-GUIDE.md (Human-Facing Guide)

**Files:**

- Modify: `C:\_AAA\JVR\realworld-angular-sandbox\README-TEST-GUIDE.md`
- Read: current spec files for real-world examples
- Reference: Angular 22 docs via MCP `search_documentation` and `angular-developer` skill references

- [ ] **Step 1: Update the Current Testing Reality section**

  Replace the stale paragraph with:

  ````markdown
  ## Current Testing Reality

  The upstream `realworld-angular` test suite currently compiles and runs and is **fully green**.
  Run the suite with:

  ```bash
  pnpm run test
  ```
  ````

  Latest local result: **59/59 specs pass, 350/350 tests pass**. The earlier `PhotonLocationField` failure has been resolved upstream.

  This guide documents Angular-recommended patterns and the project's current test patterns. It does **not** claim the suite is production-ready beyond unit tests. Use the checklist below to write better tests; treat any future failures as a separate cleanup task.

  ```

  ```

- [ ] **Step 2: Refresh real-world code examples**

  For each section below, read the current real spec file and replace the representative excerpt in the guide:
  - **Pipes** — `src/app/shared/pipes/catalog-image-url.pipe.spec.ts`
  - **Services** — `src/app/core/services/auth.spec.ts`
  - **Interceptors** — `src/app/core/interceptors/credentials.interceptor.spec.ts`
  - **Stores / State** — `src/app/features/cart/cart.store.spec.ts`
  - **Components** — `src/app/shared/components/button/button.spec.ts`
  - **Dialogs & Overlays** — `src/app/shared/components/confirm-dialog/confirm-dialog.spec.ts`
  - **Page Components** — `src/app/features/pizzerias/pages/pizzeria-list-page/pizzeria-list-page.spec.ts`
  - **Guards** — `src/app/core/guards/auth/auth.guard.spec.ts`
  - **Directives** — `src/app/shared/directives/role.directive.spec.ts`
  - **Forms & Wizard Services** — `src/app/features/checkout/services/checkout-wizard.spec.ts`

  Keep the **Angular Recommended** and **Project Pattern** structure. Update the Project Pattern code to match the current real spec. Update the Angular Recommended code only if the MCP/skill reference has changed since the last doc version.

- [ ] **Step 3: Verify [Illustrative] sections against Angular 22 docs**

  For each existing `[Illustrative]` section, use the Angular MCP to confirm the recommended API is still current:
  - Reactive Primitives (`linkedSignal`, `effect`, `afterRenderEffect`)
  - `httpResource`
  - `@defer` blocks
  - Data Resolvers
  - Custom Form Controls (ControlValueAccessor)
  - Signal Outputs
  - Host Element Bindings

  If the official API or testing guidance has changed, update the illustrative code. Keep the `[Illustrative]` marker.

- [ ] **Step 4: Update the Quick Reference Table**

  Ensure the table at the end reflects the current real-world-angular patterns and any updated Angular recommendations. Verify each row against the refreshed sections.

- [ ] **Step 5: Commit the updated README-TEST-GUIDE.md**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git add README-TEST-GUIDE.md
  git commit -m "docs: refresh Angular testing guide with current specs and best practices"
  ```

---

## Task 5: Update README-TEST-AGENT-GUIDE.md (LLM Recipe Book)

**Files:**

- Modify: `C:\_AAA\JVR\realworld-angular-sandbox\README-TEST-AGENT-GUIDE.md`
- Reference: Angular 22 docs/skills; real-world-angular specs only for alignment checks

- [ ] **Step 1: Pre-flight checks**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox\realworld-angular"
  pnpm exec ng version
  ```

  Confirm Angular 22.x and Vitest 4.x. Note the exact versions for the pre-flight section.

- [ ] **Step 2: Verify each recipe against current Angular 22 + Vitest conventions**

  For each section in §3, use `search_documentation` or `angular-developer` skill references to confirm the recommended pattern:
  - §3.1 Pipes
  - §3.2 Services
  - §3.3 Interceptors
  - §3.4 Components
  - §3.5 Dialogs & Overlays
  - §3.6 Stores / State
  - §3.7 Guards
  - §3.8 Resolvers
  - §3.9 Directives
  - §3.10 Forms
  - §3.11 Signal Primitives
  - §3.12 @defer Blocks
  - §3.13 Page Components

  Update code examples only where the official recommendation has changed. Keep placeholders in `<placeholder>` form so the guide stays project-agnostic.

- [ ] **Step 3: Cross-check real-world alignment claims**

  Where the guide states "realworld-angular uses this pattern," verify against the current spec files. Remove or rephrase any claim that is no longer true.

- [ ] **Step 4: Update §5 PrimeNG reference**

  Ensure the PrimeNG companion file reference is current. No deep PrimeNG detail here; that belongs in `README-TEST-PRIMENG-AGENT-GUIDE.md`.

- [ ] **Step 5: Commit the updated README-TEST-AGENT-GUIDE.md**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git add README-TEST-AGENT-GUIDE.md
  git commit -m "docs: refresh LLM test recipe book for Angular 22 + Vitest"
  ```

---

## Task 6: Update README-TEST-PRIMENG-AGENT-GUIDE.md (PrimeNG Cookbook)

**Files:**

- Modify: `C:\_AAA\JVR\realworld-angular-sandbox\README-TEST-PRIMENG-AGENT-GUIDE.md`
- Reference: PrimeNG v20+ docs via PrimeNG MCP; Angular 22 testing conventions via Angular MCP/skills

- [ ] **Step 1: Verify PrimeNG version and component APIs**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox\realworld-angular"
  cat package.json | grep '"primeng"'
  ```

  Note the installed PrimeNG version. If the PrimeNG MCP is available, query it for the current APIs of: `Table`, `Dialog`, `Select`, `DatePicker`, `ConfirmPopup`, `Toast`, `FileUpload`.

- [ ] **Step 2: Update universal setup advice**

  Confirm `provideAnimationsAsync()` is still the correct animation provider for PrimeNG v20+ with Angular 22. Update §2.1 if the recommendation changed.

- [ ] **Step 3: Update service stubs**

  Verify the stub shapes for `MessageService`, `ConfirmationService`, `DialogService`, and `DynamicDialogRef` still match PrimeNG v20+ service signatures. Update code examples and assertions.

- [ ] **Step 4: Refresh per-component recipes**

  For each recipe in §4-§11, check the current PrimeNG component API and selector names. Update imports from module imports to standalone component imports where PrimeNG v20+ supports them. Keep class selectors (`.p-table`, `.p-dialog`, etc.) as fallbacks but emphasize stable attributes/roles in the prose.

- [ ] **Step 5: Verify the v17/v18 rename table**

  Confirm the rename table in §12 is still accurate. Add any new renames introduced in v20+ if applicable.

- [ ] **Step 6: Commit the updated README-TEST-PRIMENG-AGENT-GUIDE.md**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git add README-TEST-PRIMENG-AGENT-GUIDE.md
  git commit -m "docs: refresh PrimeNG v20+ testing cookbook for Angular 22"
  ```

---

## Task 7: Final Verification

- [ ] **Step 1: Re-run the test suite**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox\realworld-angular"
  pnpm run test
  ```

  Expected: 59/59 specs pass, 350/350 tests pass.

- [ ] **Step 2: Verify no documentation references removed files**

  Search the README files for `photon-api.spec.ts` or any other deleted spec name:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  grep -R "photon-api.spec.ts" README*.md || true
  ```

  Expected: no matches.

- [ ] **Step 3: Review git diff**

  Run:

  ```bash
  cd "C:\_AAA\JVR\realworld-angular-sandbox"
  git diff --stat
  ```

  Expected: changes only to the six README files and the plan/spec files under `docs/superpowers/`.

- [ ] **Step 4: Final commit if needed**

  If any fixes were needed after verification, commit them with an appropriate message.

---

## Spec Coverage Self-Check

| Spec Requirement                                        | Task          |
| ------------------------------------------------------- | ------------- |
| Update factual docs with current green run              | Tasks 1-3     |
| Refresh real-world examples from current specs          | Tasks 1, 4    |
| Verify Angular 22 + Vitest best-practice guidance       | Tasks 4, 5    |
| Verify PrimeNG v20+ testing patterns                    | Task 6        |
| Use Angular MCP/skills and PrimeNG MCP as sources       | Tasks 4, 5, 6 |
| Preserve [Illustrative] marker for non-project examples | Task 4        |
| Final verification that docs do not break suite         | Task 7        |

No placeholders remain in the plan steps. Every code or command block is concrete.

---

## Execution Choice

Plan complete and saved to `docs/superpowers/plans/2026-06-15-readme-test-docs-update-plan.md`.

Two execution options:

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per file, review between tasks, fast iteration.
2. **Inline Execution** — execute tasks in this session using `superpowers:executing-plans`, batch execution with checkpoints.

Which approach do you want?
