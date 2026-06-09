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

## Angular Tooling

See `.claude/angular-tooling.md` for the full MCP server, skills, and
question-routing reference. Key rules:

- Call `list_projects` first, then `get_best_practices` before writing Angular code.
- Invoke `angular-developer` skill for any Angular coding task.
- For conceptual questions, use `search_documentation` / `find_examples` /
  `get_best_practices` (not `ai_tutor` — that's for full tutorials).
