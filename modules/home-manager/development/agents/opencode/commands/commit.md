---
description: Create a conventional commit for staged changes
model: anthropic/claude-haiku-4-5
agent: commit
---

Review the staged changes and create a conventional commit.

Git status:
!`git status --short`

Staged changes:
!`git diff --staged`

Based on the changes above, write a conventional commit message in the format `type(scope): description`.
- Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build
- Keep the subject line under 72 characters
- Add a concise body only if the changes are complex

Then run `git commit -m "<message>"` to create the commit.
