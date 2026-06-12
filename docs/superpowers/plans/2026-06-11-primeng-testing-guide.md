# PrimeNG Testing Guide Scope Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the PrimeNG testing cookbook and related test-guide references so they target the current Angular 22 + PrimeNG v20+ sandbox while preserving legacy PrimeNG v17/v18 rename notes.

**Architecture:** This is a documentation-only change. Keep the cookbook structure intact and update only the framing, pre-flight, MCP, animation, and cross-link language that could mislead agents about the current target or MCP availability.

**Tech Stack:** Markdown documentation, Angular 22, PrimeNG v20+, Vitest, configured PrimeNG MCP.

---

### Task 1: Update the PrimeNG cookbook framing and pre-flight

**Files:**

- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:1-58`

- [ ] **Step 1: Rename the guide title and index entry**

Replace the title and index entry with Angular 22 + PrimeNG v20+ wording:

```markdown
# Angular 22 + PrimeNG v20+ Test Cookbook (for LLMs)

> **Testing Docs Index:**
>
> - **README-TEST-AGENT-GUIDE.md** — Main LLM-portable test creation guide
> - **README-TEST-PRIMENG-AGENT-GUIDE.md** — This file: Angular 22 + PrimeNG v20+ companion cookbook
> - **README-TEST-GUIDE.md** — Human-facing tour of realworld-angular test patterns
> - **README-TEST-INSIGHTS.md** — Quality evaluation & improvement roadmap
> - **README-TESTING.md** — Factual inventory of what exists
> - **README-TEST-CHRONOLOGY.md** — Test creation history & evolution
```

- [ ] **Step 2: Update the audience paragraph**

Replace:

```markdown
You are an LLM writing tests for an Angular + Vitest codebase that uses **PrimeNG** for UI primitives. The main test creation guide (`README-TEST-AGENT-GUIDE.md`) covers the standard patterns; this file covers the **PrimeNG-specific** setup, service stubs, and per-component patterns.
```

With:

```markdown
You are an LLM writing tests for an Angular + Vitest codebase that uses **PrimeNG** for UI primitives. The main test creation guide (`README-TEST-AGENT-GUIDE.md`) covers the standard patterns; this file covers the **PrimeNG-specific** setup, service stubs, and per-component patterns for the current sandbox target: **Angular 22 + PrimeNG v20+**. Legacy PrimeNG v17/v18 rename notes are included as compatibility context.
```

- [ ] **Step 3: Update the MCP guidance block**

Replace lines 21-27 with:

````markdown
4. **For the current API of any component**, query the configured PrimeNG MCP when its tools or resources are available before writing assertions. If the MCP is configured but not visible in the session, use the versioned PrimeNG docs or the component source as the fallback source of truth.

> **PrimeNG MCP:** before writing assertions for any component in §4-§13, query the configured PrimeNG MCP for the current `<ComponentName>` API when available. The patterns below are version-stable; the API details are not. A configured MCP does not always mean tools or resources are active in the current session. If it is not visible, use the versioned PrimeNG docs or the component source. If the MCP is not installed in the agent environment, the optional setup command is:
>
> ```bash
> claude mcp add primeng -s user -- npx -y @primeng/mcp
> ```
````

- [ ] **Step 4: Update the pre-flight section**

Replace:

```markdown
## 1. Pre-flight: Confirm PrimeNG Version

Open `package.json` and check `primeng` in `dependencies`. Confirm the major version:

- **v20+** — this guide. Signal-based components, async animations.
- **v17/v18** — same patterns, but the renamed components still use the old names. See §12.
- **v16 or earlier** — `BrowserAnimationsModule` (not async); no signal components. Stop and ask the user.

Also confirm `@angular/core` is **v20+** — PrimeNG v20 requires Angular 20+.
```

With:

```markdown
## 1. Pre-flight: Confirm Angular and PrimeNG Versions

Open `package.json` and confirm both `@angular/core` and `primeng` versions. The current sandbox target is **Angular 22 + PrimeNG v20+**, so use that path unless the user explicitly asks for legacy-version guidance.

- **Angular 22 + PrimeNG v20+** — this guide's primary target. Use signal-based components, Angular 22 guard/resolver/test conventions, and PrimeNG v20+ selectors/imports.
- **PrimeNG v17/v18** — same high-level patterns, but use the legacy component names and imports listed in §12. Treat this as compatibility context, not the current sandbox target.
- **PrimeNG v16 or earlier** — `BrowserAnimationsModule` instead of async animations; no signal components. Stop and ask the user.

If the Angular and PrimeNG major versions disagree with the expected pair, flag the mismatch before writing assertions.
```

### Task 2: Normalize animation guidance in the cookbook

**Files:**

- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:60-80`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:284-289`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:361-365`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:773-779`

- [ ] **Step 1: Update the universal setup animation paragraph**

Replace:

```markdown
Use `provideAnimationsAsync()` when the PrimeNG component or interaction path depends on animation events. Start without extra animation setup for simple components, then add `provideAnimationsAsync()` if PrimeNG throws animation-related errors or interactions fail.

Avoid `NoopAnimationsModule` when testing components that rely on animation events for transitions, open/close state, or portal behavior. It is not automatically wrong for every PrimeNG test, but it can suppress the events a component depends on.
```

With:

```markdown
Use `provideAnimationsAsync()` when the component path depends on animation events. Start without extra animation setup for simple rendering assertions, then add `provideAnimationsAsync()` if the interaction path depends on animation events or PrimeNG throws animation-related errors.

Avoid `NoopAnimationsModule` when testing transitions, open/close state, portal behavior, or any path that depends on animation events. It is not automatically wrong for every PrimeNG test, but it can suppress events a component depends on.
```

- [ ] **Step 2: Update the p-table pitfall**

Replace:

```markdown
- **Assuming `provideAnimationsAsync()` is always required** — start without it for simple rendering assertions; add it when the component path depends on animation events or interactions fail.
```

With:

```markdown
- **Assuming `provideAnimationsAsync()` is always required** — start without it for simple rendering assertions; add it only when the component path depends on animation events or interactions fail.
```

- [ ] **Step 3: Update the p-dialog pitfall**

Replace:

```markdown
- **Assuming `provideAnimationsAsync()` is always required** — start without it for simple rendering assertions; add it when the component path depends on animation events or interactions fail.
```

With:

```markdown
- **Assuming `provideAnimationsAsync()` is always required** — start without it for simple rendering assertions; add it only when the component path depends on animation events or interactions fail.
```

- [ ] **Step 4: Update common pitfalls**

Replace:

```markdown
- **Assuming `provideAnimationsAsync()` is always required** — start without it for simple rendering assertions; add it when the component path depends on animation events or interactions fail.
- **Using `NoopAnimationsModule` for every PrimeNG test** — it can be fine for static rendering, but it suppresses animation events when open/close or transition behavior matters.
```

With:

```markdown
- **Assuming `provideAnimationsAsync()` is always required** — start without it for simple rendering assertions; add it only when the component path depends on animation events or interactions fail.
- **Using `NoopAnimationsModule` for every PrimeNG test** — it can be fine for static rendering, but avoid it for transitions, open/close state, portal behavior, or any path that depends on animation events.
```

### Task 3: Update component MCP callouts to avoid overclaiming availability

**Files:**

- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:181-184`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:291-294`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:367-370`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:435-438`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:500-503`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:569-572`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:631-634`
- Modify: `README-TEST-PRIMENG-AGENT-GUIDE.md:692-695`

- [ ] **Step 1: Update p-table MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `Table` API — selector (`p-table`), events (`onPage`, `onSort`, `onFilter`), and template syntax (`<ng-template pTemplate="header">` vs the new signal-based form). The patterns below are version-stable; the API details are not.
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `Table` API — selector (`p-table`), events (`onPage`, `onSort`, `onFilter`), and template syntax (`<ng-template pTemplate="header">` vs the new signal-based form). If the MCP is not visible, use the PrimeNG v20+ docs or the component source. The patterns below are version-stable; the API details are not.
```

- [ ] **Step 2: Update p-dialog MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `Dialog` API — selector (`p-dialog`), visibility binding (`[visible]`), events (`onShow`, `onHide`), and the close mechanism (header close button, ESC key, backdrop click).
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `Dialog` API — selector (`p-dialog`), visibility binding (`[visible]`), events (`onShow`, `onHide`), and the close mechanism (header close button, ESC key, backdrop click). If the MCP is not visible, use the PrimeNG v20+ docs or the component source.
```

- [ ] **Step 3: Update p-select MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `Select` API (v20+) or `Dropdown` API (v17/v18). Confirm the selector, the `options` array shape (`{ label, value }`), the `[(ngModel)]` or signal form integration, and the `onChange` event payload.
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `Select` API (v20+) or `Dropdown` API (v17/v18). Confirm the selector, the `options` array shape (`{ label, value }`), the `[(ngModel)]` or signal form integration, and the `onChange` event payload. If the MCP is not visible, use the versioned PrimeNG docs or the component source.
```

- [ ] **Step 4: Update p-datepicker MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `DatePicker` API (v20+) or `Calendar` API (v17/v18). Confirm the selector, the date format (`dateFormat`), the inline vs popup mode, and the change event payload (`Date` object or string).
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `DatePicker` API (v20+) or `Calendar` API (v17/v18). Confirm the selector, the date format (`dateFormat`), the inline vs popup mode, and the change event payload (`Date` object or string). If the MCP is not visible, use the versioned PrimeNG docs or the component source.
```

- [ ] **Step 5: Update p-confirmpopup MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `ConfirmPopup` API — selector, the `accept`/`reject` event payload, and the `ConfirmationService` integration.
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `ConfirmPopup` API — selector, the `accept`/`reject` event payload, and the `ConfirmationService` integration. If the MCP is not visible, use the PrimeNG v20+ docs or the component source.
```

- [ ] **Step 6: Update p-toast MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `Toast` API — the `key` for matching toasts, the `MessageService.add` payload shape (`severity`, `summary`, `detail`, `key`).
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `Toast` API — the `key` for matching toasts, the `MessageService.add` payload shape (`severity`, `summary`, `detail`, `key`). If the MCP is not visible, use the PrimeNG v20+ docs or the component source.
```

- [ ] **Step 7: Update simple component MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current API of each component before writing tests. The patterns below are version-stable.
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current API of each component before writing tests. If the MCP is not visible, use the versioned PrimeNG docs or the component source. The patterns below are version-stable.
```

- [ ] **Step 8: Update p-fileupload MCP callout**

Replace:

```markdown
> **PrimeNG MCP:** query the configured PrimeNG MCP for the current `FileUpload` API — the upload mode (`auto` vs `manual`), the `onUpload` event payload, and the `choose` / `upload` / `cancel` button selectors.
```

With:

```markdown
> **PrimeNG MCP:** when available, query the configured PrimeNG MCP for the current `FileUpload` API — the upload mode (`auto` vs `manual`), the `onUpload` event payload, and the `choose` / `upload` / `cancel` button selectors. If the MCP is not visible, use the PrimeNG v20+ docs or the component source.
```

### Task 4: Update cross-links in the main LLM guide

**Files:**

- Modify: `README-TEST-AGENT-GUIDE.md:1196-1212`

- [ ] **Step 1: Update the PrimeNG companion description**

Replace:

```markdown
> **[README-TEST-PRIMENG-AGENT-GUIDE.md](README-TEST-PRIMENG-AGENT-GUIDE.md)** — universal setup, service stubs, top 8-10 components, v20 renames table, pitfalls.
```

With:

```markdown
> **[README-TEST-PRIMENG-AGENT-GUIDE.md](README-TEST-PRIMENG-AGENT-GUIDE.md)** — Angular 22 + PrimeNG v20+ universal setup, service stubs, component recipes, legacy v17/v18 renames table, pitfalls.
```

- [ ] **Step 2: Update the TL;DR PrimeNG MCP bullet**

Replace:

```markdown
- For the **current API** of any PrimeNG component, query the configured PrimeNG MCP when available. If it is not visible in the session, use the versioned PrimeNG docs or the component source. The companion file gives the testing pattern.
```

With:

```markdown
- For the **current API** of any PrimeNG component, query the configured PrimeNG MCP when available. If it is not visible in the session, use the versioned PrimeNG docs or the component source. The companion file gives the testing pattern.
```

- [ ] **Step 3: Update the quick reference row**

Replace:

```markdown
| PrimeNG component | Conditional `provideAnimationsAsync()` + service stubs + MCP preflight | Component-specific; see PrimeNG companion |
```

With:

```markdown
| PrimeNG component | Conditional `provideAnimationsAsync()` + service stubs + MCP/docs preflight | Component-specific; see Angular 22 + PrimeNG v20+ companion |
```

### Task 5: Update cross-links in the human-facing guide

**Files:**

- Modify: `README-TEST-GUIDE.md:12-13`

- [ ] **Step 1: Update the PrimeNG guide index entry**

Replace:

```markdown
- **README-TEST-PRIMENG-AGENT-GUIDE.md** — PrimeNG v20+ companion cookbook
```

With:

```markdown
- **README-TEST-PRIMENG-AGENT-GUIDE.md** — Angular 22 + PrimeNG v20+ companion cookbook
```

### Task 6: Verify documentation wording

**Files:**

- Verify: `README-TEST-PRIMENG-AGENT-GUIDE.md`
- Verify: `README-TEST-AGENT-GUIDE.md`
- Verify: `README-TEST-GUIDE.md`
- Verify: `docs/superpowers/specs/2026-06-11-primeng-testing-guide-scope.md`

- [ ] **Step 1: Search for stale PrimeNG-only title wording**

Run:

```bash
grep -n "PrimeNG v20+ Test Cookbook\|PrimeNG v20+ companion cookbook\|https://primeng.org/mcp\|query the configured PrimeNG MCP" README-TEST-PRIMENG-AGENT-GUIDE.md README-TEST-AGENT-GUIDE.md README-TEST-GUIDE.md
```

Expected: no stale title or direct URL remains; any remaining `query the configured PrimeNG MCP` occurrences should include conditional availability wording.

- [ ] **Step 2: Search for stale animation wording**

Run:

```bash
grep -n "provideAnimationsAsync().*always required\|NoopAnimationsModule.*every PrimeNG test\|always required" README-TEST-PRIMENG-AGENT-GUIDE.md README-TEST-AGENT-GUIDE.md
```

Expected: no wording implies `provideAnimationsAsync()` is mandatory for every PrimeNG test or `NoopAnimationsModule` is wrong for every PrimeNG test.

- [ ] **Step 3: Review the edited guide manually**

Open `README-TEST-PRIMENG-AGENT-GUIDE.md` and confirm:

- The title says Angular 22 + PrimeNG v20+.
- The pre-flight section confirms both Angular and PrimeNG versions.
- MCP guidance says “when available” and documents fallback when configured but not visible.
- Animation guidance is conditional.
- The current suite red caveat remains intact.

### Task 7: Commit the documentation update

**Files:**

- Commit: `README-TEST-PRIMENG-AGENT-GUIDE.md`
- Commit: `README-TEST-AGENT-GUIDE.md`
- Commit: `README-TEST-GUIDE.md`
- Commit: `docs/superpowers/specs/2026-06-11-primeng-testing-guide-scope.md`

- [ ] **Step 1: Stage only the documentation files**

Run:

```bash
git add README-TEST-PRIMENG-AGENT-GUIDE.md README-TEST-AGENT-GUIDE.md README-TEST-GUIDE.md docs/superpowers/specs/2026-06-11-primeng-testing-guide-scope.md
```

Expected: only the three guides and the approved spec are staged.

- [ ] **Step 2: Commit without AI attribution**

Run:

```bash
git commit -m "docs: scope PrimeNG testing guide to Angular 22"
```

Expected: commit succeeds and the message contains no AI attribution.
