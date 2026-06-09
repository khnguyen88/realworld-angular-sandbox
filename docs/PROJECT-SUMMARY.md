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

In `realworld-angular/`. To work with it: `cd realworld-angular && pnpm install --trust-lockfile`.

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
