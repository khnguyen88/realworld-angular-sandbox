# Upstream Sync 2026-06-04 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replay the 6 upstream commits made since 2026-06-03 (`8fa08a5` → `3322c2d`) onto `sync/upstream-2026-06` and document the result in `SYNC-NOTES.md`.

**Architecture:** `git cherry-pick` per commit, in-place on `sync/upstream-2026-06`. WIP stashed and restored around the loop. Conflicts pause for user input. After the loop, append a new section to `SYNC-NOTES.md`, run verification commands, and commit the doc update.

**Tech Stack:** Git 2.x, pnpm 11.3.0, Node 22.22.3 (via PATH override), Angular CLI 22.

**Spec:** `docs/superpowers/specs/2026-06-04-upstream-sync-design.md`

---

## Task 1: Pre-flight verification

**Files:** None (read-only checks)

- [ ] **Step 1: Confirm starting commit and upstream tip**

Run from `C:\_AAA\JVR\realworld-angular-sandbox`:

```bash
git rev-parse HEAD
git rev-parse upstream/main
git log --oneline upstream/main..HEAD
```

Expected:

- HEAD = `a6244bb45b6a06e22ebf04d448b90c51c0f0d397`
- upstream/main = `3322c2d498f82bb00fd0e56fd048a23288c95ce1`
- `git log --oneline upstream/main..HEAD` shows the 6 sandbox-only commits from 2026-06-03 sync (a6244bb at top, 36f5b5b at bottom of that range), no upstream commits ahead.

- [ ] **Step 2: Confirm working tree contains only known WIP**

```bash
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

- [ ] **Step 3: Confirm upstream has the 6 expected new commits**

```bash
git log --oneline f3f1700b3be39ed2152d72a2027a0febbb8b7bc8..upstream/main
```

Expected (6 commits, oldest first):

```
8fa08a5 feat: add footer placeholder and defer loading for footer component
ecd87f8 feat: add debounce to coupon code validation in checkout wizard
d5a7229 fix: handle discount reset on coupon validation error
059e7fc fix: improve error handling in login and registration forms
bba14ca feat: add sync icon SVG to public icons directory
3322c2d feat: enhance coupon code functionality in checkout review step
```

- [ ] **Step 4: No commit — proceed to Task 2**

Pre-flight is read-only. Continue to the stash step.

---

## Task 2: Stash working-tree WIP

**Files:** None (stash operation)

- [ ] **Step 1: Stash the 4 WIP files**

```bash
git stash push -u -m "wip-pre-sync-2026-06-04" -- .claude/settings.local.json .claude/settings.json README-TESTING.md README-TEST-INSIGHTS.md
```

Expected: `Saved working tree and index state WIP on sync/upstream-2026-06: ...`

- [ ] **Step 2: Verify clean tree**

```bash
git status --porcelain
```

Expected: empty output. If anything remains, STOP and inspect.

- [ ] **Step 3: Verify stash exists with the WIP**

```bash
git stash list
```

Expected: a single entry containing the message `wip-pre-sync-2026-06-04`.

- [ ] **Step 4: No commit — proceed to Task 3**

---

## Task 3: Cherry-pick loop — commits 1 through 3

**Files:** Modified by cherry-pick: `src/app/...` (footer, coupon code, coupon validation). Specific paths unknown until picks run; report any conflicts that surface.

- [ ] **Step 1: Cherry-pick `8fa08a5` (footer placeholder + defer)**

```bash
git cherry-pick 8fa08a5
```

Expected: clean pick, no conflicts. Output ends with `[sync/upstream-2026-06 <new-sha>] feat: add footer placeholder and defer loading for footer component`.

If conflict occurs: STOP. Run `git status` and `git diff --name-only --diff-filter=U` to identify conflicted files. Report to user and ask for resolution (--ours / --theirs / manual / abort). Do not auto-resolve.

- [ ] **Step 2: Cherry-pick `ecd87f8` (coupon code debounce)**

```bash
git cherry-pick ecd87f8
```

Expected: clean pick. Same pause-on-conflict behavior.

- [ ] **Step 3: Cherry-pick `d5a7229` (discount reset on validation error)**

```bash
git cherry-pick d5a7229
```

Expected: clean pick. Same pause-on-conflict behavior.

- [ ] **Step 4: Verify three new commits on the branch**

```bash
git log --oneline -4
```

Expected: top 4 commits are (newest first) the docs commit `4452f93` from the design spec, then `8fa08a5`, `ecd87f8`, `d5a7229`. The order of the 3 cherry-picks (oldest first in chronological terms) is `d5a7229`, `ecd87f8`, `8fa08a5` from bottom to top.

- [ ] **Step 5: No commit — proceed to Task 4**

(Each `git cherry-pick` automatically creates one commit per replayed commit. No explicit `git commit` step needed between picks.)

---

## Task 4: Cherry-pick loop — commits 4 through 6

**Files:** Modified by cherry-pick: `src/app/...` (error handling, sync icon, coupon review step).

- [ ] **Step 1: Cherry-pick `059e7fc` (improve error handling in login/registration)**

```bash
git cherry-pick 059e7fc
```

Expected: clean pick.

- [ ] **Step 2: Cherry-pick `bba14ca` (add sync icon SVG)**

```bash
git cherry-pick bba14ca
```

Expected: clean pick. Path modified: `public/icons/sync.svg` (verify with `git show --stat HEAD` if curious).

- [ ] **Step 3: Cherry-pick `3322c2d` (enhance coupon code functionality)**

```bash
git cherry-pick 3322c2d
```

Expected: clean pick.

- [ ] **Step 4: Verify all 6 cherry-picks are present**

```bash
git log --oneline a6244bb..HEAD
```

Expected output (6 lines, newest first):

```
3322c2d feat: enhance coupon code functionality in checkout review step
bba14ca feat: add sync icon SVG to public icons directory
059e7fc fix: improve error handling in login and registration forms
d5a7229 fix: handle discount reset on coupon validation error
ecd87f8 feat: add debounce to coupon code validation in checkout wizard
8fa08a5 feat: add footer placeholder and defer loading for footer component
```

- [ ] **Step 5: Verify sandbox content is unchanged**

```bash
git diff a6244bb..HEAD -- .claude/ docs/superpowers/specs/
```

Expected: empty output. The 6 cherry-picks should not touch `.claude/` or the spec files (the only spec file change was the design commit at `4452f93`, which is _not_ in the range `a6244bb..HEAD` — wait, it is. Re-check: range is from `a6244bb` (parent of `4452f93`) to HEAD. So this command will show the design spec file as added. Adjust expectation:

The design spec file `docs/superpowers/specs/2026-06-04-upstream-sync-design.md` will appear as added in this range — that is expected. Everything else under `.claude/` and `docs/superpowers/specs/` should be unchanged.

To verify only the cherry-picks didn't touch sandbox content, run:

```bash
git diff a6244bb~1..HEAD -- .claude/ docs/superpowers/specs/
```

Expected: empty output. The 6 cherry-picks + 1 docs commit should not modify any existing tracked file under `.claude/` or `docs/superpowers/specs/`.

- [ ] **Step 6: Pause for user review before continuing**

STOP here. Report the 6 successful cherry-picks and the clean sandbox-content check to the user. Do not proceed to restore the WIP or run verification until the user confirms the cherry-pick loop looks right.

---

## Task 5: Restore the WIP stash

**Files:** Restored: `.claude/settings.local.json` (modified), `.claude/settings.json`, `README-TESTING.md`, `README-TEST-INSIGHTS.md` (untracked)

- [ ] **Step 1: Pop the stash**

```bash
git stash pop
```

Expected: output reports that the 4 files are restored. No conflicts expected (the WIP was on top of `a6244bb`; the cherry-picks don't touch any of those files).

If a conflict appears, STOP — the cherry-picks unexpectedly touched a WIP-tracked file. Report to user.

- [ ] **Step 2: Verify the 4 WIP files are back**

```bash
git status --porcelain
```

Expected (4 lines, same as Task 1 Step 2):

```
 M .claude/settings.local.json
?? .claude/settings.json
?? README-TEST-INSIGHTS.md
?? README-TESTING.md
```

Plus one of:

- No other changes (cherry-picks touched only their own files)
- Or: the cherry-picks also show as unstaged/untracked (would only happen if they didn't `git add` properly — but cherry-pick does)

If 6 cherry-pick commits appear as "unstaged" or anything is unexpected, STOP and inspect with `git status` and `git log --oneline a6244bb..HEAD`.

- [ ] **Step 3: Verify stash is empty**

```bash
git stash list
```

Expected: empty output.

- [ ] **Step 4: No commit — proceed to Task 6**

---

## Task 6: Run verification commands (install + build + lint + test)

**Files:** None (read-only checks against the post-cherry-pick tree)

- [ ] **Step 1: Set Node 22.22.3 on PATH for this session**

```bash
export PATH="/c/Users/khngu/AppData/Roaming/nvm/v22.22.3:$PATH"
node --version
```

Expected: `v22.22.3` (or `v22.22.x` for the same minor). If different, STOP and verify nvm directory.

- [ ] **Step 2: Install dependencies (allow recent-published packages)**

```bash
pnpm install --trust-lockfile
```

Expected: exit 0. Output may note `Lockfile is up to date` since the cherry-picks don't touch `pnpm-lock.yaml`. If lockfile changed unexpectedly, STOP and inspect.

- [ ] **Step 3: Run the production build**

```bash
pnpm run build
```

Expected: exit 0. Build output reports bundle size and may include CSS-budget warnings (those are non-fatal, same as the prior sync). Note any new warnings in the SYNC-NOTES update.

If exit is non-zero, STOP. The cherry-picks may have introduced a build error. Inspect with `pnpm run build 2>&1 | tail -50`.

- [ ] **Step 4: Run the linter and capture the error count**

```bash
pnpm run lint 2>&1 | tee /tmp/lint-2026-06-04.txt | tail -5
echo "---"
echo "Exit: $?"
grep -c "error" /tmp/lint-2026-06-04.txt || true
```

Expected: exit 1, ≥19 errors. The number may be ≥25 because the 6 new commits could have introduced additional lint warnings (or fixed some). Document the actual count in SYNC-NOTES, not the expected count.

- [ ] **Step 5: Run the test suite and capture the error count**

```bash
pnpm run test 2>&1 | tee /tmp/test-2026-06-04.txt | tail -5
echo "---"
echo "Exit: $?"
grep -cE "TS[0-9]{4}" /tmp/test-2026-06-04.txt || true
```

Expected: exit 1, ≥19 TypeScript errors. The actual count and which files fail may differ from the pre-sync state because the 6 new commits touched checkout/coupon code (which has the test-failure hot spots).

If test output reveals a new error pattern that wasn't in the prior 19 (e.g., a new `TS2xxx` or `TS5xxx` not related to guard-arity or coupon discount), note it in SYNC-NOTES for the separate test-fix spec.

- [ ] **Step 6: No commit — proceed to Task 7**

---

## Task 7: Update SYNC-NOTES.md and commit

**Files:**

- Modify: `SYNC-NOTES.md` (append new 2026-06-04 section after the existing 2026-06-03 section)

- [ ] **Step 1: Read the current end of `SYNC-NOTES.md` to find the insertion point**

```bash
wc -l SYNC-NOTES.md
tail -5 SYNC-NOTES.md
```

Note the last line number — the new section will be appended at the end of the file (after line 58, which is the last content line of the 2026-06-03 section).

- [ ] **Step 2: Append the new section using `cat >>` with a here-document**

```bash
cat >> SYNC-NOTES.md <<'EOF'

## Upstream Sync Notes — 2026-06-04

**Previous sync tip:** f3f1700b3be39ed2152d72a2027a0febbb8b7bc8
**New upstream tip:** 3322c2d498f82bb00fd0e56fd048a23288c95ce1
**Feature branch:** `sync/upstream-2026-06`
**Strategy:** Cherry-pick, in-place, pause on conflict (same as 2026-06-03 sync)
**Pre-sync WIP:** `.claude/settings.local.json` (modified) + 3 untracked files, stashed and restored.

### Cherry-pick outcome

| Commit | Subject                                                                                       | Conflicts | Resolution |
| ------ | --------------------------------------------------------------------------------------------- | --------- | ---------- |
| `8fa08a5` | feat: add footer placeholder and defer loading for footer component                       | None      | Clean.     |
| `ecd87f8` | feat: add debounce to coupon code validation in checkout wizard                           | None      | Clean.     |
| `d5a7229` | fix: handle discount reset on coupon validation error                                     | None      | Clean.     |
| `059e7fc` | fix: improve error handling in login and registration forms                               | None      | Clean.     |
| `bba14ca` | feat: add sync icon SVG to public icons directory                                         | None      | Clean.     |
| `3322c2d` | feat: enhance coupon code functionality in checkout review step                           | None      | Clean.     |

### Per-file overrides

None. No `.claude/*` files conflicted because the 6 upstream commits do not touch sandbox paths.

### Verification

| Command          | Exit | Notes |
| ---------------- | ---- | ----- |
| `pnpm install`   | _fill_ | Run with `--trust-lockfile`. Lockfile up to date (cherry-picks did not modify dependency tree). |
| `pnpm run build` | _fill_ | Built successfully. _note bundle size, CSS warnings, etc._ |
| `pnpm run lint`  | _fill_ | _N_ errors. _list any new lint regressions vs. the 2026-06-03 baseline of 19, if relevant._ |
| `pnpm run test`  | _fill_ | _N_ TypeScript errors. _list the failing files and any new error patterns._ |

### Post-sync test red (not fixed by this sync)

The 19 pre-existing errors documented in the 2026-06-03 section above may have shifted:
some may now be eclipsed by new errors introduced by the 6 cherry-picks, and some
upstream-side errors may have been resolved. _Document the actual delta from the
prior baseline, not the prior baseline itself._

### Strategy notes

Same as 2026-06-03. No worktree used. No squash. The 6 cherry-picks remain
individual atomic commits for revertability.
EOF
```

**Replace `_fill_` placeholders with the actual exit codes and notes captured in Task 6** before committing. If you prefer to commit SYNC-NOTES with placeholders and amend later, that's also acceptable — but it's cleaner to fill them in first.

- [ ] **Step 3: Verify the appended section looks right**

```bash
tail -45 SYNC-NOTES.md
```

Expected: 45 new lines appended after the existing 58. No `_fill_` placeholders should remain.

- [ ] **Step 4: Stage and commit the doc update**

```bash
git add SYNC-NOTES.md
git status
git diff --cached --stat
git commit -m "docs: update sync notes for 2026-06-04 upstream cherry-pick"
```

Expected: one file changed (`SYNC-NOTES.md`), one new commit. Husky pre-commit will run prettier and lint-staged — both should pass on the markdown file. If husky fails, fix the issue and create a new commit (do not amend).

- [ ] **Step 5: Final state check**

```bash
git log --oneline upstream/main..HEAD
git status --porcelain
```

Expected:

- `git log` shows 7 commits (6 cherry-picks + 1 SYNC-NOTES update), in chronological order with the SYNC-NOTES commit at HEAD
- `git status` shows the 4 WIP files (untracked + 1 modified), no other changes

- [ ] **Step 6: Done**

The sync is complete. Report to user: 6 cherry-picks replayed, 1 doc commit added, branch tip at `3322c2d + SYNC-NOTES`. Test/build/lint state captured in `SYNC-NOTES.md`. No push performed (out of scope, blocked on `gh auth login`).

---

## Rollback reference

If something goes wrong mid-plan:

- **Single pick conflict:** resolve per spec section "Conflict handling" — abort / --ours / --theirs / manual.
- **Whole loop disaster, before SYNC-NOTES commit:**
  ```bash
  git reset --hard a6244bb
  git stash pop
  ```
  Returns the branch to the pre-sync state and restores the WIP.
- **After SYNC-NOTES commit but before push:**
  ```bash
  git reset --hard a6244bb  # drops the 6 cherry-picks + 1 doc commit
  git stash pop
  ```
- **Stash lost somehow:** the WIP was stashed in Task 2 and the stash should still be in the reflog for 30 days. Recovery: `git fsck --unreachable | grep commit` or `git log --walk-reflogs --oneline stash@{0}`.
