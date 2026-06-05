# Upstream Sync — 2026-06-04

Replays the 6 upstream commits that landed since the 2026-06-03 sync onto `sync/upstream-2026-06`. Cherry-pick, in-place, pause on conflict. Test red is out of scope.

## Context

- **Upstream:** https://github.com/realworld-angular/realworld-angular
- **Last sync tip:** `f3f1700` (Angular 22.0 deps update, synced 2026-06-03)
- **New upstream tip:** `3322c2d` (enhance coupon code functionality in checkout review step)
- **Local branch tip:** `a6244bb` (sync notes for 2026-06-03 cherry-pick)
- **Working tree:** 1 modified file (`.claude/settings.local.json`) + 3 untracked files (`.claude/settings.json`, `README-TESTING.md`, `README-TEST-INSIGHTS.md`)

The prior sync used `git cherry-pick` rather than rebase because the local snapshot has no common ancestor with upstream. This sync uses the same strategy.

## Commits to replay (6, in order)

| #   | SHA       | Subject                                                             |
| --- | --------- | ------------------------------------------------------------------- |
| 1   | `8fa08a5` | feat: add footer placeholder and defer loading for footer component |
| 2   | `ecd87f8` | feat: add debounce to coupon code validation in checkout wizard     |
| 3   | `d5a7229` | fix: handle discount reset on coupon validation error               |
| 4   | `059e7fc` | fix: improve error handling in login and registration forms         |
| 5   | `bba14ca` | feat: add sync icon SVG to public icons directory                   |
| 6   | `3322c2d` | feat: enhance coupon code functionality in checkout review step     |

All are feature/fix commits. None touch `.claude/*` or `docs/superpowers/*` (sandbox-only paths). Low conflict risk.

## Strategy

Cherry-pick, in-place, pause on conflict. Mirrors the 2026-06-03 sync's approach (see `SYNC-NOTES.md`).

**Why not rebase:** No common ancestor. The snapshot root (`a1eb73e`) and upstream root are unrelated.

**Why not fast-forward merge:** The 47 sandbox-only files (CLAUDE.md, `.claude/skills/`, docs, etc.) are not in upstream; fast-forward would discard them.

**Why not squash at end:** Per-commit granularity is more useful for future reverts and matches the prior sync's history style.

## Procedure

1. **Pre-flight.** Verify:
   - `git rev-parse HEAD` is `a6244bb`
   - `git rev-parse upstream/main` is `3322c2d`
   - Working tree only contains the 4 known WIP files
2. **Stash WIP.** `git stash push -u -m "wip-pre-sync-2026-06-04"`. Verify clean.
3. **Cherry-pick loop.** For each of the 6 commits in order:
   - `git cherry-pick <sha>` (no flags)
   - If clean: continue to next
   - If conflict: STOP, show diff stat, ask user for resolution
   - If empty diff: `git cherry-pick --skip`, log it
4. **Restore WIP.** `git stash pop`. Verify the 4 WIP files are back.
5. **Verify state.** `git log --oneline upstream/main..HEAD` shows 6 commits in the right order.
6. **Document.** Append a new section to `SYNC-NOTES.md` (under the existing 2026-06-03 block):
   - List of 6 commits and conflict outcomes
   - Verification table (build, lint, test, install)
7. **Verification commands** (all run with Node 22.22.3 via PATH override):
   - `pnpm install` (with `--trust-lockfile` per SYNC-NOTES.md precedent)
   - `pnpm run build` — expect exit 0
   - `pnpm run lint` — capture exit code + error count (expected: 1, ≥19 errors)
   - `pnpm run test` — capture exit code + error count (expected: 1, ≥19 errors)
8. **Commit doc update.** `docs: update sync notes for 2026-06-04 upstream cherry-pick`

## Conflict handling

When `git cherry-pick` reports a conflict:

1. Run `git status` and `git diff --name-only --diff-filter=U`
2. Show the user the conflict summary (file + first 30 lines of conflict markers)
3. Ask: (a) `--abort` the cherry-pick, (b) `--ours` for the file, (c) `--theirs` for the file, (d) manual resolution
4. Wait for explicit choice. Do not auto-resolve.

**Special case for `.claude/settings.local.json`:** If it re-conflicts (as it did twice in the prior sync), the safe default is to restore from `main:.claude/settings.local.json` — that file is sandbox cumulative state, not part of upstream history. But still pause and ask, because the user might want to inspect.

## Rollback

If something goes wrong mid-loop:

- `git cherry-pick --abort` — reverts the in-flight pick (working tree to clean)
- `git reset --hard a6244bb` — drops all 6 picks, returns to pre-sync state
- `git stash pop` — restores the WIP (still in the stash, untouched)

These three commands are the escape hatch. No commits have been created during the cherry-pick loop, so rollback is always lossless until step 8.

## Verification

| Command                                 | Pass criterion                                                         |
| --------------------------------------- | ---------------------------------------------------------------------- |
| `git log --oneline upstream/main..HEAD` | Shows 6 commits, oldest → newest matches the table                     |
| `git log --oneline -1`                  | HEAD is the docs commit from step 8                                    |
| `git diff --stat a6244bb..HEAD`         | Upstream changes + SYNC-NOTES, no sandbox churn                        |
| `git diff a6244bb..HEAD -- .claude/`    | Tracked `.claude/` content matches `main:.claude/` (sandbox unchanged) |
| `pnpm install`                          | Exit 0 (with `--trust-lockfile`)                                       |
| `pnpm run build`                        | Exit 0                                                                 |
| `pnpm run lint`                         | Document exit + count; expected red                                    |
| `pnpm run test`                         | Document exit + count; expected red                                    |

## Out of scope (explicit)

- Fixing the 19 pre-existing test errors (`TS2554` guard-arity, `TS2339` coupon discount) + 14 lint errors — separate spec
- Updating `README-TEST-INSIGHTS.md` — that's pre-sync state; regeneration is part of the test-fix spec
- Pushing the branch or opening a PR — blocked on `gh auth login` from prior session
- Squashing the 6 picks — left as 6 atomic commits for revertability

## Documentation update

A new section appended to `SYNC-NOTES.md`:

```
## Upstream Sync Notes — 2026-06-04

**Previous sync tip:** f3f1700
**New upstream tip:** 3322c2d
**Commits replayed:** 6 (8fa08a5 → 3322c2d)
**Strategy:** Cherry-pick (in-place, pause on conflict)

[...table: SHA, subject, conflicts encountered, resolution...]
[...verification table: command, exit, notes...]
```

## Pause points

- After cherry-pick loop (step 5) — confirm clean replay before documenting
- After lint/test (step 7) — confirm red is acceptable before committing docs
