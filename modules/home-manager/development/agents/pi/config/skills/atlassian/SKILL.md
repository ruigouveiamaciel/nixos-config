---
name: atlassian
description: Atlassian Cloud CLI for Jira issue lookups, JQL/CQL searches, comments, transitions, and Confluence page reads. Uses the official MCP server.
---

# Atlassian

Command-line access to Atlassian Cloud (Jira, Confluence, JSM, Compass) through
the official MCP server.

## Setup

```bash
{baseDir}/atlassian.sh status
```

`status` is the single auth entry point: if no tokens are cached it opens the
browser for OAuth consent, then re-probes. Safe to run repeatedly. Exit 0 =
authenticated, 1 = unauthenticated (after a failed flow), 2 = unknown (network,
etc.).

## Usage

Run `{baseDir}/atlassian.sh help` for full command reference.

Commands:

- `{baseDir}/atlassian.sh status` — auth probe + interactive bootstrap.
- `{baseDir}/atlassian.sh tools` — list all tools (JSON with name, description,
  inputSchema).
- `{baseDir}/atlassian.sh schema <tool>` — print the tool object (incl.
  `inputSchema`) for one tool.
- `{baseDir}/atlassian.sh call <tool>` — invoke a tool. **Arguments must be
  piped as a single JSON object on stdin** (no `key=value`, no `--args`). For
  no-arg tools, pipe `jq -n '{}'`. The script validates the input against the
  tool's `inputSchema` (via `jsonschema-cli`) before calling and exits 2 with a
  list of violations on mismatch.

Tool names are camelCase and case-sensitive. Discover them with `tools` before
calling — don't guess.

## Jira

Most Jira tools require a `cloudId`. Fetch once per session:

```bash
CID=$(jq -n '{}' \
  | {baseDir}/atlassian.sh call getAccessibleAtlassianResources \
  | jq -r '.[0].id')
```

Example — current user's open issues:

```bash
jq -nc --arg c "$CID" '{
  cloudId: $c,
  jql: "assignee = currentUser() AND resolution = Unresolved ORDER BY updated DESC",
  fields: ["summary","status","priority"]
}' \
  | {baseDir}/atlassian.sh call searchJiraIssuesUsingJql \
  | jq '.issues[] | {key, summary: .fields.summary, status: .fields.status.name}'
```

Fetch a single issue:

```bash
jq -nc --arg c "$CID" '{cloudId: $c, issueIdOrKey: "PROJ-123"}' \
  | {baseDir}/atlassian.sh call getJiraIssue
```
