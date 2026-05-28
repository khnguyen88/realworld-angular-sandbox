# Angular Agent Skills — Integration Design

## Summary

Add Angular's official agent skills (`angular-developer`, `angular-new-app`) to the Claude Code `.claude/skills/` directory so Claude can produce idiomatic Angular code with up-to-date Signals, forms, routing, and testing guidance.

## Context

- **Source**: `https://github.com/angular/skills` (official Angular team repo)
- **Current state**: `angular-developer` is already present in `.agents/skills/angular-developer/` (Gemini CLI format) with 36 reference files, tracked by `skills-lock.json`. `angular-new-app` is not installed.
- **Target**: Claude Code reads skills from `.claude/skills/<name>/SKILL.md`

## Approach

Copy `angular-developer` from the existing `.agents/` installation, fetch `angular-new-app` from source.

## Directory Structure

```
.claude/skills/
├── angular-developer/
│   ├── SKILL.md              (copied from .agents/skills/angular-developer/)
│   └── references/           (36 .md files, copied)
└── angular-new-app/
    └── SKILL.md              (fetched from angular/skills)
```

`angular-new-app` has no `references/` directory.

## Operations

1. Copy `.agents/skills/angular-developer/` → `.claude/skills/angular-developer/` recursively
2. Fetch `angular-new-app/SKILL.md` from `raw.githubusercontent.com/angular/skills/main/` into `.claude/skills/angular-new-app/SKILL.md`
3. Commit the new `.claude/skills/` directory

## Verification

- Confirm both `SKILL.md` files have valid YAML frontmatter (`name`, `description`)
- Confirm reference files in `angular-developer/references/` are intact (36 files)
- Run `ng build` as a sanity check (skills are documentation, no code impact expected)
