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

1. /caveman ultra
2. Push current branch to remote.
3. run skil({ name: "mymrflow-generate-description" })
4. Create merge request using `glab mr create`. If a merge request already
   exists, update it instead.
5. run skil({ name: "mymrflow-generate-changeset" })
6. Sleep for 300 seconds before proceeding to give enough time for the pipeline
   to finish
7. run skil({ name: "mymrflow-check-pipeline" })
