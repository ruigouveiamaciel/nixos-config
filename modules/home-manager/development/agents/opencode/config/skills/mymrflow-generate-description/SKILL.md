---
name: mymrflow-generate-description
description: Generate concise MR description
---

# Steps

1. Identify JIRA ticket ID from:
   - Current branch name (e.g., `feature/PROJ-123-description`)
   - Recent commit messages
   - Look for patterns like `PROJ-[0-9]+`

2. If a JIRA ticket is found:
   - **IMPORTANT:** Verify that JIRA/Atlassian MCP is available and `question`
     the user if it isn't
   - Fetch the ticket details using the Atlassian API
   - Extract: title, description, acceptance criteria, linked issues

3. Analyze the commit history

4. Generate MR description including:
   - **What**: Brief summary of changes (from JIRA title + commit messages)
   - **Why**: Context from JIRA ticket description and acceptance criteria
   - **How**: Key implementation details from commits
   - **Related Issue**: Link to JIRA ticket if found

5. Generate MR title using conventional commits including:
   - **scope**: The main scope of this merge request
   - **JIRA tikcet**: The associated JIRA ticket if any exists
   - example: feat(app): PROJ-1233 Added new feature to landing page

Format as clean Markdown suitable for GitLab MR description.
