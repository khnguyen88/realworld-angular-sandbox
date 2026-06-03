# Sync local fork with `realworld-angular/realworld-angular` upstream — Design

**Date:** 2026-06-03
**Status:** Approved
**Owner:** Khiem Hoang Nguyen

## Goal

Make the local fork (`khnguyen88/realworld-angular-sandbox`) contain the current `realworld-angular/realworld-angular` upstream code, dependencies, and structure, _with_ the 9 sandbox-only commits (CLAUDE.md, memory-compiler, MCP server, agent skills, test READMEs) reapplied on top via cherry-pick. End state: a PR-ready feature branch that, when merged into `main`, leaves `main` ahead of upstream by exactly those 9 commits.

## Context

- The local fork's `2464e99` is **not** a true clone of `realworld-angular/realworld-angular` — it is a fresh root commit that _snapshotted_ the upstream tree at clone time. The two repos share **zero commits**. (Verified: `git merge-base 2464e99 upstream/main` exits 1 with no common ancestor.) The local `2464e99` tree contains 337 files; the current upstream tip contains 336. Of those, 336 are common — the local snapshot is essentially a copy of the current upstream state with one extra file (`.claude/settings.local.json` from the sandbox).
- The 9 sandbox-only commits on `main` (oldest to newest: `01a3113`, `c69605d`, `0b8e7db`, `99878b2`, `29655c0`, `fe6637f`, `ff20f46`, `87541d1`, `82dcc52`, `b5925c6`) are valid commits, but they cannot be **rebased** onto upstream because there is no common ancestor. Instead, they must be **cherry-picked** onto the upstream tip.
- Upstream has 85 total commits on `main`. Most recent upstream activity: 2026-06-03 (Angular dep bumps, coupon-code feature, email availability validation, checkout stepper refactor, profile link a11y fix).
- The local fork's `upstream` remote is currently absent (`git status` reports "upstream is gone"). It will be re-added.
- The local fork is missing top-level folders described in upstream's README: `src/app/features/admin/`, `src/app/features/home/`, and a project-root `design-system/`. The literal upstream tree will be confirmed via the GitHub tree API or a temporary fetch before the cherry-pick.
- The local fork's test suite is currently red with 5 known TypeScript errors documented in `README-TEST-INSIGHTS.md` (stale `mockOrder` / `mockAdminOrderListItem` fixtures missing `tipAmount` / `scheduledAt`; one call to a non-existent `canDeactivate`). This sync does **not** fix those — it preserves the existing state and may change the failure count.

## Scope

In scope:

- Add `upstream` remote pointing at `https://github.com/realworld-angular/realworld-angular.git`.
- Create a feature branch `sync/upstream-2026-06` from the upstream tip.
- **Cherry-pick** the 9 sandbox-only commits onto the upstream tip in original order. (Rebase is impossible: the two histories share no common ancestor. Cherry-pick applies each commit's diff to the current tree and uses 3-way merge for conflicts, which the per-file policy below still covers.)
- Resolve conflicts using the policy in section "Conflict resolution policy" below.
- Run `pnpm install`, `pnpm run build`, `pnpm run lint`, and `pnpm run test` on the resulting branch. Report the results.
- Open a PR from `sync/upstream-2026-06` to `main` with a structured body.

Out of scope:

- Fixing the 5 pre-existing test errors. Tracked separately.
- Upgrading or downgrading any dependency past what upstream ships in its tip.
- Removing or relocating sandbox tooling (memory-compiler, agent skills, test READMEs) on the basis that they "shouldn't" be in the repo. They are an intentional overlay.
- Adding automation for future syncs (Dependabot config, scheduled cherry-pick job, etc.). This is a one-time sync.
- Force-pushing against `main` or any existing branch.

## Branch and history strategy

- `main` — local fork's main; unchanged during the sync work.
- `sync/upstream-2026-06` — feature branch created from the upstream tip. Target of the cherry-pick and the source branch of the PR.
- `upstream/main` (remote tracking) — read-only reference to `realworld-angular/realworld-angular@main`.

Commit ordering on `sync/upstream-2026-06` (bottom to top):

1. The upstream tip commit (current `chore: update Angular dependencies and TypeScript version` on `upstream/main`).
   2..10. The 9 sandbox-only commits in original order:
   - `01a3113` Added memory compiler to track changes
   - `c69605d` added angular mcp server
   - `0b8e7db` installed dependencies
   - `99878b2` created claude MD
   - `29655c0` docs: add design spec for Angular agent skills integration
   - `fe6637f` docs: add implementation plan for Angular agent skills integration
   - `ff20f46` feat: add Angular agent skills (angular-developer, angular-new-app) to .claude/skills
   - `87541d1` docs: add design spec for project summary documentation
   - `82dcc52` docs: add implementation plan for project summary documentation
   - `b5925c6` docs: add standalone Mermaid architecture diagram

   Note: `2464e99` (initial clone) is replaced by the upstream tip. The newest local commit (`b5925c6`) ends up on top.

- The PR targets `main`. The PR body includes: upstream tip SHA, list of cherry-pick conflicts and how each was resolved, verification command output, and a note on the pre-existing test red.
- No force-push. The feature branch is new, not a rewrite of a published branch.

## Conflict resolution policy

The likely conflict surface, with policy per path:

| Path                               | Why it might conflict                                                                                                                                  | Resolution policy                                                                                                                                                                                                                                                                                       |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `package.json`                     | Upstream bumped Angular, TypeScript, ESLint deps on 2026-06-03.                                                                                        | Take upstream's `package.json`. Confirm none of the 9 sandbox commits add a dep that should be preserved.                                                                                                                                                                                               |
| `pnpm-lock.yaml`                   | Will definitely conflict after the dep bump.                                                                                                           | Regenerate via `pnpm install`. Do not hand-merge.                                                                                                                                                                                                                                                       |
| `angular.json`                     | Low risk — no local changes, but upstream may have added projects.                                                                                     | Take upstream's version verbatim.                                                                                                                                                                                                                                                                       |
| `tsconfig*.json`                   | Low risk.                                                                                                                                              | Take upstream's version verbatim.                                                                                                                                                                                                                                                                       |
| `README.md`                        | Upstream's structure changed. Local added `README-TESTING.md` and `README-TEST-INSIGHTS.md` as separate files (no conflict on the main README itself). | Take upstream's `README.md`. The new test READMEs are separate files with no conflict.                                                                                                                                                                                                                  |
| `.claude/`                         | Local added `settings.json`, `settings.local.json`, skills, hooks. Upstream may have its own `.claude/` content.                                       | Take upstream's `.claude/` content where it exists. Re-overlay local-only entries: `.claude/settings.json`, hook paths in `settings.local.json`, the new `angular-developer` and `angular-new-app` skill directories. Treat sandbox tooling as additive unless upstream's content is a strict superset. |
| `.agents/skills/angular-developer` | Upstream ships this; local added both `angular-developer` and `angular-new-app`.                                                                       | Take upstream's `angular-developer`. Keep local's `angular-new-app`.                                                                                                                                                                                                                                    |
| `skills-lock.json`                 | Both sides may have it.                                                                                                                                | Take upstream's; merge any local-only entries.                                                                                                                                                                                                                                                          |
| `docs/`                            | Local added design + plan docs. Upstream may have its own `docs/`.                                                                                     | Take upstream's `docs/`; re-overlay local doc subdirectories. If a path collides, prefer upstream and flag.                                                                                                                                                                                             |
| `src/` (any subpath)               | Low risk — the 9 sandbox commits do not touch `src/`. The upstream tree contains features the local lacks (`home/`, `admin/`, `design-system/`).       | Take upstream's `src/` verbatim. No overlay needed.                                                                                                                                                                                                                                                     |

Per-conflict decision rule (when policy does not say):

1. If the file is configuration, dependencies, lockfile, or a code path the sandbox did not touch → take upstream.
2. If the file is a sandbox-only artifact (new file, sandbox tooling) → take local.
3. If both modified the same file in incompatible ways → take upstream for the structural parts and re-apply the sandbox's _additive_ changes manually. Document the decision in the PR body.

Unresolvable conflicts: stop the cherry-pick at that commit, leave the working tree dirty, and surface the file to the user. Do not `--continue` past a suspicious conflict.

## Verification

Run on `sync/upstream-2026-06` after the cherry-pick, before opening the PR.

1. `pnpm install` — must exit 0; the dep tree resolves against the new `package.json`. Capture exit code and any peer-dep warnings.
2. `pnpm run build` — production build must complete and emit `dist/`. Capture exit code and bundle size.
3. `pnpm run lint` — must exit 0. The earlier session noted the test suite is red, not the lint suite; if lint fails after the cherry-pick, that is a real regression and needs investigation.
4. `pnpm run test` — must run. Per prior analysis, expected to be red (5 TypeScript errors from stale fixtures). Report the count, the new count if it changed, and the failing specs. Do not fix pre-existing failures as part of this sync. If the failure count is **higher** than 5, or the failing files are **different** from the 4 fixture-drift specs and 1 `canDeactivate` spec, treat as a regression and investigate.
5. Manual smoke (optional, fast). Start `pnpm start` and load `/` and `/auth/login` to confirm the dev server boots. Skipped if any of 1–4 fails.

Pass criteria for opening the PR:

- All four commands ran.
- Build exit 0, lint exit 0, `pnpm install` exit 0.
- Test failure count ≤ 5, and failures match the previously-known set.
- Working tree clean.

Failure handling:

- `pnpm install` failure on the new `package.json` → cherry-pick picked a wrong version of a sandbox-modified file. Inspect, fix, re-run.
- Build failure on a missing import or type → cherry-pick dropped a file or kept a stale `tsconfig`. Inspect and resolve using the conflict policy.
- Lint failure on a file the sandbox did not touch → upstream regression. Report and surface; do not "fix" upstream code.
- New test failures → regression. Investigate by inspecting the affected spec and the upstream changes to the file it covers. If the local commit is the cause, take local; if upstream is the cause, surface to user.

## Rollback

- `sync/upstream-2026-06` is a new local branch — deletion is the rollback: `git branch -D sync/upstream-2026-06` discards the sync work entirely with no impact on `main` or any pushed branch.
- If the cherry-pick is in progress and produces a conflict the user wants to abort: `git cherry-pick --abort` returns the branch to its pre-cherry-pick state. The user retains full local-only history on `main` unchanged.
- The upstream remote is additive; removing it has no blast radius beyond losing the fetch reference.

## Open questions

- The exact list of upstream commits the cherry-pick will replay over (~75) — discovered via `git log upstream/main` once the remote is added.
- Whether upstream's `src/app/features/admin/` exists in the tip, or only in the README's documentation — resolved by fetching the literal tree via the GitHub tree API or `git ls-tree`.
- Whether upstream's `.claude/` directory exists or whether their skill lives in `.agents/` — resolved at first conflict.
- Whether the sandbox's `angular-new-app` skill collides with anything upstream added under a similar name.

## Deliverables

- This design spec at `docs/superpowers/specs/2026-06-03-realworld-upstream-sync-design.md`, committed before the plan.
- A PR from `sync/upstream-2026-06` → `main` titled `chore: sync fork with realworld-angular upstream (Jun 2026)` with body listing: upstream SHA at sync time, cherry-pick conflicts encountered and resolution, verification command output, and a note on the pre-existing test red.
- A short `SYNC-NOTES.md` (or appended section in the PR description) listing any per-file override decisions, so future syncs have a reference.

## Out of scope (called out in the PR)

- The 5 pre-existing test errors (stale fixtures, missing `canDeactivate`). Tracked separately.
- Any attempt to fix upstream's test state, even if their test suite is also red.
- Renaming or restructuring the sandbox's tooling to "match" upstream's documentation.

## Estimated effort

Mostly mechanical: 1 remote add, 1 fetch, 1 branch, 9 cherry-picks, conflict resolution in ~5–10 files, 4 verification commands, 1 PR. The conflict resolution is the only part where the time is unpredictable. Best case: under 15 minutes. Worst case: surface an unresolvable conflict to the user and stop.

## Risks and mitigations

- **Risk:** `package.json` cherry-pick picks a version that loses a sandbox dev-dep.
  - **Mitigation:** Verify `package.json` after the cherry-pick; diff against pre-cherry-pick to confirm only the upstream-bumped entries changed.
- **Risk:** `.claude/` conflict is tangled between upstream and local tooling.
  - **Mitigation:** Per-path policy: take upstream first, re-overlay local-only entries by hand. Document every overlay in the PR body.
- **Risk:** Test failures double in count after the cherry-pick.
  - **Mitigation:** The verification step explicitly checks for new failures vs. the previously-known set. New failures block the PR; old failures are called out and skipped.
- **Risk:** Upstream's source structure has changed in ways the README does not document (e.g., feature renamed).
  - **Mitigation:** `git fetch` + `git ls-tree -r upstream/main src/` before the cherry-pick to confirm the literal tree.
