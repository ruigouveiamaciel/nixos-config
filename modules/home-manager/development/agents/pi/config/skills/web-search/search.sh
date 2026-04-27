#!/usr/bin/env bash
# search.sh — Consistent SearXNG query wrapper.
#
# Outputs a small, stable JSON envelope so the consumer (an LLM, another
# script, or a human) gets the same shape every time and doesn't have to
# worry about markdown escaping, URL parens, prompt injection via styled
# text, etc. A `urls` mode is provided for pipeline use.

set -euo pipefail

INSTANCE_DEFAULT="http://10.0.50.42:8888"
SNIPPET_MAX=1024 # chars; clamp to keep context size bounded

usage() {
    cat <<'EOF'
Usage: search.sh [options] <query...>

Options:
  -n, --count N          Number of results to return (default: 5)
  -c, --category CAT     general|images|videos|news|science|it|files|
                         music|map|"social media"
  -l, --language LANG    e.g. en, pt, de, all  (default: all)
  -t, --time RANGE       day|week|month|year
  -e, --engines LIST     comma-separated engines (e.g. google,wikipedia)
  -p, --page N           Page number, >= 1 (default: 1)
  -s, --safesearch 0|1|2 (default: 0)
  -f, --format FMT       json|urls  (default: json)
  -h, --help

Environment:
  SEARXNG_URL            Instance URL (default: http://10.0.50.42:8888).
                         Trailing slash is stripped.

Output (json):
  {
    "query":        "<query>",
    "instance":     "<url>",
    "total_hits":   <int>,        // number_of_results reported by SearXNG
    "returned":     <int>,        // how many results in this response
    "answers":      ["text", ...],
    "infobox":      {"title": "...", "content": "..."} | null,
    "results": [
      {
        "n":              <int>,   // 1-based position
        "title":          "...",
        "url":            "...",
        "engine":         "google" | null,
        "published_date": "..." | null,
        "snippet":        "..." | null   // whitespace-collapsed, capped
      }
    ],
    "suggestions":          ["..."] ,
    "unresponsive_engines": ["name", ...],
    "warnings":             ["..."]    // e.g. "no results returned"
  }

Exit codes:
  0  success
  1  network / parse / runtime error
  2  usage error (bad flag, missing argument, invalid value)

Examples:
  search.sh rust async traits
  search.sh -n 10 -t week -c news "ecb interest rates"
  search.sh -f urls -n 3 "kubernetes operator"
  search.sh -f json "nixos impermanence" | jq '.results[0].url'
EOF
}

die() {
    echo "search.sh: $*" >&2
    exit 1
}
bad() {
    echo "search.sh: $*" >&2
    exit 2
}

# need_value FLAG "${2-}"
#   Verifies that the caller supplied a non-empty value after FLAG that
#   doesn't look like another option. Call with "${2-}" so that a
#   missing $2 becomes an empty string instead of tripping `set -u`.
need_value() {
    local flag="$1" value="${2-}"
    if [[ -z "$value" || "$value" == -* ]]; then
        bad "option $flag requires a value"
    fi
}

count=5
category=""
language=""
time_range=""
engines=""
pageno=""
safesearch=""
format="json"
query_parts=()

while [[ $# -gt 0 ]]; do
    case "$1" in
    -n | --count)
        need_value "$1" "${2-}"
        count="$2"
        shift 2
        ;;
    -c | --category)
        need_value "$1" "${2-}"
        category="$2"
        shift 2
        ;;
    -l | --language)
        need_value "$1" "${2-}"
        language="$2"
        shift 2
        ;;
    -t | --time)
        need_value "$1" "${2-}"
        time_range="$2"
        shift 2
        ;;
    -e | --engines)
        need_value "$1" "${2-}"
        engines="$2"
        shift 2
        ;;
    -p | --page)
        need_value "$1" "${2-}"
        pageno="$2"
        shift 2
        ;;
    -s | --safesearch)
        need_value "$1" "${2-}"
        safesearch="$2"
        shift 2
        ;;
    -f | --format)
        need_value "$1" "${2-}"
        format="$2"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --)
        shift
        query_parts+=("$@")
        break
        ;;
    -*) bad "unknown option: $1" ;;
    *)
        query_parts+=("$1")
        shift
        ;;
    esac
done

if [[ ${#query_parts[@]} -eq 0 ]]; then
    echo "search.sh: query required" >&2
    usage >&2
    exit 2
fi

# ---- Validation -----------------------------------------------------------

case "$format" in
json | urls) ;;
*) bad "invalid --format: $format (expected: json, urls)" ;;
esac

[[ "$count" =~ ^[0-9]+$ ]] || bad "--count must be a non-negative integer"

if [[ -n "$time_range" ]]; then
    case "$time_range" in
    day | week | month | year) ;;
    *) bad "invalid --time: $time_range (expected: day, week, month, year)" ;;
    esac
fi

if [[ -n "$safesearch" ]]; then
    case "$safesearch" in
    0 | 1 | 2) ;;
    *) bad "invalid --safesearch: $safesearch (expected: 0, 1, 2)" ;;
    esac
fi

if [[ -n "$pageno" ]]; then
    [[ "$pageno" =~ ^[1-9][0-9]*$ ]] || bad "--page must be a positive integer"
fi

for bin in curl jq; do
    command -v "$bin" >/dev/null 2>&1 || die "missing required binary: $bin"
done

# ---- Request --------------------------------------------------------------

# Strip trailing slash so `$INSTANCE/search` doesn't become `//search`.
INSTANCE="${SEARXNG_URL:-$INSTANCE_DEFAULT}"
INSTANCE="${INSTANCE%/}"

query="${query_parts[*]}"

args=(-sfG --max-time 30 "$INSTANCE/search"
    --data-urlencode "q=$query"
    --data-urlencode "format=json")

[[ -n "$category" ]] && args+=(--data-urlencode "categories=$category")
[[ -n "$language" ]] && args+=(--data-urlencode "language=$language")
[[ -n "$time_range" ]] && args+=(--data-urlencode "time_range=$time_range")
[[ -n "$engines" ]] && args+=(--data-urlencode "engines=$engines")
[[ -n "$pageno" ]] && args+=(--data-urlencode "pageno=$pageno")
[[ -n "$safesearch" ]] && args+=(--data-urlencode "safesearch=$safesearch")

if ! response=$(curl "${args[@]}" 2>/dev/null); then
    die "request to $INSTANCE failed (instance down, URL wrong, or VPN off?)"
fi

if ! jq -e . >/dev/null 2>&1 <<<"$response"; then
    echo "search.sh: SearXNG returned non-JSON. The instance likely needs" >&2
    echo "           'formats: [html, json]' in settings.yml." >&2
    exit 1
fi

# ---- Rendering ------------------------------------------------------------

case "$format" in
urls)
    jq -r --argjson n "$count" '(.results // [])[:$n] | .[].url' <<<"$response"
    ;;

json)
    # Everything below is pure data transformation: trim, normalize,
    # and reshape into a stable envelope. No markdown, no escaping
    # gymnastics — jq handles JSON string escaping for free.
    jq \
        --arg q "$query" \
        --arg instance "$INSTANCE" \
        --argjson n "$count" \
        --argjson snippet_max "$SNIPPET_MAX" \
        '
        # Collapse whitespace runs, trim, and clamp length.
        def clean_text:
            if . == null or . == "" then null
            else
                (gsub("\\s+"; " ") | sub("^ +"; "") | sub(" +$"; "")) as $s
                | if ($s | length) > $snippet_max
                    then ($s[:$snippet_max] + "…")
                    else $s
                  end
            end;

        # SearXNG returns answers as either strings or objects
        # (DuckDuckGo uses {url, engine, answer, ...}). Normalize to string.
        def render_answer:
            if type == "string" then .
            elif type == "object" then (.answer // .content // .text // (. | tojson))
            else (. | tojson)
            end;

        # Entries in .unresponsive_engines are usually ["name","reason"]
        # pairs but be defensive about other shapes.
        def engine_name:
            if   type == "array"  then (.[0] // null)
            elif type == "object" then (.name // .engine // null)
            elif type == "string" then .
            else null end;

        (.results // []) as $all
        | ($all[:$n]) as $taken
        | (.infoboxes // []) as $ib
        | (.unresponsive_engines // []) as $dead
        | (.answers // []) as $answers
        | {
            query:       $q,
            instance:    $instance,
            total_hits:  (.number_of_results // null),
            returned:    ($taken | length),
            answers:     ($answers | map(render_answer) | map(select(. != null and . != ""))),
            infobox:     (if ($ib | length) > 0
                            then {title: ($ib[0].infobox // null),
                                  content: ($ib[0].content // null | clean_text)}
                            else null end),
            results: ($taken
                      | to_entries
                      | map({
                            n:              (.key + 1),
                            title:          (.value.title // null),
                            url:            (.value.url // null),
                            engine:         (.value.engine // null),
                            published_date: (.value.publishedDate // null),
                            snippet:        (.value.content | clean_text)
                        })),
            suggestions:          (.suggestions // []),
            unresponsive_engines: ($dead | map(engine_name) | map(select(. != null))),
            warnings:             (
                                    [
                                      (if ($taken | length) == 0
                                          and ($answers | length) == 0
                                          and ($ib | length) == 0
                                          then "no results, answers, or infobox returned"
                                          else empty end)
                                    ]
                                  )
          }
        ' <<<"$response"
    ;;
esac
