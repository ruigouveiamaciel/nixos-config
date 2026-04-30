#!/usr/bin/env bash
# atlassian.sh — wrapper around `mcporter` for the Atlassian Rovo MCP
# server. Run `atlassian.sh help` for usage.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE_DEFAULT="$SCRIPT_DIR/mcporter.json"
SERVER_NAME="atlassian"

usage() {
    cat <<'EOF'
Usage: atlassian.sh <command> [args...]

Commands:
  auth                        Run the OAuth browser flow. One-time per user
                              per machine; cached tokens are reused and
                              refreshed automatically afterwards.
  status                      Show whether OAuth tokens are cached locally.
  tools                       List all tools exposed by the Atlassian MCP
                              server (JSON).
  schema <tool>               Print the JSON schema for a single tool.
  call <tool> [key=value ...] Invoke a tool. Arguments can be:
                                - key=value pairs (bool/int/null/JSON
                                  auto-coerced by mcporter)
                                - raw JSON via `--args '{"k":"v"}'`
                                - pass `--` to forward literal positional
                                  values or extra mcporter flags
  help                        Show this message.

Environment:
  ATLASSIAN_MCP_CONFIG        Path to an alternative mcporter config file
                              (default: <this script's dir>/mcporter.json).
  MCPORTER_OAUTH_TIMEOUT_MS   OAuth browser wait in ms (mcporter built-in).

Output:
  `tools` and `schema` use `mcporter list --json`. `call` uses
  `mcporter call --output json`. `auth` and `status` print human-readable
  status to stderr and keep stdout clean.

Exit codes:
  0  success
  1  runtime error (network, mcporter failure, non-JSON response,
                    missing tokens for tools/schema/call)
  2  usage error (bad flag, missing argument, unknown subcommand)

Examples:
  atlassian.sh auth                        # run once, browser opens
  atlassian.sh status
  atlassian.sh tools | jq '.tools[] | {name, description}'
  atlassian.sh schema getJiraIssue
  atlassian.sh call getJiraIssue issueIdOrKey=PROJ-123
  atlassian.sh call searchJiraIssuesUsingJql \
      --args '{"jql":"assignee=currentUser() AND resolution=Unresolved"}'
EOF
}

die() {
    echo "atlassian.sh: $*" >&2
    exit 1
}
bad() {
    echo "atlassian.sh: $*" >&2
    exit 2
}

# Parse the subcommand before preflight so `help` / bad usage works
# without mcporter installed.
cmd="${1:-}"
[[ -n "$cmd" ]] || { usage >&2; exit 2; }
shift || true

case "$cmd" in
help | -h | --help)
    usage
    exit 0
    ;;
auth | status | tools | schema | call) ;;
*) bad "unknown command: $cmd (try: auth | status | tools | schema | call | help)" ;;
esac

for bin in mcporter jq; do
    command -v "$bin" >/dev/null 2>&1 \
        || die "missing required binary: $bin (install via home-manager 'agents' module)"
done

CONFIG_FILE="${ATLASSIAN_MCP_CONFIG:-$CONFIG_FILE_DEFAULT}"
[[ -f "$CONFIG_FILE" ]] || die "mcporter config not found at $CONFIG_FILE"

# How long the probe waits for the OAuth callback. Default lets the user
# complete browser consent; override (e.g. 500) to make `status` non-blocking.
AUTH_PROBE_TIMEOUT_MS="${ATLASSIAN_AUTH_PROBE_TIMEOUT_MS:-60000}"

# Returns: "authenticated" | "unauthenticated" | "unknown:<reason>"
probe_auth() {
    local tmp_out tmp_err status issue_kind issue_msg
    tmp_out=$(mktemp -t atlassian-mcp.probe.XXXXXX)
    tmp_err=$(mktemp -t atlassian-mcp.probe.err.XXXXXX)
    mcporter --config "$CONFIG_FILE" --oauth-timeout "$AUTH_PROBE_TIMEOUT_MS" \
        list "$SERVER_NAME" --json >"$tmp_out" 2>"$tmp_err" || true
    if ! jq -e . "$tmp_out" >/dev/null 2>&1; then
        rm -f "$tmp_out" "$tmp_err"
        printf 'unknown:mcporter-returned-no-json'
        return
    fi
    status=$(jq -r '.status // ""' "$tmp_out")
    issue_kind=$(jq -r '.issue.kind // ""' "$tmp_out")
    issue_msg=$(jq -r '.issue.rawMessage // .issue.message // ""' "$tmp_out")
    rm -f "$tmp_out" "$tmp_err"
    case "$status" in
        ok)
            printf 'authenticated'
            ;;
        offline)
            # Distinguish missing creds from network failure.
            if [[ "$issue_msg" == *OAuth* || "$issue_msg" == *authoriz* || "$issue_kind" == *auth* ]]; then
                printf 'unauthenticated'
            else
                printf 'unknown:%s' "${issue_msg:-offline}"
            fi
            ;;
        *)
            printf 'unknown:status=%s' "${status:-missing}"
            ;;
    esac
}

require_tokens() {
    local state
    state=$(probe_auth)
    case "$state" in
        authenticated) return 0 ;;
        unauthenticated) die "not authenticated with Atlassian. Run: atlassian.sh auth" ;;
        unknown:*) die "could not verify auth state (${state#unknown:}). Run: atlassian.sh status for details" ;;
    esac
}

# mcporter 0.8.x truncates piped stdout at ~64 KiB, so we route through a
# tempfile instead of $(...) capture.
run_mcporter_json() {
    local tmp_out tmp_err rc
    tmp_out=$(mktemp -t atlassian-mcp.out.XXXXXX)
    tmp_err=$(mktemp -t atlassian-mcp.err.XXXXXX)
    trap 'rm -f "$tmp_out" "$tmp_err"' RETURN
    if ! mcporter --config "$CONFIG_FILE" "$@" >"$tmp_out" 2>"$tmp_err"; then
        rc=$?
        echo "atlassian.sh: mcporter failed (exit $rc):" >&2
        cat "$tmp_err" >&2
        [[ -s "$tmp_out" ]] && cat "$tmp_out" >&2
        exit 1
    fi
    cat "$tmp_out"
}

case "$cmd" in

auth)
    [[ $# -eq 0 ]] || bad "'auth' takes no arguments"
    echo "atlassian.sh: opening browser for Atlassian OAuth consent…" >&2
    # Interactive — do NOT capture stdio; let mcporter drive the terminal.
    exec mcporter --config "$CONFIG_FILE" auth "$SERVER_NAME" "$@"
    ;;

status)
    [[ $# -eq 0 ]] || bad "'status' takes no arguments"
    state=$(probe_auth)
    case "$state" in
        authenticated)
            echo "atlassian.sh: authenticated (verified via mcporter)" >&2
            printf '{"server":"%s","authenticated":true,"state":"%s"}\n' \
                "$SERVER_NAME" "authenticated"
            exit 0
            ;;
        unauthenticated)
            echo "atlassian.sh: not authenticated. Run: atlassian.sh auth" >&2
            printf '{"server":"%s","authenticated":false,"state":"%s"}\n' \
                "$SERVER_NAME" "unauthenticated"
            exit 1
            ;;
        unknown:*)
            reason="${state#unknown:}"
            echo "atlassian.sh: could not verify auth state: $reason" >&2
            jq -nc --arg s "$SERVER_NAME" --arg r "$reason" \
                '{server:$s, authenticated:null, state:"unknown", reason:$r}'
            exit 2
            ;;
    esac
    ;;

tools)
    [[ $# -eq 0 ]] || bad "'tools' takes no arguments"
    require_tokens
    out=$(run_mcporter_json list "$SERVER_NAME" --json)
    jq -e . >/dev/null 2>&1 <<<"$out" \
        || die "mcporter returned non-JSON. Raw output:
$out"
    printf '%s\n' "$out"
    ;;

schema)
    tool="${1:-}"
    [[ -n "$tool" ]] || bad "'schema' requires a tool name"
    shift
    [[ $# -eq 0 ]] || bad "'schema' takes only a tool name"
    require_tokens
    out=$(run_mcporter_json list "$SERVER_NAME" --schema --json)
    jq -e . >/dev/null 2>&1 <<<"$out" \
        || die "mcporter returned non-JSON. Raw output:
$out"
    jq --arg t "$tool" '
        (.tools // .servers[0].tools // [])
        | map(select(.name == $t))
        | if length == 0 then
            error("tool not found: \($t)")
          else .[0] end
    ' <<<"$out"
    ;;

call)
    tool="${1:-}"
    [[ -n "$tool" ]] || bad "'call' requires a tool name"
    shift
    for arg in "$@"; do
        case "$arg" in
            --log-level|--log-level=*)
                bad "--log-level is not allowed"
                ;;
        esac
    done
    require_tokens
    run_mcporter_json call "$SERVER_NAME.$tool" --output json "$@"
    ;;
esac
