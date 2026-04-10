---
name: mymrflow
description: Create a GitLab merge request.
license: MIT
metadata:
  workflow: gitlab-mr
---

# description

Orchestrate the entire GitLab merge request workflow.

**IMPORTANT:** Do not commit any unstaged stages! If in doubt question the user
using the `question` tool.

## Steps

1. Push current branch to remote.
2. run skil({ name: "mymrflow-generate-description" })
3. Create merge request using `glab mr create`. If a merge request already
   exists, update it instead.
4. run skil({ name: "mymrflow-generate-changeset" })
5. Sleep for 300 seconds before proceeding to give enough time for the pipeline
   to finish
6. run skil({ name: "mymrflow-check-pipeline" })
