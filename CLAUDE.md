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

### MCP Server

The Angular CLI MCP server is configured in `.mcp.json` (`angular-cli`).
It runs `@angular/cli` MCP in read-only mode and provides:

- `list_projects` — discover workspaces, projects, and targets (mandatory first step)
- `get_best_practices` — load version-specific Angular coding standards
- `search_documentation` — query angular.dev for API/concept docs
- `ai_tutor` — interactive Angular tutorial persona
- `onpush_zoneless_migration` — step-by-step OnPush/zoneless migration analysis

Always call `list_projects` first, then `get_best_practices` before writing
Angular code.

### Skills

Angular ecosystem skills are installed from `angular/skills` (GitHub) and
tracked in `skills-lock.json`:

- **`angular-developer`** — full Angular development workflow: generate
  components/services/pipes/directives, manage dependencies, build, and test.
  Invoke for any Angular coding task.
- **`angular-new-app`** — scaffold a new Angular project with standalone
  components and modern best practices. Invoke for greenfield app creation.

Invoke these via the `Skill` tool before performing Angular work. The skills
are stored in `.claude/skills/angular-developer/` and
`.claude/skills/angular-new-app/`.
