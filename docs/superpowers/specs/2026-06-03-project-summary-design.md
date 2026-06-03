# Project Summary Documentation — Design

**Date:** 2026-06-03
**Status:** Approved
**Owner:** Khiem Hoang Nguyen

## Goal

Produce a single `README-PROJECT-SUMMARY.md` that gives a developer a high-level map of the Angular 21 application — its features, components, services, styles, and how they relate — plus a per-file breakdown with import/dependency lists for the entire `src/app/` tree.

## Scope

In scope:

- One README file at the project root: `README-PROJECT-SUMMARY.md`.
- One standalone Mermaid source file at `docs/diagrams/project-architecture.mmd` (referenced from the README).
- Coverage of every `.ts`, `.html`, and `.css` file under `src/app/`.
- Top-level description of `src/styles/`, `src/environments/`, and external dependencies from `package.json`.

Out of scope:

- Modifying any source file.
- Generating diagrams for individual features beyond the per-feature mini-diagrams inside their own README section.
- Running the build, tests, or linter.
- Updating `README.md` (the existing one) or `README-TESTING.md`.

## Observed architecture

- **Stack:** Angular 21.2, standalone components, signal-based state, RxJS 7.8, Vitest for unit tests, ESLint + Prettier, pnpm.
- **Bootstrap:** `src/main.ts` → `appConfig` (providers) → `app.ts` (root component) → router uses `app.routes.ts`.
- **App config (`src/app/app.config.ts`):** provides router (with `withComponentInputBinding`, `withExperimentalAutoCleanupInjectors`, scroll restoration), HTTP client (with `withFetch` and two interceptors), and an `appInitializer` that calls `Auth.init()`.
- **Routing:** All feature routes are lazy-loaded. Top-level redirect goes to `/pizzerias` (or `/pizzerias/admin` for admins). Global guards: `authGuard` (for checkout/orders/profile), `guestGuard` (for `/auth`), `cartNotEmptyGuard` (for checkout).
- **Source layers under `src/app/`:**
  - `core/` — singletons: `auth` service, `photon-api` service, two HTTP interceptors (`base-url`, `credentials`), two guards (`auth/role`), two models (`pagination`, `user`).
  - `shared/` — presentational components (avatar, button, callout, modal, pagination, input, textarea, status-badge, spinner, empty-state, hero-banner, image-picker, pizza-logo, load-more, photon-location-field, confirm-dialog), one directive (`role.directive`), one pipe (`catalog-image-url.pipe`), and `address.model.ts`.
  - `features/` — seven lazy bundles (`auth`, `cart`, `checkout`, `orders`, `pizzerias`, `profile`) plus `legal`, `not-found`, `unauthorized`. Each owns its own routes, pages, components, services, guards, models.
- **Styles:** `src/styles.css` is the global stylesheet registered in `angular.json`. It is not currently referenced from any component via `styleUrl`. The `src/styles/` directory contains a small set of design-system files: `design-system/_reset.css` and `design-system/_tokens.css` (resets and design tokens), and `components/input.css` (component-scoped stylesheet). These are not yet wired into `angular.json` and exist as design-stage artifacts.

## Approach

Use **parallel subagents, one per feature folder**, to break down the source tree. The main session assembles the final README from their reports.

### Subagent dispatch plan

Eight subagents run in parallel, each given a slice of `src/app/`:

1. **core** — services, guards, interceptors, models under `src/app/core/`.
2. **shared** — components, directive, pipe, model under `src/app/shared/`.
3. **auth** — `src/app/features/auth/`.
4. **cart** — `src/app/features/cart/`.
5. **checkout** — `src/app/features/checkout/`.
6. **orders** — `src/app/features/orders/`.
7. **pizzerias** — `src/app/features/pizzerias/`.
8. **profile + legal + not-found + unauthorized + app root** — `src/app/features/profile/`, `src/app/features/legal/`, `src/app/features/not-found/`, `src/app/features/unauthorized/`, and the top-level `src/app/app.{ts,config.ts,routes.ts,html,css}`.

Each subagent returns a structured report with the following shape per file:

```
- path: src/app/...
  role: <one-sentence purpose>
  type: component | service | guard | interceptor | model | directive | pipe | page | route-config | spec | other
  imports: [<list of import specifiers>]
  exports: [<list of exported symbols>]
  consumers: [<files/classes/strings that reference this file's exports>]
  notes: <optional, e.g. uses signals, uses OnPush, references a specific environment var>
```

Subagents do not write any files — they return their report as a single message.

### Main session assembly

The main session:

1. Writes `docs/diagrams/project-architecture.mmd` (the canonical Mermaid source).
2. Writes `README-PROJECT-SUMMARY.md` containing:
   - Overview and stack summary.
   - The architecture diagram (embedded Mermaid block + link to the `.mmd` file).
   - Routing map (path → feature → guard).
   - One section per feature: purpose, components, services, guards, models, cross-feature dependencies, mini-diagram.
   - Shared & core catalog.
   - Styles section.
   - Per-file appendix (full detail, derived from the subagent reports).
   - External dependencies table (from `package.json`).

## Deliverables

- `README-PROJECT-SUMMARY.md` at the project root.
- `docs/diagrams/project-architecture.mmd`.
- This design spec committed alongside the work it describes.

## Verification

- Mermaid syntax is valid: balanced parentheses, valid node IDs, no reserved-keyword collisions.
- The README's per-file appendix is internally consistent with the prose sections.
- Spot-check 3–5 dependency claims with `grep` against the actual source.
- No source files under `src/` are modified.

## Risks and mitigations

- **Risk:** Subagents report duplicate or inconsistent information (e.g. one subagent lists `address.model` in shared, another in core).
  - **Mitigation:** The main session reconciles reports during assembly. Boundaries are explicit in each subagent's scope.
- **Risk:** Subagent context fills up on a large feature (pizzerias has ~25 files).
  - **Mitigation:** If a subagent returns truncated output, split that feature across two dispatches.
- **Risk:** Diagram becomes unreadable.
  - **Mitigation:** Keep the top-level diagram to one graph with subgraphs per layer. Per-feature diagrams are tiny (≤8 nodes).
