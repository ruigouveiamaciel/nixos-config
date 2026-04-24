---
name: nix-search
description: Authoritative lookups across the Nix ecosystem — nixpkgs packages, NixOS / Home Manager / nix-darwin / Nixvim options, flake inputs, Noogle functions, NixHub version history, and the Nix wiki / nix.dev docs. Prefer over web-search whenever the question is about a Nix name, option path, attribute, or version.
---

# mcp-nixos

Local stdio MCP server (`mcp-nixos`) fronted by `mcporter`. Exposes the NixOS
Elasticsearch indexes, option docs, Noogle, NixHub, the Nix wiki, and nix.dev
through two tools. No auth, no network credentials — the server runs on-demand
as a child process.

## Requirements

`mcp-nixos` and `mcporter` must be on `PATH` (they are, via the home-manager
`agents` module). Verify:

```bash
{baseDir}/nix-search.sh status
```

Exit 0 = ready. Exit 1 = binary missing or server failed to start — usually a
stale home-manager generation; rebuild and retry.

## Usage

```bash
{baseDir}/nix-search.sh tools                         # list tools (JSON)
{baseDir}/nix-search.sh schema <tool>                 # schema for one tool
{baseDir}/nix-search.sh call <tool> key=value ...     # invoke with scalar args
{baseDir}/nix-search.sh call <tool> --args '{...}'    # invoke with raw JSON
```

Run `{baseDir}/nix-search.sh help` for the full reference.

Argument coercion (from `mcporter`):

- `key=value` → **string**
- `key:value` → **typed JSON** (`limit:5` is int 5; `enabled:true` is bool)
- `--args '{...}'` → raw JSON object, merged over `key=value` pairs

Tool names are case-sensitive. Discover them with `tools` before calling.

## Tools

Two tools. Schemas evolve — confirm with `schema <tool>` before assuming
parameters.

### `nix` — unified query across every source

Single entry point. Required: `action`. Other args depend on `action`:

| action         | purpose                                        | key args                             |
| -------------- | ---------------------------------------------- | ------------------------------------ |
| `search`       | Search packages / options / programs           | `query`, `source`, `type`, `channel` |
| `info`         | Full record for one package or option          | `query`, `source`, `type`, `channel` |
| `stats`        | Document counts for a source / channel         | `source`, `channel`                  |
| `options`      | Browse option tree (`list` / `ls` / `read`)    | `query`, `source`, `type`            |
| `channels`     | List indexed NixOS release channels            | —                                    |
| `flake-inputs` | Resolve / read flake inputs in the current dir | `query`, `limit`                     |
| `cache`        | Inspect on-disk cache for a source             | `source`, `version`                  |

Enums:

- `source` ∈
  `nixos | home-manager | darwin | flakes | flakehub | nixvim | wiki | nix-dev | noogle | nixhub`
  (default `nixos`)
- `type` ∈ `packages | options | programs | list | ls | read` (default
  `packages`)
- `channel`∈ `unstable | stable | 25.11 | beta` (default `unstable`; `stable`
  currently resolves to `25.11`)
- `limit` ∈ 1–100 (1–2000 for `flake-inputs read`)

#### Picking the right `source`

`source` tracks the scope of the question, not the host you're running on:

- Packages (nixpkgs) → `source=nixos`. Linux and macOS draw from the same
  package index; this source is correct on either.
- NixOS system options (Linux hosts) → `source=nixos`, `type=options`.
- nix-darwin system options (macOS hosts) → `source=darwin`.
- User-level config (any host) → `source=home-manager`.
- Neovim via Nixvim → `source=nixvim`.
- Library / stdlib function lookups → `source=noogle`.
- Prose docs → `source=wiki` or `source=nix-dev`.
- Flake inputs / FlakeHub metadata → `source=flakes` / `source=flakehub`.

The naming is a bit unfortunate: `source=nixos` returns **either** a package or
an option depending on `type=`, and its options are NixOS-the-Linux-distro
options — they don't apply to nix-darwin hosts. Pick the source that matches the
_kind of config_ you're asking about.

#### Examples

```bash
# Package search on nixpkgs (works on any host)
{baseDir}/nix-search.sh call nix action=search query=ripgrep limit:5

# Full package metadata
{baseDir}/nix-search.sh call nix action=info query=firefox source=nixos

# Home Manager option search
{baseDir}/nix-search.sh call nix action=search \
    query=programs.fish source=home-manager type=options limit:10

# NixOS system option lookup — MUST use search, not options (see Gotchas)
{baseDir}/nix-search.sh call nix action=search \
    query=services.nginx source=nixos type=options limit:10

# nix-darwin option tree browse (macOS hosts)
{baseDir}/nix-search.sh call nix action=options \
    query=homebrew source=darwin type=ls limit:20

# Noogle — find a Nix stdlib function
{baseDir}/nix-search.sh call nix action=search \
    query=mapAttrs source=noogle limit:5

# Pin to a numeric channel — numeric strings need --args (see Gotchas)
{baseDir}/nix-search.sh call nix --args \
    '{"action":"search","query":"ripgrep","channel":"25.11","limit":5}'

# List indexed channels
{baseDir}/nix-search.sh call nix action=channels
```

### `nix_versions` — NixHub version history

Every version of a package ever shipped in nixpkgs, with nixpkgs commit SHAs.
Required: `package`.

```bash
{baseDir}/nix-search.sh call nix_versions package=nodejs limit:10

# Looking up a numeric version — use --args so the version stays a
# string (see Gotchas).
{baseDir}/nix-search.sh call nix_versions --args \
    '{"package":"postgresql","version":"16.5"}'
```

## Output Envelope

Success:

```json
{ "result": "<preformatted human-readable text>" }
```

Error (exit still `0`):

```json
{
  "content": [{ "type": "text", "text": "<error message>" }],
  "isError": true
}
```

Always check the payload, not just the exit code. The text is preformatted by
the server — parse with your eyes, not `jq`. If you need structure, narrow the
query instead of trying to split the string.

## Gotchas

- **Numeric-looking string values get coerced to numbers.** Any string arg whose
  value parses as a number (`channel=25.11`, `version=16`) fails with a pydantic
  `string_type` error because `mcporter` sends it as a float/int. Fixes:
  `--args '{"version":"16"}'` or `version:'"16"'` (colon + quoted-JSON).
  Purely-alphabetic values (`unstable`, `stable`, `beta`) are safe bare.
- **`source` defaults to `nixos`.** For Home Manager / darwin / nixvim options
  you _must_ pass the matching `source=` or you'll get "not found" for valid
  names.
- **`limit` is capped 1–100.** The server rejects `0` and `101+` with
  `Error (ERROR): Limit must be 1-100`. No pagination cursor exists — raise
  `limit` instead of trying to page.
- **First cold query on a new channel takes a few seconds** while `mcp-nixos`
  populates `~/.cache/mcp_nixos/`. Subsequent calls are instant.
- **`flake-inputs` reads from the current working directory.** It expects a
  `flake.nix` in `$PWD`; it's not a remote lookup.
- **Unknown tool names return `isError:true` with exit 0.** Always check `tools`
  / `schema <tool>` if you're unsure of the name.
- **`key=value` vs `key:value`.** Equals sends a string; colon sends typed JSON.
  `limit:5` works; `limit=5` is the string `"5"` and gets rejected.

## When Not to Use

- Questions about what's **actually installed or active** on the host → use
  `nix`, `nix-env`, `nixos-option` (Linux) / `darwin-option` (macOS), or read
  the flake directly. This skill queries upstream indexes, not local system
  state.
- Anything outside the Nix ecosystem → fall back to `web-search`.
- Building / evaluating derivations → use `nix build` / `nix eval`.
