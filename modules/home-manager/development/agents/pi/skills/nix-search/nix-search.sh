#!/usr/bin/env bash
# nix-search.sh — Thin wrapper around `mcporter` for the local
# `mcp-nixos` stdio MCP server (NixOS, Home Manager, nix-darwin,
# flakes, FlakeHub, Nixvim, Wiki, nix.dev, Noogle, NixHub).
#
# Unlike the Atlassian skill, this server is entirely local and
# anonymous — no OAuth, no tokens, no network auth. The only
# precondition is that the `mcp-nixos` binary is on PATH (provided
# by the home-manager `agents` module via pkgs.unstable.mcp-nixos).
#
# Commands:
#   nix-search.sh status                        # probe the stdio server
#   nix-search.sh tools                         # list available tools
#   nix-search.sh schema <tool>                 # show a tool's JSON schema
#   nix-search.sh call <tool> [key=value ...]   # invoke a tool
#   nix-search.sh call <tool> --args '{...}'    # invoke with raw JSON
#
# The bundled `mcporter.json` (next to this script) registers the
# server with mcporter using the stdio transport.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE="$SCRIPT_DIR/mcporter.json"
SERVER_NAME="nixos"

usage() {
    cat <<'EOF'
Usage: nix-search.sh <command> [args...]

Commands:
  status                      Probe the stdio server and report whether
                              it starts and lists tools cleanly.
  tools                       List all tools exposed by mcp-nixos (JSON).
  schema <tool>               Print the JSON schema for a single tool.
  call <tool> [key=value ...] Invoke a tool. Arguments can be:
                                - key=value pairs (bool/int/null/JSON
                                  auto-coerced by mcporter)
                                - raw JSON via `--args '{"k":"v"}'`
                                - pass `--` to forward literal positional
                                  values or extra mcporter flags
  help                        Show this message.

Output:
  `tools` and `schema` use `mcporter list --json`. `call` uses
  `mcporter call --output json`. `status` prints human-readable status
  to stderr and JSON to stdout.

Exit codes:
  0  success
  1  runtime error (mcporter failure, non-JSON response, mcp-nixos
                    failed to start)
  2  usage error (bad flag, missing argument, unknown subcommand)

Examples:
  nix-search.sh status
  nix-search.sh tools | jq '.tools[] | {name, description}'
  nix-search.sh schema nix
  nix-search.sh call nix action=search query=ripgrep limit:5
  nix-search.sh call nix action=info query=firefox source=nixos
  nix-search.sh call nix action=options query=homebrew source=darwin type=ls
  nix-search.sh call nix_versions package=nodejs limit:5
EOF
}

die() {
    echo "nix-search.sh: $*" >&2
    exit 1
}
bad() {
    echo "nix-search.sh: $*" >&2
    exit 2
}

# --- Dispatch --------------------------------------------------------------

cmd="${1:-}"
[[ -n "$cmd" ]] || { usage >&2; exit 2; }
shift || true

case "$cmd" in
help | -h | --help)
    usage
    exit 0
    ;;
status | tools | schema | call) ;; # fall through
*) bad "unknown command: $cmd (try: status | tools | schema | call | help)" ;;
esac

# --- Preflight -------------------------------------------------------------

for bin in mcporter jq mcp-nixos; do
    command -v "$bin" >/dev/null 2>&1 \
        || die "missing required binary: $bin (install via home-manager 'agents' module)"
done

[[ -f "$CONFIG_FILE" ]] || die "mcporter config not found at $CONFIG_FILE"

# Ask mcporter whether the stdio server starts and lists tools. No auth
# involved; we only distinguish "ok" from any form of failure.
#
# Outputs:  "ok" | "error:<reason>"
probe_server() {
    local tmp_out tmp_err status issue_msg
    tmp_out=$(mktemp -t nix-search.probe.XXXXXX)
    tmp_err=$(mktemp -t nix-search.probe.err.XXXXXX)
    mcporter --config "$CONFIG_FILE" list "$SERVER_NAME" --json \
        >"$tmp_out" 2>"$tmp_err" || true
    if ! jq -e . "$tmp_out" >/dev/null 2>&1; then
        rm -f "$tmp_out" "$tmp_err"
        printf 'error:mcporter-returned-no-json'
        return
    fi
    status=$(jq -r '.servers[0].status // .status // ""' "$tmp_out")
    issue_msg=$(jq -r '.servers[0].issue.rawMessage // .servers[0].issue.message // .issue.rawMessage // .issue.message // ""' "$tmp_out")
    rm -f "$tmp_out" "$tmp_err"
    case "$status" in
        ok) printf 'ok' ;;
        *)  printf 'error:%s' "${issue_msg:-status=${status:-missing}}" ;;
    esac
}

require_ready() {
    local state
    state=$(probe_server)
    case "$state" in
        ok) return 0 ;;
        error:*) die "mcp-nixos server not ready (${state#error:}). Run: nix-search.sh status for details" ;;
    esac
}

run_mcporter_json() {
    # See atlassian.sh — mcporter 0.8.x truncates piped stdout at ~64 KiB,
    # so we redirect to a tempfile instead of `$(...)` capture.
    local tmp_out tmp_err rc
    tmp_out=$(mktemp -t nix-search.out.XXXXXX)
    tmp_err=$(mktemp -t nix-search.err.XXXXXX)
    trap 'rm -f "$tmp_out" "$tmp_err"' RETURN
    if ! mcporter --config "$CONFIG_FILE" "$@" >"$tmp_out" 2>"$tmp_err"; then
        rc=$?
        echo "nix-search.sh: mcporter failed (exit $rc):" >&2
        cat "$tmp_err" >&2
        [[ -s "$tmp_out" ]] && cat "$tmp_out" >&2
        exit 1
    fi
    cat "$tmp_out"
}

# --- Subcommands -----------------------------------------------------------

case "$cmd" in

status)
    [[ $# -eq 0 ]] || bad "'status' takes no arguments"
    state=$(probe_server)
    case "$state" in
        ok)
            echo "nix-search.sh: server ready (mcp-nixos starts and lists tools)" >&2
            printf '{"server":"%s","ready":true,"state":"ok"}\n' "$SERVER_NAME"
            exit 0
            ;;
        error:*)
            reason="${state#error:}"
            echo "nix-search.sh: server not ready: $reason" >&2
            jq -nc --arg s "$SERVER_NAME" --arg r "$reason" \
                '{server:$s, ready:false, state:"error", reason:$r}'
            exit 1
            ;;
    esac
    ;;

tools)
    [[ $# -eq 0 ]] || bad "'tools' takes no arguments"
    require_ready
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
    require_ready
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
    # --log-level is strictly not allowed.
    for arg in "$@"; do
        case "$arg" in
            --log-level|--log-level=*)
                bad "--log-level is not allowed"
                ;;
        esac
    done
    require_ready
    run_mcporter_json call "$SERVER_NAME.$tool" --output json "$@"
    ;;
esac
