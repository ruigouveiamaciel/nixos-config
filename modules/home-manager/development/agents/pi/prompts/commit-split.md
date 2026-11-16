---
description: Split unstaged and untracked work into multiple logical commits
---

Split the current unstaged and untracked work into multiple logical
commits instead of one big commit.

1. Run `git status` and `git diff` (plus `git ls-files --others
   --exclude-standard` for untracked files) to get a full picture of
   everything that is not yet committed. Ignore already-staged changes
   beyond noting they exist; do not amend or rewrite existing commits.
2. Group the changes into coherent units — e.g. by feature, module,
   or concern — so that each commit is self-contained and would still
   build/pass on its own whenever that is realistically checkable.
   Prefer more, smaller commits over one mixed bag, but do not create
   artificial splits within an obviously atomic change.
3. For each group in a sensible order (dependencies first), stage only
   the files/hunks belonging to it (`git add` with specific paths,
   `git add -p` for partial staging) and commit it.
4. Write each commit message using conventional commits:
   `type(scope): subject`. Infer the type and subject from that group's
   changes. Pick a sensible scope; if unsure, check the old commit
   history to see which scopes this repo uses. Optionally add a short
   body explaining the *why*.
5. No attribution, co-author, or "Generated with" footers.
6. When done, verify `git status` shows a clean working tree and report
   the list of new commits (hash + message) in the order they were
   created.
