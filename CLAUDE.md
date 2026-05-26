# CLAUDE.md

## Commit Policy

Never include AI attribution in commit messages. Do not add `Co-Authored-By:`, `Signed-off-by:`, or any similar AI/assistant credit lines — whether the commit is created manually, triggered by superpowers skills, or initiated by any other automation.

## Hooks

Memory compiler hooks are configured in `.claude/settings.local.json`:

- **SessionStart** — injects knowledge base index into new sessions via `memory-compiler/hooks/session-start.py`
- **PreCompact** — captures context before auto-compaction via `memory-compiler/hooks/pre-compact.py`
- **SessionEnd** — captures transcript and spawns background flush via `memory-compiler/hooks/session-end.py`

All hook scripts resolve paths relative to their own location (`__file__`), so they function correctly regardless of working directory. The `memory-compiler/` directory is gitignored and treated as read-only third-party code.
