---
description: Stage and commit all changes and report the message
---

Stage all pending changes (including untracked files) and commit them.

1. Run `git status` and `git diff HEAD` to understand the changes.
2. Write the commit message using conventional commits: `type(scope): subject`.
   Infer the type and subject from the changes. Pick a sensible scope; if
   unsure, check the old commit history to see which scopes this repo uses.
   Optionally add a short body explaining the *why*.
3. No attribution, co-author, or "Generated with" footers.
4. Commit with the message and report the resulting hash and message.
