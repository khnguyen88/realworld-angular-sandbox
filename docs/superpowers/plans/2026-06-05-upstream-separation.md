# Upstream Separation 2026-06-05 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the sandbox so the upstream Angular SPA lives in a gitignored `realworld-angular/` subdirectory (re-cloned on every sync via `scripts/sync-upstream.sh`), and the top level becomes a clean sandbox narrative (CLAUDE.md, SYNC-NOTES.md, docs/PROJECT-SUMMARY.md, .claude/ tooling).

**Architecture:** One migration commit on `sync/upstream-2026-06`. The commit: writes `scripts/sync-upstream.sh`, runs it to populate `realworld-angular/`, updates `.gitignore` to ignore it, removes the root-level Angular files (now redundant with the clone), adds `docs/PROJECT-SUMMARY.md`, prepends an "Upstream source of truth" section to `CLAUDE.md`, and rewrites `SYNC-NOTES.md` with the new workflow + historical appendix.

**Tech Stack:** Git 2.39 (Windows), bash 5.2 (Git Bash), Node 22.22.3, pnpm 11.3, `git clone --depth=1`, `cp -R` (no rsync in this environment).

**Spec:** `docs/superpowers/specs/2026-06-05-upstream-separation-design.md`

---

## File structure (this plan touches / creates / removes)

**Created (new tracked files):**

- `scripts/sync-upstream.sh` — the sync entry point.
- `docs/PROJECT-SUMMARY.md` — top-level "what is this sandbox" doc.

**Modified (existing tracked files):**

- `.gitignore` — add block to ignore `realworld-angular/` and its generated subdirs.
- `CLAUDE.md` — prepend "Upstream source of truth" section.
- `SYNC-NOTES.md` — full rewrite, new workflow + historical appendix.

**Removed (existing tracked files, deleted from root):**

- `angular.json`
- `tsconfig.app.json`, `tsconfig.json`, `tsconfig.spec.json`
- `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`
- `eslint.config.js`
- `src/` (directory), `public/` (directory)
- `.editorconfig`
- `.prettierrc`, `.prettierrc.json`, `.prettierignore`
- `.husky/` (directory), `.vscode/` (directory), `.github/` (directory), `.agents/` (directory)
- `skills-lock.json`

**Left untouched (generated / not tracked):**

- `.angular/`, `dist/`, `node_modules/` (already untracked; gitignore will catch any future creation)
- `.claude/`, `memory-compiler/`, `docs/` (sandbox-owned; kept)

**Generated (gitignored, ephemeral):**

- `realworld-angular/` — the only copy of the app, produced by the sync script.

---

## Task 1: Pre-flight verification

**Files:** None (read-only checks)

- [ ] **Step 1: Confirm working tree contains only known WIP**

```bash
cd C:\_AAA\JVR\realworld-angular-sandbox
git status --porcelain
```

Expected output (4 lines, exact):

```
 M .claude/settings.local.json
?? .claude/settings.json
?? README-TEST-INSIGHTS.md
?? README-TESTING.md
```

If there are any other modified or untracked files, STOP and ask the user what to do with them.

- [ ] **Step 2: Confirm branch and tip**

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline -3
```

Expected:

- Branch: `sync/upstream-2026-06`
- Top 3 commits (newest first): `829b0e9` (spec update), `261b76f` (spec collapse), `23f46ab` (spec add) — i.e. the 3 commits that landed during brainstorming. The branch tip before this plan runs is `829b0e9`.

- [ ] **Step 3: Confirm tools**

```bash
bash --version | head -1
node --version
git --version
```

Expected:

- bash ≥ 5.x
- Node `v22.22.3` or higher (the upstream's `package.json` requires Node 22.12+; the build path needs 22.22.3+)
- git ≥ 2.x

If Node is not 22.22.3+, the verification build in Task 7 will not work. Set it with `nvm use 22.22.3` or the appropriate path export. If the right Node is not installed, STOP and ask the user.

- [ ] **Step 4: Confirm no `realworld-angular/` already exists**

```bash
ls -la realworld-angular 2>/dev/null && echo "EXISTS" || echo "absent"
```

Expected: `absent`. If the directory exists from a prior attempt, the migration is already in progress or was reverted; ask the user before deleting.

- [ ] **Step 5: No commit — proceed to Task 2**

---

## Task 2: Write the sync script

**Files:**

- Create: `scripts/sync-upstream.sh`

- [ ] **Step 1: Create the `scripts/` directory**

```bash
mkdir -p scripts
```

- [ ] **Step 2: Write the script file**

Create `scripts/sync-upstream.sh` with this exact content:

```bash
#!/usr/bin/env bash
# sync-upstream.sh — pulls upstream realworld-angular into realworld-angular/
# (the only copy of the app, gitignored, re-cloned on every run).
#
# Idempotent. Safe to re-run.

set -euo pipefail

REPO_URL="https://github.com/realworld-angular/realworld-angular"
CLONE_DIR="realworld-angular"

echo "[sync-upstream] wiping previous clone..."
rm -rf "$CLONE_DIR"

echo "[sync-upstream] cloning upstream (depth=1)..."
git clone --depth=1 "$REPO_URL" "$CLONE_DIR"

NEW_SHA=$(git -C "$CLONE_DIR" rev-parse HEAD)
echo
echo "[sync-upstream] done."
echo "  Upstream HEAD: $NEW_SHA"
echo
echo "Next steps:"
echo "  1. Update SYNC-NOTES.md 'Current pinned upstream SHA' to: $NEW_SHA"
echo "  2. Add a row to SYNC-NOTES.md 'Sync log' table."
echo "  3. Optional verification:"
echo "       cd $CLONE_DIR && pnpm install && pnpm run build"
```

- [ ] **Step 3: Verify the file was created with the right content**

```bash
ls -la scripts/sync-upstream.sh
head -3 scripts/sync-upstream.sh
wc -l scripts/sync-upstream.sh
```

Expected:

- File exists.
- First 3 lines are the shebang, then two comment lines.
- Line count is 27.

- [ ] **Step 4: No commit — proceed to Task 3**

(The script will be part of the single migration commit at the end. No need to commit it standalone.)

---

## Task 3: Run the sync script to populate `realworld-angular/`

**Files:** Created (gitignored): `realworld-angular/` (full upstream tree from `3322c2d`)

- [ ] **Step 1: Run the script from a bash shell**

```bash
cd C:\_AAA\JVR\realworld-angular-sandbox
bash scripts/sync-upstream.sh
```

Expected:

- `[sync-upstream] wiping previous clone...`
- `[sync-upstream] cloning upstream (depth=1)...` followed by git output
- `[sync-upstream] done.`
- `  Upstream HEAD: 3322c2d498f82bb00fd0e56fd048a23288c95ce1`
- (Some `warning: redirecting to` lines from Git on Windows are normal during `git clone` output — ignore them.)

If the script fails (e.g., network error, permission denied), STOP. Do not proceed; the rest of the migration assumes the clone succeeded.

- [ ] **Step 2: Verify the clone is in place**

```bash
ls -la realworld-angular | head -15
cat realworld-angular/package.json | grep '"name"'
```

Expected:

- `realworld-angular/` directory exists.
- `package.json` shows `"name": "realworld-angular"`.

- [ ] **Step 3: Verify the clone is gitignored (not yet, but will be — confirm the absence of the gitignore block)**

```bash
grep -c "realworld-angular/" .gitignore
```

Expected: `0` (the gitignore block is added in Task 4; right now the directory will appear as untracked but that's expected).

```bash
git status --porcelain | head -20
git status --porcelain | wc -l
```

Expected: a `?? realworld-angular/` entry in the untracked list (git reports untracked directories as a single line, not recursively — `--untracked-files=all` would still report 1 entry for the directory). The clone contains ~364 files. This is fine and expected — Task 4 will add the gitignore.

- [ ] **Step 4: No commit — proceed to Task 4**

---

## Task 4: Update `.gitignore`

**Files:**

- Modify: `.gitignore` (append a block at the end)

- [ ] **Step 1: Read the current end of `.gitignore`**

```bash
tail -10 .gitignore
```

Note the last line number / last line text. The new block will be appended after the last existing line.

- [ ] **Step 2: Append the new block**

```bash
cat >> .gitignore <<'EOF'

# --- upstream clone (throwaway; re-cloned on every sync) ---
realworld-angular/
realworld-angular/node_modules/
realworld-angular/dist/
realworld-angular/.angular/
# End of upstream clone ignore block
EOF
```

- [ ] **Step 3: Verify the block is in place and `realworld-angular/` is now ignored**

```bash
tail -10 .gitignore
git check-ignore -v realworld-angular realworld-angular/package.json realworld-angular/node_modules/foo
```

Expected:

- `.gitignore` ends with the new block (4 ignore lines + 2 comment lines = 6 lines added).
- `git check-ignore` prints a match for each path with the matching line from `.gitignore` (e.g., `realworld-angular/	.gitignore:N	realworld-angular/` where N is the line number of the matching rule).

- [ ] **Step 4: Verify the working tree no longer lists `realworld-angular/` files as untracked**

```bash
git status --porcelain | head -10
git status --porcelain | wc -l
```

Expected: working tree count drops back to the original 4 WIP items (`.claude/settings.local.json` modified + 3 untracked). The `realworld-angular/*` lines should no longer appear.

If the count is still high, the gitignore block is wrong — re-check the syntax and the `git check-ignore` output.

- [ ] **Step 5: No commit — proceed to Task 5**

---

## Task 5: Create `docs/PROJECT-SUMMARY.md`

**Files:**

- Create: `docs/PROJECT-SUMMARY.md`

- [ ] **Step 1: Write the file**

Create `docs/PROJECT-SUMMARY.md` with this exact content:

```markdown
# Project Summary

This is a sandbox for working with the
[realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular)
Angular SPA. The sandbox separates two concerns:

- **The app** (the upstream Angular project) lives in a gitignored
  subdirectory `realworld-angular/`. It is re-cloned from scratch on
  every sync via `scripts/sync-upstream.sh` at the repo root.
- **The sandbox layer** (everything else in this repo) is user-owned
  and version-controlled: it contains tooling, docs, hooks, and the
  sync record. The app is not part of the sandbox's git history.

## Layout

- `CLAUDE.md` — entry point for LLM agents and humans. Includes the
  upstream source-of-truth pointer.
- `SYNC-NOTES.md` — sync log, current upstream SHA, and historical
  cherry-pick sessions (preserved as an appendix).
- `docs/` — sandbox-owned documentation, specs, and plans
  (including this file).
- `docs/superpowers/specs/` — design specs.
- `docs/superpowers/plans/` — implementation plans.
- `docs/diagrams/` — architecture diagrams.
- `.claude/` — Claude Code hooks, skills, and settings.
- `memory-compiler/` — third-party tooling that powers the hooks
  (gitignored, treated as read-only).
- `realworld-angular/` — the only copy of the app (gitignored).
  Not the runnable app's history; see the GitHub URL for that.
- `scripts/sync-upstream.sh` — the sync entry point.

## Where is the app

In `realworld-angular/`. To work with it: `cd realworld-angular && pnpm install`.

## Where is the upstream

[realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular).
For the currently-pinned upstream tip, see `SYNC-NOTES.md`.

## How to sync
```

bash scripts/sync-upstream.sh

```

The script wipes and re-clones `realworld-angular/`, then prints the
new upstream SHA. Update `SYNC-NOTES.md` (pinned SHA + sync log row)
and commit.

For all commit history of the app source, refer to the GitHub URL.
The local `git log` only records sandbox-side history.
```

- [ ] **Step 2: Verify the file is in place**

```bash
ls -la docs/PROJECT-SUMMARY.md
head -10 docs/PROJECT-SUMMARY.md
```

Expected: file exists, header line is `# Project Summary`.

- [ ] **Step 3: No commit — proceed to Task 6**

---

## Task 6: Update `CLAUDE.md`

**Files:**

- Modify: `CLAUDE.md` (prepend new section, preserve existing content)

- [ ] **Step 1: Read the current `CLAUDE.md`**

```bash
cat CLAUDE.md
```

Confirm the current top is `# CLAUDE.md` and the existing sections are "Commit Policy" and "Hooks".

- [ ] **Step 2: Write the new `CLAUDE.md`**

Replace the entire `CLAUDE.md` with this content (preserves the existing Commit Policy and Hooks sections verbatim):

```markdown
# CLAUDE.md

## Upstream source of truth

The Angular SPA in `realworld-angular/` is a clone of
[realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular),
re-cloned from scratch on each sync via `scripts/sync-upstream.sh`. The
directory is gitignored — it is the only copy of the app and is rebuilt
mechanically; its state is not versioned in this repo.

**For all commit history of the app source**, refer to
[https://github.com/realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular).
The local `git log` of this repo only records the _sandbox_ history
(sync commits, sandbox tooling, sandbox docs), not the app's history.

For the currently-pinned upstream tip, see `SYNC-NOTES.md`. For deep
analysis of any historical sync, the GitHub commit URL pinned in
`SYNC-NOTES.md` is the source of truth — fetch the upstream tree at
that SHA and read the files. LLM agents can do this on demand.

When making changes to the app, prefer the upstream: consult the GitHub
repo for the canonical version, and only edit the local clone when
intentionally diverging. To pull in upstream updates, run
`scripts/sync-upstream.sh` (see SYNC-NOTES.md for the full workflow).

## Commit Policy

Never include AI attribution in commit messages. Do not add `Co-Authored-By:`,
`Signed-off-by:`, or any similar AI/assistant credit lines — whether the
commit is created manually, triggered by superpowers skills, or initiated
by any other automation.

## Hooks

Memory compiler hooks are configured in `.claude/settings.local.json`:

- **SessionStart** — injects knowledge base index into new sessions via
  `memory-compiler/hooks/session-start.py`
- **PreCompact** — captures context before auto-compaction via
  `memory-compiler/hooks/pre-compact.py`
- **SessionEnd** — captures transcript and spawns background flush via
  `memory-compiler/hooks/session-end.py`

All hook scripts resolve paths relative to their own location (`__file__`),
so they function correctly regardless of working directory. The
`memory-compiler/` directory is gitignored and treated as read-only
third-party code.
```

- [ ] **Step 3: Verify the new CLAUDE.md**

```bash
head -20 CLAUDE.md
grep -c "Upstream source of truth" CLAUDE.md
grep -c "Commit Policy" CLAUDE.md
grep -c "Hooks" CLAUDE.md
```

Expected:

- First line is `# CLAUDE.md`.
- Second section is `## Upstream source of truth`.
- `Commit Policy` and `Hooks` sections both still present (count: 1 each).

- [ ] **Step 4: No commit — proceed to Task 7**

---

## Task 7: Rewrite `SYNC-NOTES.md`

**Files:**

- Modify: `SYNC-NOTES.md` (full rewrite — preserve the 2026-06-03 and 2026-06-04 sections verbatim as the historical appendix)

- [ ] **Step 1: Capture the existing 2026-06-03 and 2026-06-04 sections verbatim**

The existing file contains two sections that must be preserved verbatim in the rewrite: the 2026-06-03 sync notes and the 2026-06-04 sync notes. Locate them:

```bash
grep -n "^## Upstream Sync Notes" SYNC-NOTES.md
```

Expected: two matches, one for `## Upstream Sync Notes — 2026-06-03` and one for `## Upstream Sync Notes — 2026-06-04`. Note the line numbers — both sections (and everything from each `## Upstream Sync Notes` heading to the next `## Upstream Sync Notes` heading, or to EOF) must be preserved verbatim in the rewrite.

- [ ] **Step 2: Save the historical sections to a temp file**

```bash
# Find the start of the 2026-06-03 section
START=$(grep -n "^## Upstream Sync Notes — 2026-06-03" SYNC-NOTES.md | head -1 | cut -d: -f1)
# Save from that line to EOF
tail -n +"$START" SYNC-NOTES.md > /tmp/sync-notes-historical.md
wc -l /tmp/sync-notes-historical.md
head -3 /tmp/sync-notes-historical.md
tail -3 /tmp/sync-notes-historical.md
```

Expected:

- `/tmp/sync-notes-historical.md` has all the existing 2026-06-03 + 2026-06-04 content.
- It starts with `## Upstream Sync Notes — 2026-06-03` (after possible leading whitespace).
- It ends with the last line of the 2026-06-04 section.

- [ ] **Step 3: Write the new `SYNC-NOTES.md` (workflow part only)**

Write the new top portion of `SYNC-NOTES.md` (without the historical appendix — that gets appended in Step 5):

```bash
cat > SYNC-NOTES.md <<'EOF'
# Upstream Sync Notes

This document is the workflow reference for syncing the sandbox with
[realworld-angular/realworld-angular](https://github.com/realworld-angular/realworld-angular).

## Current sync model (as of 2026-06-05)

- `realworld-angular/` is a **throwaway clone** of upstream, gitignored.
  Re-cloned from scratch on every sync via `scripts/sync-upstream.sh`.
  It is the only copy of the app and is rebuilt mechanically; its
  state is not versioned in this repo.
- The local record of upstream state is this document (`SYNC-NOTES.md`,
  pinned SHA per sync) and the `git log` of sync commits in this repo.
  For deep analysis, the GitHub URL pinned here is the source of truth.

## How to sync

```

bash scripts/sync-upstream.sh

```

The script:

1. Wipes the previous `realworld-angular/` directory.
2. `git clone --depth=1 https://github.com/realworld-angular/realworld-angular realworld-angular`.
3. Prints the new upstream HEAD SHA.

Idempotent. Safe to re-run. The script does not commit anything — the
sync commit is the user's (or LLM agent's) responsibility.

## Post-sync steps

1. Update the "Current pinned upstream SHA" line below to the new SHA.
2. Add a row to the "Sync log" table.
3. (Optional) Verify the upstream still builds:
   `cd realworld-angular && pnpm install --trust-lockfile && pnpm run build`.
4. Commit the `SYNC-NOTES.md` change.

## Current pinned upstream SHA

`3322c2d498f82bb00fd0e56fd048a23288c95ce1`

## Sync log

| Date       | Upstream SHA                                  | Notes                                                                                          |
| ---------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 2026-06-05 | (this migration)                              | Workflow changed: from `git cherry-pick` to `git clone` + throwaway. See commit history.       |

## Historical cherry-pick workflow (preserved for context)

Before 2026-06-05, the sandbox synced via `git cherry-pick` directly into
the sandbox's main tree. The cherry-pick sessions of 2026-06-03 and
2026-06-04 are recorded verbatim below.

EOF
```

- [ ] **Step 4: Append the historical sections**

```bash
cat /tmp/sync-notes-historical.md >> SYNC-NOTES.md
```

- [ ] **Step 5: Verify the structure**

```bash
grep -n "^## " SYNC-NOTES.md
wc -l SYNC-NOTES.md
```

Expected section headers (in order):

```
## Current sync model (as of 2026-06-05)
## How to sync
## Post-sync steps
## Current pinned upstream SHA
## Sync log
## Historical cherry-pick workflow (preserved for context)
## Upstream Sync Notes — 2026-06-03
## Upstream Sync Notes — 2026-06-04
```

The last two (`## Upstream Sync Notes — 2026-06-03` and `## Upstream Sync Notes — 2026-06-04`) are the historical sections preserved verbatim.

- [ ] **Step 6: Sanity check — the historical content is byte-identical**

```bash
# Re-extract the historical portion from the new file and diff against the saved version.
NEW_HIST_START=$(grep -n "^## Upstream Sync Notes — 2026-06-03" SYNC-NOTES.md | head -1 | cut -d: -f1)
tail -n +"$NEW_HIST_START" SYNC-NOTES.md > /tmp/sync-notes-historical-new.md
diff /tmp/sync-notes-historical.md /tmp/sync-notes-historical-new.md
echo "---"
echo "Diff exit: $?"
```

Expected: diff produces no output; exit code 0. (Any diff means the historical content was modified — STOP and fix.)

- [ ] **Step 7: No commit — proceed to Task 8**

---

## Task 8: Remove the root-level Angular files

**Files:** Removed (tracked deletions): see the file list in the spec's "Files removed at root" section.

- [ ] **Step 1: List the files to be removed (sanity check)**

```bash
# Verify all expected files are currently present and tracked.
for f in angular.json \
         tsconfig.app.json tsconfig.json tsconfig.spec.json \
         package.json pnpm-lock.yaml pnpm-workspace.yaml \
         eslint.config.js \
         src public \
         .editorconfig \
         .prettierrc .prettierrc.json .prettierignore \
         .husky .vscode .github .agents \
         skills-lock.json; do
  if [ -e "$f" ]; then
    echo "EXISTS: $f"
  else
    echo "MISSING: $f"
  fi
done
```

Expected: every line says `EXISTS: ...`. If any say `MISSING`, the file is already gone or the name is wrong — STOP and inspect.

- [ ] **Step 2: Remove them with `git rm`**

```bash
cd C:\_AAA\JVR\realworld-angular-sandbox
git rm -r angular.json \
        tsconfig.app.json tsconfig.json tsconfig.spec.json \
        package.json pnpm-lock.yaml pnpm-workspace.yaml \
        eslint.config.js \
        src public \
        .editorconfig \
        .prettierrc .prettierrc.json .prettierignore \
        .husky .vscode .github .agents \
        skills-lock.json
```

Expected: git lists `rm '...'` for each path and reports a final summary like `rm '<path>'` lines. Exit code 0.

- [ ] **Step 3: Verify the staging area shows the deletions**

```bash
git status --short | head -30
git status --short | grep "^D " | wc -l
```

Expected: a block of `D  <path>` lines (one per file/directory removed). The count of `D ` lines should match the number of paths removed (≈19 lines counting directories as 1 line each).

- [ ] **Step 4: Verify the new files are also staged (additions) and the WIP is preserved**

```bash
git status --short | grep -E "^(A|M|\?\?)" | head -20
```

Expected: includes `A  scripts/sync-upstream.sh`, `M  CLAUDE.md`, `M  SYNC-NOTES.md`, `M  .gitignore`, `A  docs/PROJECT-SUMMARY.md`. The 4 WIP items should still appear as untracked or modified (not staged for this commit).

- [ ] **Step 5: No commit — proceed to Task 9**

---

## Task 9: Stage the new files and commit the migration

**Files:** Single migration commit on `sync/upstream-2026-06`.

- [ ] **Step 1: Stage the additions and modifications**

```bash
git add .gitignore CLAUDE.md SYNC-NOTES.md docs/ scripts/
git status --short | head -30
```

Expected: the previously-deletions (`D ` lines) and the new modifications/additions (`M `, `A ` lines) are all staged. The 4 WIP items remain untracked or modified (not staged).

- [ ] **Step 2: Final staged-status check**

```bash
git diff --cached --stat | tail -20
git status --porcelain
```

Expected:

- `git diff --cached --stat` shows a long list of changes: `D` lines for the removed files, `M` / `A` lines for the new content. Total file count should be roughly: 1 new script + 1 new doc + 3 modified existing + 19 deleted = ~24 changes.
- `git status --porcelain` shows the staged changes (no leading `??` or ` M` other than the 4 WIP items).

- [ ] **Step 3: Commit**

```bash
git commit -m "refactor: separate upstream realworld-angular into its own subdir

- Clone upstream into gitignored realworld-angular/ (re-cloned on sync)
- Remove root-level Angular files (recoverable from git history)
- Add scripts/sync-upstream.sh to make future syncs mechanical
- Add upstream URL to CLAUDE.md as source of truth
- Add docs/PROJECT-SUMMARY.md for top-level context
- Rewrite SYNC-NOTES.md with the new workflow + historical appendix"
```

Expected: husky pre-commit hooks run (prettier on the markdown file, lint-staged on staged JS). Output ends with a commit hash. Husky will likely emit a "DEPRECATED" warning about `.husky/pre-commit` shim lines — that's a pre-existing warning, not a failure.

If husky fails on the prettier step: read the error, fix the file content (it's likely a markdown formatting issue introduced in Tasks 5–7), re-stage, and re-commit. Do NOT use `--no-verify` — prettier formatting is intentional and matters for the project.

- [ ] **Step 4: Verify the commit landed**

```bash
git log --oneline -3
git show --stat HEAD | head -30
```

Expected:

- Top 3 commits: the new migration commit (head), then the spec update `829b0e9`, then `261b76f`.
- `git show --stat HEAD` lists the migration's changes: ~24 file changes (mix of `D`, `M`, `A`).

- [ ] **Step 5: No commit — proceed to Task 10**

---

## Task 10: Post-commit verification

**Files:** None (read-only checks against the post-migration tree)

- [ ] **Step 1: Working tree should be clean except for the 4 WIP items**

```bash
git status --porcelain
```

Expected (4 lines, exact):

```
 M .claude/settings.local.json
?? .claude/settings.json
?? README-TEST-INSIGHTS.md
?? README-TESTING.md
```

- [ ] **Step 2: Root has no Angular files**

```bash
ls -1 *.json *.yaml *.js 2>/dev/null
ls -1 src public 2>/dev/null && echo "STILL EXISTS" || echo "absent"
ls -1d .angular .husky .vscode .github .agents 2>/dev/null
```

Expected:

- No top-level `angular.json`, `package.json`, `tsconfig*.json`, `eslint.config.js`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`.
- `src` and `public` are absent.
- `.angular`, `.husky`, `.vscode`, `.github`, `.agents` are absent (the `ls -1d` returns nothing if all are absent).

- [ ] **Step 3: `realworld-angular/` exists and is gitignored**

```bash
ls -d realworld-angular
git check-ignore -v realworld-angular
cat realworld-angular/package.json | grep '"name"'
```

Expected:

- `realworld-angular` directory exists.
- `git check-ignore` prints a match (the gitignore is doing its job).
- `package.json` says `"name": "realworld-angular"`.

- [ ] **Step 4: `realworld-angular-snapshot/` does NOT exist (collapsed design)**

```bash
ls -d realworld-angular-snapshot 2>/dev/null && echo "EXISTS - WRONG" || echo "absent (correct)"
```

Expected: `absent (correct)`. If `EXISTS - WRONG` appears, the script was modified or an extra directory was created; STOP.

- [ ] **Step 5: Verify the upstream's build still works**

```bash
cd realworld-angular
pnpm install --trust-lockfile
pnpm run build
cd ..
```

Expected:

- `pnpm install` exits 0. (May print a warning about `--trust-lockfile`; the upstream's lockfile was published today per SYNC-NOTES, so pnpm's default supply-chain policy will reject it without the flag.)
- `pnpm run build` exits 0. Output reports bundle size and may include CSS-budget warnings (4 warnings expected, same as the 2026-06-04 sync notes).

If `pnpm install` fails: check Node version with `node --version` — must be 22.22.3+. If `pnpm run build` fails: STOP, the upstream is broken. Do not paper over; report to the user.

- [ ] **Step 6: Optional — confirm lint/test state matches upstream**

```bash
cd realworld-angular
pnpm run lint 2>&1 | tail -3
echo "lint exit: $?"
cd ..
pnpm run test 2>&1 | tail -3
echo "test exit: $?"
cd ..
```

Expected: both exit non-zero (the upstream's 19-test-red and 19-lint-error state is inherited; this is not a regression introduced by the migration). The exact counts should match the 2026-06-04 baseline if upstream hasn't changed since.

- [ ] **Step 7: Verify top-level docs**

```bash
head -3 CLAUDE.md
head -3 SYNC-NOTES.md
head -3 docs/PROJECT-SUMMARY.md
ls -la scripts/sync-upstream.sh
```

Expected:

- `CLAUDE.md` starts with `# CLAUDE.md` followed by `## Upstream source of truth`.
- `SYNC-NOTES.md` starts with `# Upstream Sync Notes`.
- `docs/PROJECT-SUMMARY.md` starts with `# Project Summary`.
- `scripts/sync-upstream.sh` exists.

- [ ] **Step 8: Done**

Report to user:

- 1 migration commit landed on `sync/upstream-2026-06` at `<new-sha>`.
- Upstream clone verified to build with `pnpm install --trust-lockfile && pnpm run build`.
- Working tree state: 4 pre-existing WIP items unchanged, no other modifications.
- Branch not pushed (out of scope, blocked on `gh auth login` from prior session).

---

## Rollback reference

If something goes wrong mid-plan:

- **Before the migration commit (between Task 2 and Task 9):**
  ```bash
  # Discard all uncommitted changes and untracked files
  git restore --staged --worktree .
  rm -rf realworld-angular scripts docs/PROJECT-SUMMARY.md
  # Then re-do pre-flight in Task 1
  ```
- **After the migration commit but before push:**

  ```bash
  git reset --hard 829b0e9   # back to the spec-update tip
  rm -rf realworld-angular
  ```

  Restores the branch to the pre-migration state.

- **Historical sections in SYNC-NOTES.md were accidentally modified:**
  The historical content was saved to `/tmp/sync-notes-historical.md` in Task 7 Step 2. Restore from that file:
  ```bash
  # Find the start of the 2026-06-03 section in the (possibly corrupted) file
  START=$(grep -n "^## Upstream Sync Notes — 2026-06-03" SYNC-NOTES.md | head -1 | cut -d: -f1)
  # Truncate the file before that line, then re-append the saved historical content
  head -n $((START-1)) SYNC-NOTES.md > /tmp/sync-notes-top.md
  cat /tmp/sync-notes-top.md /tmp/sync-notes-historical.md > SYNC-NOTES.md
  ```
