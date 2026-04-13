---
name: mymrflow-generate-changeset
description: Generate a changeset following defined rules
metadata:
  parent: mymrflow
---

# Steps

Generate a `.changeset/<sanitized-branch>.md` file for release changelogs
consumption. Sanitize the branch name by replacing `/` with `--` (e.g.
`fix/PROJ-1234-example` → `fix--PROJ-1234-example.md`).

1. **Determine affected apps** from `git diff --stat origin/<target>...HEAD`:
   - **IMPORTANT:** Ask the user using the `question` tool to confirm affected
     apps

2. **Summary:** Use the MR description to figure out what changed (one line,
   concise)

3. **Write the file:** `.changeset/<sanitized-branch>.md`
   ```markdown
   ---
   apps: [example-app]
   ---

   Fixed mobile view in landing page.
   ```
   Example: branch `fix/PROJ-1234-example` →
   `.changeset/fix--PROJ-1234-example.md`

4. **Skip changeset** if:
   - The MR only touches CI/infra (no app impact)
   - The MR is docs-only
   - No apps are affected

5. **Push the changeset.** Before pushing remember to `git add` and
   `git commit -m "chore: ..."`
