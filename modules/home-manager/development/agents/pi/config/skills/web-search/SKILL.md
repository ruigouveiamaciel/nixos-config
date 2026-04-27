---
name: web-search
description: Web search via self-hosted service. Aggregates 70+ engines (Google, Bing, DuckDuckGo, Wikipedia, GitHub, StackOverflow, ...). Use for documentation, facts, current events, or any web search.
---

# SearXNG

Self-hosted metasearch at `http://10.0.50.42:8888` (requires LAN/VPN). Returns a
stable JSON envelope — no markdown escaping or link-syntax ambiguity to deal
with.

## Requirements

The SearXNG instance must be reachable. Verify with:

```bash
curl -sfI http://10.0.50.42:8888/
```

If unreachable, ask the user to connect to the VPN or check the instance.
Override the URL with `SEARXNG_URL=http://other:8888`.

## Search

```bash
{baseDir}/search.sh "query"                             # Top 5 results (JSON)
{baseDir}/search.sh -n 10 "rust async traits"           # More results
{baseDir}/search.sh -c news -t week "ecb rates"         # Recent news
{baseDir}/search.sh -e google,wikipedia "query"         # Specific engines
{baseDir}/search.sh -f urls -n 3 "kubernetes operator"  # URLs only, one per line
```

Run `{baseDir}/search.sh --help` for full reference.

### Options

- `-n, --count N` - Number of results (default: 5)
- `-c, --category CAT` -
  `general|images|videos|news|science|it|files|music|map|"social media"`
- `-l, --language LANG` - `en|pt|de|all|...` (default: all)
- `-t, --time RANGE` - `day|week|month|year`
- `-e, --engines LIST` - Comma-separated engine names
- `-p, --page N` - Page number (default: 1)
- `-s, --safesearch 0|1|2` - default: 0
- `-f, --format FMT` - `json|urls` (default: json)

Quote the query if it contains shell metacharacters (`|`, `&`, `;`, `$`, `(`,
`)`, backticks) — otherwise the shell eats them before the script sees them.

## Output Envelope (json)

```json
{
  "query": "...",
  "instance": "http://...",
  "total_hits": 348000,
  "returned": 5,
  "answers": ["direct answer text", "..."],
  "infobox": { "title": "...", "content": "..." },
  "results": [
    {
      "n": 1,
      "title": "...",
      "url": "https://...",
      "engine": "google",
      "published_date": "2024-01-15T00:00:00Z",
      "snippet": "..."
    }
  ],
  "suggestions": ["...", "..."],
  "unresponsive_engines": ["...", "..."],
  "warnings": []
}
```

All top-level fields are always present. Missing per-result data
(`published_date`, `snippet`, `infobox`) is `null`, not absent. `snippet` is
whitespace-collapsed and capped at 1024 chars with a trailing `…` when
truncated. `answers` is always a plain `string[]` — object-valued answers (e.g.
DuckDuckGo) are flattened to the `answer` text.

## Examples

```bash
# Top result URL only
{baseDir}/search.sh "nixos impermanence" | jq -r '.results[0].url'

# Titles + URLs, one per line
{baseDir}/search.sh -n 5 "rust async traits" \
  | jq -r '.results[] | "\(.n). \(.title)\n   \(.url)"'

# Instant answers (if any)
{baseDir}/search.sh "define serendipity" | jq -r '.answers[]?'

# Search + fetch top result
URL=$({baseDir}/search.sh -f urls -n 1 "nixos-anywhere tutorial")
curl -sL "$URL" | lynx -stdin -dump -nolist -width=120
```

## Gotchas

- Empty results still exit 0. Check `.warnings` for
  `"no results, answers, or infobox returned"` before telling the user you found
  something.
- `.unresponsive_engines` being non-empty is harmless when `.returned > 0`.
  `karmasearch` is chronically flaky.
- Exit code 1 = network/parse error; exit 2 = usage error.

## When Not to Use

- The SearXNG instance is unreachable (off-LAN, no VPN).
- Tasks requiring interactive browsing, JS execution, or logged-in sessions.
