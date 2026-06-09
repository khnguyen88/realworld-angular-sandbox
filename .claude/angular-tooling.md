# Angular Tooling

## MCP Server

The Angular CLI MCP server is configured in `.mcp.json` (`angular-cli`).
It runs `@angular/cli` MCP in read-only mode and provides:

- `list_projects` — discover workspaces, projects, and targets (mandatory first step)
- `get_best_practices` — load version-specific Angular coding standards
- `search_documentation` — query angular.dev for API/concept docs
- `find_examples` — curated database of official, best-practice code examples
- `ai_tutor` — interactive Angular tutorial persona (guided curriculum, not one-off Q&A)
- `onpush_zoneless_migration` — step-by-step OnPush/zoneless migration analysis

Always call `list_projects` first, then `get_best_practices` before writing
Angular code.

## Skills

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

## General Angular questions

When the user asks conceptual Angular questions
(e.g. "what is TestBed?", "how does HttpTestingController work?"):

| Question type                     | Tool to use                                                            |
| --------------------------------- | ---------------------------------------------------------------------- |
| "What is X?" / "How does Y work?" | `search_documentation` — official angular.dev docs                     |
| "Show me an example of Z"         | `find_examples` — curated best-practice code samples                   |
| "What's the right pattern for W?" | `get_best_practices` — coding standards, then skill references         |
| "Teach me Angular from scratch"   | `ai_tutor` — interactive step-by-step curriculum                       |
| One-off conceptual question       | Do NOT use `ai_tutor` — it launches a full tutorial, not a Q&A session |

Also check `angular-developer` skill references for supplementary guidance.
Prefer the official source over general knowledge.
