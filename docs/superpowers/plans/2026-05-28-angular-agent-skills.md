# Angular Agent Skills Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `angular-developer` and `angular-new-app` skills to `.claude/skills/` so Claude Code produces idiomatic Angular code.

**Architecture:** Copy the existing `angular-developer` skill from `.agents/skills/` (already installed in Gemini CLI format) into `.claude/skills/`, fetch `angular-new-app` from the upstream `angular/skills` repo. Both use Claude Code's native `SKILL.md` format.

**Tech Stack:** No code changes — file copy + HTTP fetch operations.

---

### Task 1: Create target directory and copy angular-developer skill

**Files:**

- Create: `.claude/skills/angular-developer/SKILL.md`
- Create: `.claude/skills/angular-developer/references/*.md` (35 files)

- [ ] **Step 1: Create target directory structure**

```bash
mkdir -p .claude/skills/angular-developer
```

- [ ] **Step 2: Copy SKILL.md**

```bash
cp .agents/skills/angular-developer/SKILL.md .claude/skills/angular-developer/SKILL.md
```

- [ ] **Step 3: Copy references directory recursively**

```bash
cp -r .agents/skills/angular-developer/references .claude/skills/angular-developer/references
```

- [ ] **Step 4: Verify the copy — file counts match**

```bash
echo "Source SKILL.md:" && ls -la .agents/skills/angular-developer/SKILL.md
echo "Target SKILL.md:" && ls -la .claude/skills/angular-developer/SKILL.md
echo "Source refs count:" && ls .agents/skills/angular-developer/references/ | wc -l
echo "Target refs count:" && ls .claude/skills/angular-developer/references/ | wc -l
```

Expected: Both counts are 35, both SKILL.md files exist.

### Task 2: Fetch angular-new-app skill from upstream

**Files:**

- Create: `.claude/skills/angular-new-app/SKILL.md`

- [ ] **Step 1: Create target directory**

```bash
mkdir -p .claude/skills/angular-new-app
```

- [ ] **Step 2: Fetch SKILL.md from angular/skills repo**

```bash
curl -sS -o .claude/skills/angular-new-app/SKILL.md \
  https://raw.githubusercontent.com/angular/skills/main/angular-new-app/SKILL.md
```

- [ ] **Step 3: Verify the fetched file has valid YAML frontmatter**

```bash
head -6 .claude/skills/angular-new-app/SKILL.md
```

Expected: Shows `---`, `name: angular-new-app`, `description: ...`, `---`.

### Task 3: Verify and commit

**Files:**

- Create: `.claude/skills/angular-developer/*` (all files)
- Create: `.claude/skills/angular-new-app/SKILL.md`

- [ ] **Step 1: Verify angular-developer SKILL.md frontmatter**

```bash
head -6 .claude/skills/angular-developer/SKILL.md
```

Expected: Shows `---`, `name: angular-developer`, `description: Generates Angular code...`, `---`.

- [ ] **Step 2: Verify complete directory structure**

```bash
echo "=== Skills tree ===" && find .claude/skills -type f | sort
```

Expected: 37 files (2 SKILL.md + 35 references).

- [ ] **Step 3: Run ng build as sanity check (no code impact expected)**

```bash
npx ng build
```

Expected: Build succeeds (skills are documentation, no code changes).

- [ ] **Step 4: Stage and commit**

```bash
git add .claude/skills/
git commit -m "feat: add Angular agent skills (angular-developer, angular-new-app) to .claude/skills"
```
