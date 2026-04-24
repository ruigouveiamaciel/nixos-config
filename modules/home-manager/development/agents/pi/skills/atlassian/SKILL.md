---
name: atlassian
description: Atlassian Cloud CLI for Jira issue lookups, JQL/CQL searches, comments, transitions, and Confluence page reads. Uses the official Rovo MCP server.
---

# Atlassian

Command-line access to Atlassian Cloud (Jira, Confluence, JSM, Compass) through
the official Rovo MCP server, via `mcporter` and OAuth 2.1.

## Setup

First check if already authenticated:

```bash
{baseDir}/atlassian.sh status
```

If `unauthenticated`, run `{baseDir}/atlassian.sh auth` — it opens a browser on
Atlassian's consent page asking the user to authenticate.

## Usage

Run `{baseDir}/atlassian.sh help` for full command reference.

Common operations:

- `{baseDir}/atlassian.sh status` - Report auth state; exit 0=authed,
  1=unauthed, 2=unknown
- `{baseDir}/atlassian.sh tools` - List all tools (JSON with name, description,
  inputSchema)
- `{baseDir}/atlassian.sh schema <tool>` - Print schema for one tool
- `{baseDir}/atlassian.sh call <tool> key=value ...` - Invoke with simple args
- `{baseDir}/atlassian.sh call <tool> --args '{...}'` - Invoke with JSON args

Tool names are camelCase and case-sensitive. Discover them with `tools` before
calling — don't guess.

## Jira

Most Jira tools require a `cloudId`. Fetch once per session:

```bash
CID=$({baseDir}/atlassian.sh call getAccessibleAtlassianResources | jq -r '.[0].id')
```

Example — current user's open issues:

```bash
{baseDir}/atlassian.sh call searchJiraIssuesUsingJql --args "$(jq -nc --arg c "$CID" '{
  cloudId: $c,
  jql: "assignee = currentUser() AND resolution = Unresolved ORDER BY updated DESC",
  fields: ["summary","status","priority"],
  limit: 20
}')" | jq '.issues[] | {key, summary: .fields.summary, status: .fields.status.name}'
```

## Gotchas

- Paginate via `limit` + cursor; check `.nextCursor` / `.isLast` before assuming
  you got everything.
- Confluence bodies are ADF (nested JSON, not Markdown). Use
  `jq '.. | .text? // empty'` for plain text, or ask the tool for a rendered
  variant if offered.
- Jira custom fields arrive as `customfield_XXXXX`; schemas don't name them.
  Fetch one issue to learn the IDs per site.
- Rate limits are per-user — prefer bulk JQL/CQL over N+1 loops.
- Scope = the OAuth user. Projects the user can't see return empty or 403.
- Multi-site accounts: mcporter picks the default site. To target another,
  append `?site=foo.atlassian.net` to `baseUrl` in `{baseDir}/mcporter.json` and
  re-run `auth`.

## When Not to Use

- Truly headless environments with no browser available for the one-time auth.
