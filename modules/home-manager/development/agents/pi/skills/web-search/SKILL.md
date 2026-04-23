---
name: web-search
description: Web search via a self-hosted SearXNG metasearch instance. Aggregates 70+ engines (Google, Bing, DuckDuckGo, Wikipedia, GitHub, StackOverflow, ...) with no API keys and no rate limits. Use for documentation, facts, current events, or any web search.
---

# SearXNG

Self-hosted metasearch at `http://10.0.50.42:8888` (LAN/VPN). Query the JSON API
directly with `curl` + `jq` — no auth, no installs.

## Search

```bash
# Basic search (5 results, clean fields)
curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=rust async traits" \
    --data-urlencode "format=json" \
  | jq '.results[:5] | .[] | {title, url, engine, content}'

# Human-readable output
curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=nixos impermanence" \
    --data-urlencode "format=json" \
  | jq -r '.results[:5] | to_entries[] |
      "--- Result \(.key + 1) ---\nTitle: \(.value.title)\nURL: \(.value.url)\nEngine: \(.value.engine)\nSnippet: \(.value.content)\n"'

# URLs only (for piping into curl/lynx)
curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=kubernetes operator" \
    --data-urlencode "format=json" \
  | jq -r '.results[:3] | .[].url'
```

## Parameters

Add any of these as additional `--data-urlencode` flags:

| Param        | Values                                                                                          | Default                  |
| ------------ | ----------------------------------------------------------------------------------------------- | ------------------------ |
| `q`          | query string                                                                                    | — (required)             |
| `format`     | `json`, `html`, `csv`, `rss`                                                                    | — (required, use `json`) |
| `categories` | `general`, `images`, `videos`, `news`, `science`, `it`, `files`, `music`, `map`, `social media` | `general`                |
| `language`   | `en`, `pt`, `de`, `all`, ...                                                                    | `all`                    |
| `time_range` | `day`, `week`, `month`, `year`                                                                  | —                        |
| `pageno`     | `1`, `2`, ...                                                                                   | `1`                      |
| `engines`    | comma-separated list (`google,wikipedia`)                                                       | all                      |
| `safesearch` | `0`, `1`, `2`                                                                                   | `0`                      |

## Filtered searches

```bash
# Recent news from the past week
curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=ecb interest rates" \
    --data-urlencode "format=json" \
    --data-urlencode "categories=news" \
    --data-urlencode "time_range=week" \
  | jq '.results[:5] | .[] | {title, url, publishedDate, content}'

# Restrict to a specific engine
curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=site-reliability engineering" \
    --data-urlencode "format=json" \
    --data-urlencode "engines=wikipedia" \
  | jq '.results[:3]'
```

## Instant answers & infoboxes

SearXNG returns Wikipedia summaries and direct answers when relevant:

```bash
curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=define serendipity" \
    --data-urlencode "format=json" \
  | jq -r '.answers[]?, (.infoboxes[]? | "\(.infobox)\n\(.content)")'
```

## Search + fetch in one shot

```bash
URL=$(curl -sfG "http://10.0.50.42:8888/search" \
    --data-urlencode "q=nixos-anywhere tutorial" \
    --data-urlencode "format=json" \
  | jq -r '.results[0].url')
curl -sL "$URL" | lynx -stdin -dump -nolist -width=120
```

## Output shape

```json
{
  "query": "...",
  "number_of_results": 348000,
  "results": [
    { "title": "...", "url": "...", "content": "snippet",
      "engine": "google", "score": 9.2,
      "publishedDate": "2024-01-15T00:00:00Z",
      "category": "general", "thumbnail": "...", "img_src": "..." }
  ],
  "infoboxes": [ { "infobox": "...", "content": "...", "urls": [...] } ],
  "answers": [ "instant answer text" ],
  "suggestions": [ "related query" ],
  "unresponsive_engines": [ ["engine_name", "reason"] ]
}
```

## Troubleshooting

- **Instance up?** `curl -sfI "http://10.0.50.42:8888/"`
- **HTML instead of JSON?** The `settings.yml` is missing
  `formats: [html, json]` — tell the user.
- **`unresponsive_engines` populated?** Harmless if `results` is non-empty;
  those engines failed but others succeeded.

## When to Use

- Searching for documentation or API references
- Looking up facts or current information
- Fetching content from specific URLs
- Any task requiring web search without interactive browsing
