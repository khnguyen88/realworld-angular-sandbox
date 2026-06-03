# Sync local fork with `realworld-angular/realworld-angular` upstream — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the local fork (`khnguyen88/realworld-angular-sandbox`) current with upstream `realworld-angular/realworld-angular`, preserving the 9 sandbox-only commits on top, and open a PR for review.

**Architecture:** Add the missing `upstream` remote, fetch, create a feature branch `sync/upstream-2026-06` from the upstream tip, then **cherry-pick** the 9 sandbox-only commits onto it using a per-file conflict policy. (Rebase is impossible — the local and upstream histories share no common ancestor; cherry-pick applies each commit's diff via 3-way merge.) Verify with `pnpm install`, `pnpm run build`, `pnpm run lint`, `pnpm run test`. Open a PR.

**Tech Stack:** Git, pnpm, Angular 21, Vitest, ESLint, Prettier, GitHub CLI (`gh`).

**Note on worktree:** The writing-plans skill recommends a worktree. We are not using one for this plan: the feature branch is the isolation boundary, the spec explicitly forbids force-push against `main`, and rollback is a single `git branch -D`. A worktree would add machinery without isolation benefit.

**Note on TDD:** This plan is operational (cherry-pick + verification), not feature development. There are no new tests to write. Verification commands are the test surface. The pre-existing 5-error red in the test suite is preserved (not fixed) and verified not to grow.

---

## File Structure

This plan modifies no source files. It produces a single deliverable — a synced feature branch — and one new tracked file (`SYNC-NOTES.md`).

| Path                             | Action                        | Responsibility                                                                                  |
| -------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------- |
| `.git/config`                    | Modify (via `git remote add`) | Add `upstream` remote pointing at `https://github.com/realworld-angular/realworld-angular.git`. |
| `sync/upstream-2026-06` (branch) | Create                        | Target branch for the cherry-pick and the source of the PR.                                     |
| `SYNC-NOTES.md`                  | Create at repo root           | Records cherry-pick decisions, conflict resolutions, and verification results.                  |

No source files under `src/`, no `package.json` changes beyond what the cherry-pick applies, no test changes.

---

## Task 1: Add upstream remote and fetch

**Files:** None modified. `.git/config` is updated by `git remote add`.

- [ ] **Step 1: Add the upstream remote**

Run:

```bash
git remote add upstream https://github.com/realworld-angular/realworld-angular.git
```

Expected: command exits 0, no output.

- [ ] **Step 2: Verify the remote was added**

Run:

```bash
git remote -v
```

Expected output (excerpt):

```
origin    https://github.com/khnguyen88/realworld-angular-sandbox.git (fetch)
origin    https://github.com/khnguyen88/realworld-angular-sandbox.git (push)
upstream  https://github.com/realworld-angular/realworld-angular.git (fetch)
upstream  https://github.com/realworld-angular/realworld-angular.git (push)
```

- [ ] **Step 3: Fetch upstream main**

Run:

```bash
git fetch upstream main
```

Expected: command exits 0. Output includes `From https://github.com/realworld-angular/realworld-angular` and a line such as `* [new branch] main -> upstream/main`.

- [ ] **Step 4: Record the upstream tip SHA and verify it's a descendant of the local clone**

Run:

```bash
git rev-parse upstream/main
git merge-base --is-ancestor 2464e99 upstream/main && echo "local-clone is ancestor of upstream" || echo "WARN: local clone is not an ancestor of upstream"
```

Expected: prints a 40-character SHA, then `local-clone is ancestor of upstream`. If the second line says WARN, the local clone diverged and the spec assumption is wrong — stop and surface to the user.

- [ ] **Step 5: Note the SHA for later use**

Capture the SHA from step 4 as `UPSTREAM_TIP`. Save it to a scratch variable for later tasks:

Run (PowerShell):

```powershell
$env:UPSTREAM_TIP = git rev-parse upstream/main
echo "UPSTREAM_TIP=$env:UPSTREAM_TIP"
```

Or in bash:

```bash
export UPSTREAM_TIP=$(git rev-parse upstream/main)
echo "UPSTREAM_TIP=$UPSTREAM_TIP"
```

Expected: prints `UPSTREAM_TIP=<40-char-sha>`.

- [ ] **Step 6: Commit nothing — this task is remote-config only**

No commit. The remote addition is local config; nothing is committed to source control.

---

## Task 2: Inspect upstream tree before rebasing

**Files:** None modified. Output informs later tasks.

- [ ] **Step 1: List upstream's top-level `src/app/features/`**

Run:

```bash
git ls-tree --name-only upstream/main src/app/features/
```

Expected: prints one directory per line. Verify that `admin/`, `home/`, and the other features the README describes are present. Cross-check against the spec's "Local fork is missing `admin/`, `home/`" claim.

- [ ] **Step 2: List upstream's top-level `src/`**

Run:

```bash
git ls-tree --name-only upstream/main src/
```

Expected: prints directories present in upstream's `src/`. Compare against local:

Run:

```bash
ls src/
```

If upstream has a `design-system/` directory (or any other top-level path) that local does not, the cherry-pick will add it — no action needed; this is informational.

- [ ] **Step 3: Check whether upstream has `.claude/` or only `.agents/`**

Run:

```bash
git ls-tree --name-only upstream/main .claude/ 2>&1 | head -5
echo "---"
git ls-tree --name-only upstream/main .agents/ 2>&1 | head -5
```

Expected: at least one of the two prints entries. Use the result to update the conflict policy in Task 5 if upstream's `.claude/` content exists.

- [ ] **Step 4: Record observations in the PR body later**

No file write. Keep the comparison notes in conversation context for the PR body in Task 8.

- [ ] **Step 5: Commit nothing — inspection only**

---

## Task 3: Create the feature branch from upstream tip

**Files:** None modified.

- [ ] **Step 1: Create the feature branch from `upstream/main`**

Run:

```bash
git checkout -b sync/upstream-2026-06 upstream/main
```

Expected: command exits 0. Output: `Switched to a new branch 'sync/upstream-2026-06'`.

- [ ] **Step 2: Verify the branch is at the upstream tip**

Run:

```bash
git rev-parse HEAD
git rev-parse upstream/main
```

Expected: both print the same SHA (`$UPSTREAM_TIP` from Task 1).

- [ ] **Step 3: Verify the working tree is clean**

Run:

```bash
git status --short
```

Expected: empty output (no untracked, no modified). If anything is dirty, the cherry-pick will get confused — stop and surface.

- [ ] **Step 4: Commit nothing**

---

## Task 4: Begin the cherry-pick — replay the 9 sandbox commits

**Files:** None modified directly. Cherry-pick modifies the index and working tree.

This task is the start of the cherry-pick sequence. The 9 commits will be replayed one by one. Each commit may produce conflicts; the resolution for each known path is defined in Task 5. Unresolvable conflicts stop the cherry-pick (Task 6).

- [ ] **Step 1: Identify the list of local-only commits to cherry-pick (oldest first)**

Run:

```bash
git log --reverse --format=%H upstream/main..main
```

Expected: prints 9 SHAs in chronological order, oldest first. Save the list as a variable.

Run (PowerShell):

```powershell
$commits = git log --reverse --format=%H upstream/main..main
Write-Host "Commits to cherry-pick (oldest first):"
$commits | ForEach-Object { Write-Host "  $_" }
```

Or in bash:

```bash
mapfile -t commits < <(git log --reverse --format=%H upstream/main..main)
echo "Commits to cherry-pick (oldest first):"
printf '  %s\n' "${commits[@]}"
```

Expected: 9 SHAs, e.g. `01a3113`, `c69605d`, `0b8e7db`, `99878b2`, `29655c0`, `fe6637f`, `ff20f46`, `87541d1`, `82dcc52`, `b5925c6`. (Order matches the spec's commit list.)

- [ ] **Step 2: Cherry-pick the 9 commits in order**

Run (PowerShell):

```powershell
$commits = git log --reverse --format=%H upstream/main..main
foreach ($c in $commits) {
  Write-Host "=== Cherry-picking $c ==="
  git cherry-pick $c
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Cherry-pick stopped at $c (conflicts or error). Resolve in Task 5, then continue."
    break
  }
}
```

Or in bash:

```bash
mapfile -t commits < <(git log --reverse --format=%H upstream/main..main)
for c in "${commits[@]}"; do
  echo "=== Cherry-picking $c ==="
  git cherry-pick "$c" || {
    echo "Cherry-pick stopped at $c (conflicts or error). Resolve in Task 5, then continue."
    break
  }
done
```

Expected: each cherry-pick either succeeds (the commit is replayed onto the current branch) or stops on a conflict. The loop breaks on the first failure so the conflicts can be resolved interactively in Task 5.

- [ ] **Step 3: Check cherry-pick status**

Run:

```bash
git status
```

Expected: either a clean working tree (if all 9 cherry-picks succeeded without conflicts) or "Cherry-picking in progress" with a list of unmerged paths (conflicts to resolve in Task 5).

- [ ] **Step 4: Commit nothing — cherry-pick creates the commits automatically**

If cherry-pick succeeds for a commit, it creates the commit on the branch with the original commit's message. If it stops on a conflict, the conflict resolution in Task 5 followed by `git cherry-pick --continue` produces the commit.

---

## Task 5: Resolve conflicts per file

**Files:** Per-path resolution, see below. No new file content; this is conflict resolution, not authoring.

This task is repeated up to 9 times — once per sandbox commit. Each replay may produce a fresh set of conflicts. Follow the per-path policy below for each conflict surfaced. If a conflict is not covered by the policy, stop and surface to the user (Task 6).

**Pre-flight (run once):** confirm `git` config is reasonable:

```bash
git config --local --get rerere.enabled || echo "rerere off (fine)"
```

If rerere is on, cherry-pick may auto-resolve repeated conflicts; the resolution still must be verified by inspection. Default rerere state in this repo is unknown — check first.

### Path-by-path policy

For each conflict surfaced by `git cherry-pick`, apply the matching rule. **In cherry-pick, `--ours` is the current branch (the upstream tip) and `--theirs` is the commit being applied (the local sandbox commit).** This is the opposite of rebase. Watch the direction carefully.

#### `package.json`

- [ ] **If conflict:** Take the upstream version of the file. None of the 9 sandbox commits modified `package.json` (verify by checking `git log --all -- package.json` — only the initial clone and upstream should have touched it). If a sandbox commit did touch it, hand-merge instead.

```bash
git checkout --ours package.json
git add package.json
```

#### `pnpm-lock.yaml`

- [ ] **If conflict:** Do **not** hand-merge. Resolve the conflict by taking upstream's lockfile, then regenerate after the cherry-pick sequence completes:

```bash
git checkout --ours pnpm-lock.yaml
git add pnpm-lock.yaml
```

The regeneration step is Task 7, Step 1.

#### `angular.json`, `tsconfig.json`, `tsconfig.app.json`, `tsconfig.spec.json`

- [ ] **If conflict:** Take upstream verbatim:

```bash
git checkout --ours <path>
git add <path>
```

#### `README.md`

- [ ] **If conflict:** Take upstream's `README.md`. The local sandbox's new test READMEs (`README-TESTING.md`, `README-TEST-INSIGHTS.md`) are separate files and do not conflict.

```bash
git checkout --ours README.md
git add README.md
```

#### `.claude/`

- [ ] **If conflict:** Apply per-file policy:
  - `.claude/settings.json` (local-only): take local (`--theirs` in cherry-pick direction).
  - `.claude/settings.local.json` (local-only, contains hook paths): take local. If upstream adds `.claude/settings.local.json`, hand-merge the `hooks` object — local hook paths point at `memory-compiler/hooks/` and must remain.
  - Any other `.claude/*` file: take upstream (`--ours`) if upstream has it; take local (`--theirs`) if local-only.

```bash
# Default for unknown .claude/ entries
git checkout --ours <path>

# For local-only entries:
git checkout --theirs <path>
```

#### `.agents/skills/angular-developer`

- [ ] **If conflict:** Take upstream verbatim. The local sandbox added `angular-new-app` (a different directory), which is not in conflict:

```bash
git checkout --ours .agents/skills/angular-developer
git add .agents/skills/angular-developer
```

#### `.agents/skills/angular-new-app`

- [ ] **If conflict (unlikely; this is local-only):** Take local:

```bash
git checkout --theirs .agents/skills/angular-new-app
git add .agents/skills/angular-new-app
```

#### `skills-lock.json`

- [ ] **If conflict:** Take upstream's, then append any local-only entries:

```bash
git checkout --ours skills-lock.json
# Manually append local-only keys from the pre-cherry-pick version:
git show main:skills-lock.json > /tmp/local-skills-lock.json
# Use any JSON tool to merge — for example, jq:
jq -s '.[0] * .[1]' skills-lock.json /tmp/local-skills-lock.json > /tmp/merged-skills-lock.json
mv /tmp/merged-skills-lock.json skills-lock.json
git add skills-lock.json
```

#### `docs/`

- [ ] **If conflict:** Per subdirectory:
  - `docs/superpowers/specs/2026-05-28-angular-agent-skills-design.md` (and any other local design/plan docs): take local.
  - `docs/superpowers/specs/2026-06-03-realworld-upstream-sync-design.md` (just committed in the planning step): take local.
  - `docs/superpowers/plans/*` (local-only): take local.
  - `docs/diagrams/*` (local-only): take local.
  - Any other `docs/*` path: take upstream, then re-overlay local subdirs.

```bash
# Per-path
git checkout --ours <path>   # for upstream docs
git checkout --theirs <path> # for local-only docs
```

#### `src/` (any subpath)

- [ ] **If conflict (unlikely — sandbox commits don't touch `src/`):** Take upstream. No overlay needed.

```bash
git checkout --ours <path>
```

#### Any other path

- [ ] **If conflict and not covered above:** Stop the cherry-pick (do **not** `git cherry-pick --continue`):

```bash
git cherry-pick --abort
```

Then surface the conflict to the user with the path and the conflicting commits. Do not attempt to resolve ad-hoc.

### Continuing the cherry-pick

After all conflicts in a commit are resolved and staged:

- [ ] **Continue the cherry-pick**

Run:

```bash
git status
```

Expected: "all conflicts fixed: run `git cherry-pick --continue`". If yes:

```bash
git cherry-pick --continue
```

If the cherry-pick prompts for a commit message, accept the default (the original sandbox commit message). If `git` opens an editor and you need to accept without editing, set `GIT_EDITOR=true` first or use `--no-edit` (but `--no-edit` is not a flag of `cherry-pick --continue` — it must be set on the original `cherry-pick` call, which is too late now). Easiest fallback: press Enter in the editor to accept the default message.

- [ ] **Repeat for each of the 9 commits**

The loop in Task 4 Step 2 broke at the first conflict. After resolving in Task 5, re-run the loop to continue from the next commit. Specifically, set `$commits` again (or in bash, re-source the `mapfile` line) and resume the loop, skipping the commits that have already been cherry-picked (check `git log --oneline | head -10` to see which commits are now on the branch).

- [ ] **When all 9 cherry-picks finish**

Run:

```bash
git status
git log --oneline -15
```

Expected: "On branch sync/upstream-2026-06", nothing to commit, working tree clean. The 9 sandbox commits should appear at the top of the log, in original order, on top of the upstream tip.

---

## Task 6: Handle unresolvable conflicts

**Files:** None modified. This task runs only if Task 5 surfaced an unresolvable conflict.

If during Task 5 you encountered a conflict that the policy did not cover, the cherry-pick was aborted in Task 5's "Any other path" branch. This task is the recovery.

- [ ] **Step 1: Confirm the cherry-pick was aborted**

Run:

```bash
git status
```

Expected: "On branch sync/upstream-2026-06" with a clean working tree (or with uncommitted changes that were the source of the conflict).

- [ ] **Step 2: Document the conflict for the user**

Write a short note (in conversation or in a temp file) including:

- The path that conflicted.
- The two SHAs involved (the upstream tip and the local sandbox commit being cherry-picked).
- The nature of the conflict (one-sentence summary).
- The pre-cherry-pick contents of the conflicting file (from `git show <upstream-sha>:<path>` and `git show <local-sha>:<path>`).

- [ ] **Step 3: Stop and surface to the user**

Do not attempt to resolve the conflict. The user decides:

- Take upstream (override local).
- Take local (override upstream).
- Hand-merge (the user provides a resolution).
- Abort the sync entirely (delete the feature branch, no PR).

The user can resume by either:

- Manually resolving the file and running `git cherry-pick --continue`, or
- Aborting the sync and starting over with a different policy.

---

## Task 7: Verify the synced branch

**Files:** None modified. Outputs are captured for the PR body and `SYNC-NOTES.md`.

- [ ] **Step 1: Regenerate `pnpm-lock.yaml`**

Run:

```bash
pnpm install
```

Expected: command exits 0. Output reports that the lockfile is up to date or has been updated. Capture any peer-dep warnings.

- [ ] **Step 2: Commit the regenerated lockfile if it changed**

If `git status` shows `pnpm-lock.yaml` as modified after install:

```bash
git add pnpm-lock.yaml
git commit -m "chore: regenerate pnpm-lock.yaml after upstream sync"
```

This is a separate small commit on top of the 9 cherry-picked sandbox commits, leaving the cherry-pick history clean. (Amending into a cherry-picked commit is risky because cherry-picked commits have a different parent than the original; the safest move is a separate commit.)

- [ ] **Step 3: Run the production build**

Run:

```bash
pnpm run build
```

Expected: command exits 0. Output ends with a hash report and a line such as `Application bundle generation complete`. Capture the exit code and the bundle size from the output.

- [ ] **Step 4: Run the linter**

Run:

```bash
pnpm run lint
```

Expected: command exits 0. If it does not, this is a regression — investigate. Common causes: upstream's code differs from the local copy in a way that surfaces a new lint rule, or the cherry-pick dropped a `tsconfig` change that suppresses a rule.

- [ ] **Step 5: Run the tests**

Run:

```bash
pnpm run test
```

Expected: command runs to completion. The pre-existing 5-error red may still be present. Capture:

- The total number of tests run.
- The number of failures.
- The list of failing spec files.

Pass criteria (per the spec):

- Build exit 0, lint exit 0, `pnpm install` exit 0.
- Test failure count ≤ 5, and failures match the previously-known set (4 fixture-drift specs + 1 `canDeactivate` reference).

If the failure count is greater than 5, or the failing files differ from the known set, this is a regression. Investigate: which spec failed, what is the upstream change to the file it covers, and which local commit touched the spec. Do not commit anything until the regression is resolved.

- [ ] **Step 6: Capture verification output**

Save the four command outputs (install, build, lint, test) to a scratch file for the PR body and `SYNC-NOTES.md`:

```bash
{
  echo "=== pnpm install ==="
  pnpm install 2>&1 | tail -20
  echo ""
  echo "=== pnpm run build ==="
  pnpm run build 2>&1 | tail -30
  echo ""
  echo "=== pnpm run lint ==="
  pnpm run lint 2>&1 | tail -20
  echo ""
  echo "=== pnpm run test ==="
  pnpm run test 2>&1 | tail -50
} > /tmp/sync-verification.log
```

Expected: writes a log to `/tmp/sync-verification.log`.

---

## Task 8: Write `SYNC-NOTES.md`

**Files:**

- Create: `SYNC-NOTES.md` at the repo root.

- [ ] **Step 1: Write the sync notes file**

Create `SYNC-NOTES.md` with the following content (substitute real values from previous tasks):

```markdown
# Upstream Sync Notes — 2026-06-03

**Upstream tip:** <UPSTREAM_TIP from Task 1>
**Feature branch:** `sync/upstream-2026-06`
**Source:** https://github.com/realworld-angular/realworld-angular

## Cherry-pick outcome

| Commit replayed                                                                                 | Conflicts encountered | Resolution                |
| ----------------------------------------------------------------------------------------------- | --------------------- | ------------------------- |
| `01a3113` Added memory compiler to track changes                                                | <list or "none">      | <per-file policy applied> |
| `c69605d` added angular mcp server                                                              | <list or "none">      | <per-file policy applied> |
| `0b8e7db` installed dependencies                                                                | <list or "none">      | <per-file policy applied> |
| `99878b2` created claude MD                                                                     | <list or "none">      | <per-file policy applied> |
| `29655c0` docs: add design spec for Angular agent skills integration                            | <list or "none">      | <per-file policy applied> |
| `fe6637f` docs: add implementation plan for Angular agent skills integration                    | <list or "none">      | <per-file policy applied> |
| `ff20f46` feat: add Angular agent skills (angular-developer, angular-new-app) to .claude/skills | <list or "none">      | <per-file policy applied> |
| `87541d1` docs: add design spec for project summary documentation                               | <list or "none">      | <per-file policy applied> |
| `82dcc52` docs: add implementation plan for project summary documentation                       | <list or "none">      | <per-file policy applied> |
| `b5925c6` docs: add standalone Mermaid architecture diagram                                     | <list or "none">      | <per-file policy applied> |

## Per-file overrides

<list of any paths where the policy was overridden, with rationale>

## Verification

| Command          | Exit  | Notes                                 |
| ---------------- | ----- | ------------------------------------- |
| `pnpm install`   | <0/1> | <one-line summary>                    |
| `pnpm run build` | <0/1> | <bundle size or error>                |
| `pnpm run lint`  | <0/1> | <errors or "clean">                   |
| `pnpm run test`  | <0/N> | <N> failures; <list of failing specs> |

## Pre-existing test red (not fixed by this sync)

The test suite is red with 5 known TypeScript errors documented in `README-TEST-INSIGHTS.md`:

- 4 specs with stale `mockOrder` / `mockAdminOrderListItem` fixtures missing `tipAmount` / `scheduledAt`.
- 1 spec (`checkout-page.spec.ts`) calls a non-existent `canDeactivate` method.

This sync preserved those failures. A separate spec covers the fix.
```

- [ ] **Step 2: Commit `SYNC-NOTES.md`**

```bash
git add SYNC-NOTES.md
git commit -m "docs: add sync notes for upstream cherry-pick"
```

Expected: commit succeeds.

---

## Task 9: Push the feature branch and open the PR

**Files:** None modified. Remote branch and PR are created.

- [ ] **Step 1: Push the feature branch to origin**

```bash
git push -u origin sync/upstream-2026-06
```

Expected: command exits 0. Output reports `* [new branch] sync/upstream-2026-06 -> sync/upstream-2026-06`.

- [ ] **Step 2: Open the PR using `gh`**

```bash
gh pr create \
  --base main \
  --head sync/upstream-2026-06 \
  --title "chore: sync fork with realworld-angular upstream (Jun 2026)" \
  --body "$(cat <<'EOF'
## Summary

Syncs the local fork with upstream `realworld-angular/realworld-angular@main` (tip: `<UPSTREAM_TIP>`) and replays the 9 sandbox-only commits on top via cherry-pick.

## What changed

- Adds `upstream` remote.
- Brings the local fork's source, deps, and structure in line with upstream.
- Preserves all 9 sandbox-only commits: CLAUDE.md, memory-compiler, MCP server, agent skills, test READMEs.
- Adds `SYNC-NOTES.md` documenting the cherry-pick decisions.

## Conflicts encountered

<list of paths that conflicted and how each was resolved; "none" if no conflicts>

## Verification

<insert the verification log from /tmp/sync-verification.log or a summary table>

## Pre-existing test red

The test suite is red with 5 known TypeScript errors (see `README-TEST-INSIGHTS.md`):

- 4 specs with stale `mockOrder` / `mockAdminOrderListItem` fixtures missing `tipAmount` / `scheduledAt`.
- 1 spec (`checkout-page.spec.ts`) calls a non-existent `canDeactivate` method.

This sync preserves those failures. A separate spec covers the fix. The PR does not change the failure count (or: it changes it to N — see SYNC-NOTES.md).

## Out of scope

- Fixing the 5 pre-existing test errors.
- Any dependency change beyond what upstream ships.
- Sandbox tooling removal or restructuring.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Expected: `gh` prints a URL to the new PR (e.g. `https://github.com/khnguyen88/realworld-angular-sandbox/pull/<N>`).

- [ ] **Step 3: Verify the PR was created**

```bash
gh pr view --json number,title,url,baseRefName,headRefName
```

Expected: returns JSON with the new PR's number, title, URL, and that `baseRefName` is `main` and `headRefName` is `sync/upstream-2026-06`.

---

## Task 10: Final summary for the user

**Files:** None.

- [ ] **Step 1: Report what was done**

In the conversation, report:

- The PR URL.
- The upstream tip SHA.
- The number of conflicts encountered during the cherry-pick and how they were resolved.
- The verification command results (install, build, lint, test).
- Any unresolvable conflicts that were surfaced (should be none if the plan ran to completion).
- The current state of the working tree (clean, on `sync/upstream-2026-06`).
- The next step for the user (review the PR, address any review feedback, merge when ready).

---

## Self-Review (against the spec)

**Spec coverage:**

- "Add `upstream` remote" → Task 1.
- "Create a feature branch `sync/upstream-2026-06` from the upstream tip" → Task 3.
- "Cherry-pick the 9 sandbox-only commits onto the upstream tip in original order" → Task 4.
- "Resolve conflicts using the policy" → Task 5.
- "Run `pnpm install`, `pnpm run build`, `pnpm run lint`, and `pnpm run test`" → Task 7.
- "Open a PR from `sync/upstream-2026-06` to `main`" → Task 9.
- "A short `SYNC-NOTES.md`" → Task 8.
- "Stop on unresolvable conflict, surface to user" → Task 6.
- "No force-push against `main`" → never used `git push --force` or `git push --force-with-lease`; Task 9 uses `git push -u origin sync/upstream-2026-06` (no force).
- "Working tree clean at the end" → Task 8 commit cleans `SYNC-NOTES.md`; verification step 2 commits the lockfile; final `git status` should be clean.
- "Pre-existing test red preserved" → Task 7, Step 5 pass criteria explicitly allow the known-5-failure state and flag any growth as a regression.

**Strategy shift acknowledged:** the spec's rebase strategy was invalid because the local and upstream histories share no common ancestor. The plan was amended to use cherry-pick instead. Cherry-pick's `--ours` / `--theirs` direction is the opposite of rebase's; the conflict policy in Task 5 was rewritten to use the correct direction. This is the kind of correction the design's pre-flight inspection exists to catch.

**Placeholder scan:** No "TBD", "TODO", "fill in", or "implement later" in any step. The PR body template has `<...>` placeholders that are substituted with real values before the body is passed to `gh`.

**Type / name consistency:** The branch name `sync/upstream-2026-06`, the remote name `upstream`, the file `SYNC-NOTES.md`, and the upstream URL `https://github.com/realworld-angular/realworld-angular.git` are consistent across all tasks.

**No implicit knowledge:** Every command is given in full. Every path is exact. The conflict policy in Task 5 is the only place where a decision rule is summarized, and each rule is followed by an explicit command to run.

**Gap:** The spec says the PR body should include "list of cherry-pick conflicts and how each was resolved" — Task 9's body template has a placeholder for this, and the user fills it in from `SYNC-NOTES.md` (Task 8). This is intentional: the placeholders are not unresolvable — they are populated from the artifact of Task 8.

**Gap:** The spec says "the user retains full local-only history on `main` unchanged" in rollback — `main` is not touched by any task in this plan. Verified.

No fixes required.
