---
description: Stage and commit all changes as a single commit
---

Stage all pending changes — both unstaged modifications and untracked
files — and commit them.

Everything must go into exactly ONE commit — do not split the changes
into multiple commits, even if they look logically unrelated.

1. Run `git status`, `git diff HEAD`, and `git ls-files --others
   --exclude-standard` (for untracked files) to understand the changes.
2. Write the commit message using conventional commits: `type(scope): subject`.
   Infer the type and subject from the changes. Pick a sensible scope; if
   unsure, check the old commit history to see which scopes this repo uses.
   Optionally add a short body explaining the *why*.
3. No attribution, co-author, or "Generated with" footers.
4. Commit everything as a single commit with the message and report the
   resulting hash and message. Verify afterwards that the working tree is
   clean and only one new commit was created.
