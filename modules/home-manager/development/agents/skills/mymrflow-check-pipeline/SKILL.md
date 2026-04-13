---
name: mymrflow-check-pipeline
description: Check GitLab pipeline status and unresolved review comments for the current merge request
metadata:
  parent: mymrflow
---

# Steps

## Step 1 — Check pipeline status

Check pipeline status using:

```bash
glab mr view --output="json" | jq '.pipeline'
```

Report the current pipeline status based on the output.

If pipeline is **null** or still **running**, ask the user using the `question`
tool if they want to check the pipeline again.

## Step 2 — Check for unresolved comments

Check all unresolved review comments using:

```bash
glab mr view --comments --output="json" | jq '.Notes[] | select(.resolvable == true and .resolved == false)'
```

Display any unresolved review comments based on the output.

If there are **no unresolved comments**, check if any resolvable comments were
made. If none, `question` the user if we should wait another 5 minutes.

```bash
glab mr view --comments --output="json" | jq '.Notes[] | select(.resolvable == true)'
```

## Step 3 — Output report summary

- Current pipeline status
- List of all unresolved review comments (if any)
- **IMPORTANT:** If there are any unresolved issues, ask the user using the
  `question` tool before attempting to fix them
