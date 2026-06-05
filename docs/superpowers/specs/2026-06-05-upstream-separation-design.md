# Upstream Separation: realworld-angular sandbox refactor

**Date:** 2026-06-05
**Status:** Approved (brainstorming complete)
**Branch target:** `sync/upstream-2026-06` (or current working branch at implementation time)

## Problem

The sandbox is a single tree that mixes two distinct concerns:

1. **Upstream Angular SPA** — a copy of [realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular) (MIT, Angular 22, single SPA, pnpm-workspace-shaped-but-single-app).
2. **Sandbox layer** — user-owned files added on top: `CLAUDE.md`, `.claude/` (hooks, skills, settings), `docs/`, `memory-compiler/`, the test-insight READMEs, `SYNC-NOTES.md`.

Syncing the upstream today requires `git cherry-pick` into the same tree, which has produced recurring friction documented in `SYNC-NOTES.md`:

- `.claude/settings.local.json` 3-way conflicts between user WIP, harness additions, and upstream commits that touch `.claude/`.
- Untracked sandbox files (`.claude/settings.json`, `README-TESTING.md`, `README-TEST-INSIGHTS.md`, `memory-compiler/`) repeatedly need to be relocated to `/tmp/` to avoid "untracked working tree files would be overwritten" errors.
- Every sync produces an `MM` (staged + unstaged) state on `settings.local.json` from harness auto-mutation during the loop.
- The mental model conflates "what changed in the app" with "what changed in the sandbox."

## Goal

**Separate concerns.** The top level of the sandbox is the user's narrative + tooling layer (visible to the user and to LLM agents). The Angular app lives in a dedicated subdirectory. Future upstream syncs are mechanical: re-clone, snapshot, commit.

**Non-goals.** Fix upstream's red build. Restructure the upstream app. Convert the sandbox to a real monorepo. Replace the cherry-pick workflow with a more sophisticated one (e.g., subtree merge, git-submodule with pinning). Replace the existing memory-compiler / hooks / skills infrastructure.

## Final layout

```
sandbox-root/                                 (this repo)
├── .claude/                                  KEPT — your hooks, skills, settings
├── .git/                                     KEPT
├── .gitignore                                MODIFIED — new ignore rules
├── CLAUDE.md                                 MODIFIED — new "Upstream source of truth" section
├── LICENSE                                   KEPT (upstream is MIT; LICENSE remains accurate)
├── README.md                                 KEPT
├── README-TESTING.md                         KEPT
├── README-TEST-INSIGHTS.md                   KEPT
├── SYNC-NOTES.md                             REWRITTEN — new workflow reference + historical appendix
├── docs/                                     KEPT — diagrams, superpowers/, plans, specs
│   └── PROJECT-SUMMARY.md                    NEW — top-level "what is this sandbox" doc for LLM/user
├── memory-compiler/                          KEPT (already gitignored)
│
├── realworld-angular/                        NEW, GITIGNORED
│   ├── node_modules/                         (excluded by sync script; created by pnpm install)
│   ├── dist/                                 (gitignored)
│   ├── .angular/                             (gitignored)
│   └── ...full upstream tree from clone...
│
├── realworld-angular-snapshot/               NEW, TRACKED
│   ├── README.md                             NEW — one-line "what is this" note
│   ├── src/
│   ├── public/
│   ├── angular.json
│   ├── package.json
│   ├── pnpm-lock.yaml
│   ├── tsconfig.app.json
│   ├── tsconfig.json
│   ├── tsconfig.spec.json
│   ├── eslint.config.js
│   ├── .prettierrc
│   ├── .prettierrc.json
│   ├── .prettierignore
│   ├── .editorconfig
│   ├── .github/
│   ├── .vscode/
│   ├── .husky/
│   ├── .agents/                              (upstream ships this; tracked for parity)
│   ├── skills-lock.json
│   └── LICENSE
│
└── scripts/
    └── sync-upstream.sh                      NEW, TRACKED, executable bit not required on Windows
```

### Files removed at root (after snapshot is built)

These originated from the upstream tree and are now captured in `realworld-angular-snapshot/`:

- `angular.json`
- `tsconfig.app.json`, `tsconfig.json`, `tsconfig.spec.json`
- `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`
- `eslint.config.js`
- `src/`, `public/`
- `.editorconfig`
- `.prettierrc`, `.prettierrc.json`, `.prettierignore`
- `.angular/`, `dist/`, `node_modules/`
- `.husky/`, `.vscode/`, `.github/`
- `.agents/`
- `skills-lock.json`

These are recoverable from `git log` of the parent commit; the removal is reversible if needed.

### Files KEPT at root (sandbox-owned, untouched by the migration)

- `.claude/` (sandbox-owned — hooks, skills, settings)
- `CLAUDE.md` (sandbox-owned — modified to add new section)
- `LICENSE` (kept at root; the snapshot gets its own verbatim copy of the same MIT text)
- `README.md` (sandbox-owned)
- `README-TESTING.md` (sandbox-owned, currently untracked; stays untracked → not affected by migration)
- `README-TEST-INSIGHTS.md` (sandbox-owned, currently untracked; stays untracked → not affected by migration)
- `SYNC-NOTES.md` (sandbox-owned — rewritten, not removed)
- `docs/` (sandbox-owned — gets one new file, `PROJECT-SUMMARY.md`)
- `memory-compiler/` (sandbox-owned, already gitignored)
- `.gitignore` (sandbox-owned — modified to add new rules)
- `.git/`

The 3 currently-untracked files (`.claude/settings.json`, `README-TESTING.md`, `README-TEST-INSIGHTS.md`) are KEPT and UNTOUCHED. They appear in this list as sandbox-owned, not in the "Files removed at root" list. The migration does not add them to git; that is a separate user decision.

## Sync model

### `realworld-angular/` (throwaway clone, gitignored)

A full clone of upstream `main` at `--depth=1`. Re-cloned from scratch on every sync. Used to:

- `pnpm install` and `pnpm run build` to verify the upstream still works.
- Run the app locally (`pnpm start`).
- Run the upstream's own tests/lint (knowing they may be red — that's upstream's state, not ours).

Not used as a diff surface. Not read by LLM agents for analysis. The throwaway nature is the point: any state in this directory is ephemeral.

### `realworld-angular-snapshot/` (tracked mirror)

A byte-for-byte mirror of the upstream source tree, minus `node_modules/`, `dist/`, and `.angular/`. This is the **offline source of truth for LLM analysis**:

- An LLM agent opening this repo cold can read `realworld-angular-snapshot/src/` to understand the app.
- `git log -p realworld-angular-snapshot/` shows the history of upstream changes (one snapshot commit per sync).
- `git diff` between sync commits shows exactly what changed in upstream between two syncs.

The snapshot does not run. It is not the app. It is the diff surface and the LLM context.

### `scripts/sync-upstream.sh` (entry point)

Bash script. Idempotent. The single command to invoke when upstream has new commits.

```bash
#!/usr/bin/env bash
# sync-upstream.sh — pulls upstream realworld-angular into
#   realworld-angular/         (gitignored, throwaway clone, runnable)
#   realworld-angular-snapshot/ (tracked mirror, for diff/LLM analysis)
#
# Idempotent. Safe to re-run.

set -euo pipefail

REPO_URL="https://github.com/realworld-angular/realworld-angular"
CLONE_DIR="realworld-angular"
SNAPSHOT_DIR="realworld-angular-snapshot"

echo "[sync-upstream] wiping previous clone and snapshot..."
rm -rf "$CLONE_DIR" "$SNAPSHOT_DIR"

echo "[sync-upstream] cloning upstream (depth=1)..."
git clone --depth=1 "$REPO_URL" "$CLONE_DIR"

echo "[sync-upstream] syncing snapshot (excluding node_modules, dist, .angular)..."
mkdir -p "$SNAPSHOT_DIR"
if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='.angular' \
    "$CLONE_DIR"/ "$SNAPSHOT_DIR"/
else
  echo "[sync-upstream] rsync not found, falling back to cp -R + manual prune"
  cp -R "$CLONE_DIR"/. "$SNAPSHOT_DIR"/
  rm -rf "$SNAPSHOT_DIR/node_modules" "$SNAPSHOT_DIR/dist" "$SNAPSHOT_DIR/.angular"
fi

NEW_SHA=$(git -C "$CLONE_DIR" rev-parse HEAD)
echo
echo "[sync-upstream] done."
echo "  Upstream HEAD: $NEW_SHA"
echo
echo "Next steps:"
echo "  1. Update SYNC-NOTES.md 'Current pinned upstream SHA' to: $NEW_SHA"
echo "  2. Add a row to SYNC-NOTES.md 'Sync log' table."
echo "  3. Stage and commit the snapshot changes:"
echo "       git add realworld-angular-snapshot SYNC-NOTES.md"
echo "       git commit -m \"chore: sync upstream to \$NEW_SHA\""
echo "  4. Optional verification:"
echo "       cd $CLONE_DIR && pnpm install && pnpm run build"
```

**Script properties:**

- **Idempotent** — `rm -rf` at the top means re-running on top of a stale tree is safe.
- **Depth=1, no history** — full upstream history lives on GitHub. The snapshot commits themselves accumulate history in _this_ repo.
- **No commits inside the script** — the script stages nothing. The user (or an LLM agent) reviews the diff and writes a sync-commit message.
- **No automation of SYNC-NOTES.md updates** — those need a human/LLM-readable summary line.
- **rsync fallback** — rsync ships with Git for Windows so the fallback is mostly belt-and-suspenders, but it makes the script work on a fresh WSL or Linux checkout too.
- **Cross-platform-aware** — bash because git Bash is the convention in this sandbox (per SYNC-NOTES). No PowerShell version. If a future user needs Windows-native invocation, they can run it from a bash shell or via `bash scripts/sync-upstream.sh` from PowerShell.

## Top-level documentation

### CLAUDE.md — added section

Inserted at the top, before "Commit Policy":

```markdown
## Upstream source of truth

The Angular SPA in `realworld-angular/` is a throwaway clone of
[realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular).
The tracked mirror in `realworld-angular-snapshot/` is updated from
upstream on each sync via `scripts/sync-upstream.sh`.

**For offline analysis** (no network), read `realworld-angular-snapshot/`.
**For canonical/live state**, consult the GitHub repo.

When making changes to the app, prefer the upstream: consult the GitHub
repo for the canonical version, and only edit the local clone when
intentionally diverging. To pull in upstream updates, run
`scripts/sync-upstream.sh` (see SYNC-NOTES.md for the full workflow).
```

The existing "Commit Policy" and "Hooks" sections are preserved verbatim.

### SYNC-NOTES.md — full rewrite

Replaces the current document. New structure:

1. **Header** — what this document is, link to the upstream repo.
2. **Current sync model (as of 2026-06-05)** — describes the clone + snapshot model.
3. **How to sync** — invocation, what the script does, post-script steps.
4. **Post-sync verification** — table of commands and expected outcomes.
5. **Current pinned upstream SHA** — single line, updated on each sync.
6. **Sync log** — table of `{date, SHA, notes}`.
7. **Historical cherry-pick workflow (preserved for context)** — the 2026-06-03 and 2026-06-04 sessions, verbatim, as an appendix.

The "Current pinned upstream SHA" is initialized to `3322c2d498f82bb00fd0e56fd048a23288c95ce1` (the SHA pinned in the most recent sync entry in the old document).

### `docs/PROJECT-SUMMARY.md` (NEW)

A short top-level document so an LLM opening this repo cold understands the layout at a glance. Contents:

- One paragraph: what this sandbox is.
- Bulleted list of root-level items with one-line descriptions.
- A "where is the app" pointer.
- A "where is upstream" pointer.
- A "how to sync" pointer.

### `realworld-angular-snapshot/README.md` (NEW)

A one-line note inside the snapshot directory, to prevent confusion with the runnable clone:

```markdown
# realworld-angular-snapshot

Tracked mirror of [realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular)
main branch. Updated by `scripts/sync-upstream.sh` at the repo root.

**Not the running app.** For the runnable clone, see `../realworld-angular/`.
```

## `.gitignore` additions

Add the following block to `.gitignore` (placement: end of file is fine; do not delete existing rules):

```gitignore
# --- upstream clone (throwaway; re-cloned on every sync) ---
realworld-angular/
realworld-angular/node_modules/
realworld-angular/dist/
realworld-angular/.angular/
# End of upstream clone ignore block
```

**Why `realworld-angular/` is in the gitignore:** the script always `rm -rf`s and re-clones it. Tracking its contents would mean every sync commit touches a large number of paths, defeating the point of having the snapshot directory for tracked diffs. The clone is for running, the snapshot is for diffing.

**Why the inner excludes are also listed:** belt-and-suspenders. The clone ships with its own upstream `.gitignore` covering `node_modules/`, `dist/`, `.angular/`, but the additional explicit rules here mean that even if a future upstream change accidentally drops one of those from their `.gitignore`, our top-level ignore still catches it.

## Migration mechanics

The migration lands as **a single commit on the current working branch** (likely `sync/upstream-2026-06` at `859ac29`, depending on working tree state at implementation time).

### Pre-flight checks

1. `git status` — confirm the working tree state matches expectations. The 4 WIP items from the prior session should be present and accounted for:
   - `.claude/settings.local.json` (modified, in working tree)
   - `.claude/settings.json`, `README-TESTING.md`, `README-TEST-INSIGHTS.md` (3 untracked)
2. None of these are in the migration's delete list, so they will remain in the working tree after the migration commit lands.
3. The implementation plan should include a "verify branch state" step that pauses for the user if anything is unexpected.

### Commit steps

The steps below are ordered to avoid the chicken-and-egg of "run the script before it exists." The script is written first, then invoked.

1. **Write `scripts/sync-upstream.sh`** with the contents from the "Sync model → scripts/sync-upstream.sh" section above. Stage and (optionally) commit it alone first, so the script is available in the working tree as a tracked file before being invoked. **Decision point for the implementation plan: split here or not.** The simplest path is to write the script, invoke it, and let it be part of the single migration commit — git tracks the script's content from before the invocation, so `git add scripts/` after invocation captures the script exactly as it was run.
2. **Invoke `bash scripts/sync-upstream.sh`** to populate `realworld-angular/` (gitignored) and `realworld-angular-snapshot/` (tracked) with the current upstream tip (`3322c2d`). This produces many files in `realworld-angular-snapshot/`.
3. **Update `.gitignore`** with the new block from the `.gitignore additions` section above.
4. **Add `realworld-angular-snapshot/README.md`** (one-line note from the "Top-level documentation" section).
5. **Add `docs/PROJECT-SUMMARY.md`** at the top level with the contents specified in the "Top-level documentation" section.
6. **Update `CLAUDE.md`** with the new "Upstream source of truth" section.
7. **Rewrite `SYNC-NOTES.md`** with the new structure from the "Top-level documentation" section. The historical 2026-06-03 and 2026-06-04 sections are preserved verbatim in the appendix.
8. **Remove the root Angular files** listed in the "Files removed at root" section above.
9. **Stage everything and commit:**

   ```
   git add .gitignore CLAUDE.md SYNC-NOTES.md docs/ scripts/ realworld-angular-snapshot/
   git rm <the list of root files being removed>
   git commit -m "refactor: separate upstream realworld-angular into its own subdir

   - Clone upstream into gitignored realworld-angular/ (throwaway, re-cloned on sync)
   - Mirror upstream's app code into tracked realworld-angular-snapshot/
   - Remove root-level Angular files (now captured in snapshot)
   - Add scripts/sync-upstream.sh to make future syncs mechanical
   - Add upstream URL to CLAUDE.md as source of truth
   - Add docs/PROJECT-SUMMARY.md for top-level context
   - Rewrite SYNC-NOTES.md with the new workflow + historical appendix"
   ```

### Post-commit verification

1. `git status` — clean. `realworld-angular/` is untracked (gitignored). `realworld-angular-snapshot/` is tracked. Root has no `package.json` / `src/` / `angular.json` / etc.
2. `cd realworld-angular && pnpm install && pnpm run build` — exit 0.
3. `cd realworld-angular && pnpm run lint` — exit code matches upstream's current state (may be red; that is upstream's problem, not the migration's).
4. `cd realworld-angular && pnpm run test` — same.
5. `git log -p realworld-angular-snapshot/README.md` — shows the new file in the migration commit.
6. `cat SYNC-NOTES.md` — new structure, with the historical appendix at the bottom.
7. `cat CLAUDE.md` — has the new "Upstream source of truth" section at the top.

If any verification step fails, the implementation plan includes a "pause and diagnose" step rather than papering over with `--no-verify` or similar.

## Risk and reversibility

- **Risk:** The migration commit is large (one deletion of many files, one addition of many files). The diff is reviewable but not fun to read.
- **Reversibility:** `git revert <migration-commit-sha>` puts the tree back to the pre-migration state. `git reset --hard <parent-sha>` does the same. The historical cherry-pick sessions are preserved verbatim in `SYNC-NOTES.md`'s appendix.
- **Edge case:** If the user has local edits to any of the root Angular files that aren't already in a commit or stash, those edits will be deleted by `git rm`. The pre-flight check captures this. The user is expected to commit or stash such edits before the migration runs.
- **Edge case:** The 4 WIP files from the prior session (`.claude/settings.local.json` modified, 3 untracked) are not in the migration's delete list. They are untouched. The working tree at the end of the migration commit is the same as the working tree at the start, minus the deleted root Angular files and plus the new directories.

## Open questions for the implementation plan

The implementation plan (next step, via writing-plans skill) should resolve the following:

- **Exact ordering of the `git add` and `git rm` operations** to avoid stale-index issues on Windows. (Git on Windows can produce surprising results when `git rm` of a tracked file is interleaved with `git add` of a directory containing a new file with the same path; the plan should stage-then-rm or rm-then-stage in a single batch.)
- **Node version for verification install.** The 2026-06-04 sync notes record that the build requires Node 22.22.3+ and that the system default was v22.14.0. The implementer should verify the active node version before running `pnpm install && pnpm run build`, and use `nvm` or similar to switch if needed. If the version check is uncomfortable to do unattended, the plan should pause for the user.
- **The script's bash invocation on Windows.** `bash scripts/sync-upstream.sh` from PowerShell works because Git for Windows ships bash. From `cmd` it works for the same reason. The plan should pick one and document it.
- **Should the migration be a single commit or two?** The brainstorming explicitly chose single-commit, and the design assumes that. The implementer should not split unless they encounter a concrete blocker; if they do, they should pause and ask.
