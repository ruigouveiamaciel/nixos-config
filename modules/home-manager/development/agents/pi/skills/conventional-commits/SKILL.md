---
name: conventional-commits
description: Create git commits following Conventional Commits. Splits changes into logical intermediate commits, stages selectively, and writes clear messages. Use when committing work or asked to commit.
---

# Conventional Commits

## Format

```
<type>(scope): <description>

[body]

[BREAKING CHANGE: ...]
```

**Types:** `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`

## Workflow

1. **Inspect** — `git status` and `git diff --stat` to understand all changes
2. **Plan commits** — group changes into logical units, split by:
   - feature vs refactor vs fix
   - unrelated areas (backend/frontend, module boundaries)
   - tests vs production code
   - formatting vs logic
3. **For each commit:**
   - Stage selectively: `git add <paths>` or `git add -p` for mixed files
   - Verify staged diff: `git diff --cached`
   - Commit: `git commit -m "type(scope): description"`
4. **Repeat** until working tree is clean

## Rules

- One logical change per commit
- Imperative mood, present tense: "add" not "added"
- Subject line under 72 characters
- Add body only when the *why* isn't obvious
- Never stage with `git add .` or `git add -A`
- Never commit secrets, debug code, or unrelated formatting
- Append `!` after type/scope for breaking changes: `feat!: remove v1 api`
