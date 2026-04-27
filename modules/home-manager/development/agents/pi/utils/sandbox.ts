import {
  SandboxManager,
  type SandboxRuntimeConfig,
} from "@anthropic-ai/sandbox-runtime";

export interface SandboxConfig extends SandboxRuntimeConfig {
  enabled?: boolean;
  ignoreViolations?: Record<string, string[]>;
  enableWeakerNestedSandbox?: boolean;
}

export const DEFAULT_SANDBOX_CONFIG: SandboxConfig = {
  enabled: true,
  network: {
    allowedDomains: [
      // ── Pi + LLM providers (trim to providers you actually use) ──
      "api.anthropic.com",
      "claude.ai",
      "console.anthropic.com",
      "api.openai.com",
      "auth.openai.com",
      "chatgpt.com",
      "generativelanguage.googleapis.com",
      "oauth2.googleapis.com",
      "accounts.google.com",
      "cloudcode-pa.googleapis.com",
      "api.individual.githubcopilot.com",
      "api.business.githubcopilot.com",
      "api.enterprise.githubcopilot.com",

      // ── Skill: atlassian (Rovo MCP + OAuth + per-site) ──
      "*.atlassian.com",
      "*.atlassian.net",

      // ── Skill: nix-search (mcp-nixos upstream indexes) ──
      "nixos.org",
      "*.nixos.org",
      "discourse.nixos.org",
      "wiki.nixos.org",
      "nix.dev",
      "noogle.dev",
      "nixhub.io",
      "www.nixhub.io",
      "flakehub.com",
      "api.flakehub.com",
      "nix-community.github.io",
      "nix-darwin.github.io",

      // ── Skill: web-search (self-hosted SearXNG on LAN) ──
      "10.0.50.42",

      // ── Search-engine fallback (when SearXNG is down) ──
      "duckduckgo.com",
      "*.duckduckgo.com",
      "www.google.com",
      "www.bing.com",
      "search.brave.com",
      "*.brave.com",
      "kagi.com",
      "*.kagi.com",

      // ── Generic reference / Q&A (top of search-result clicks) ──
      "*.wikipedia.org",
      "*.wikimedia.org",
      "stackoverflow.com",
      "*.stackoverflow.com",
      "*.stackexchange.com",
      "serverfault.com",
      "superuser.com",
      "askubuntu.com",
      "news.ycombinator.com",
      "www.reddit.com",
      "old.reddit.com",
      "medium.com",
      "dev.to",

      // ── Web standards / MDN ──
      "developer.mozilla.org",
      "devdocs.io",
      "caniuse.com",
      "web.dev",
      "*.whatwg.org",
      "tc39.es",
      "*.w3.org",
      "www.rfc-editor.org",
      "datatracker.ietf.org",

      // ── Frontend stack docs (matches frontend/AGENTS.md) ──
      "www.typescriptlang.org",
      "typescript-eslint.io",
      "react.dev",
      "nextjs.org",
      "*.vercel.app",
      "nuxt.com",
      "vuejs.org",
      "vitejs.dev",
      "vitest.dev",
      "playwright.dev",
      "playwright.azureedge.net",
      "cdn.playwright.dev",
      "nx.dev",
      "turbo.build",
      "pnpm.io",
      "yarnpkg.com",
      "nodejs.org",
      "eslint.org",
      "prettier.io",
      "jestjs.io",
      "mswjs.io",
      "tailwindcss.com",
      "zod.dev",
      "trpc.io",
      "launchdarkly.com",
      "*.launchdarkly.com",

      // ── Package registries & code hosts ──
      "registry.npmjs.org",
      "*.npmjs.org",
      "*.npmjs.com",
      "crates.io",
      "docs.rs",
      "pkg.go.dev",
      "proxy.golang.org",
      "sum.golang.org",
      "pypi.org",
      "files.pythonhosted.org",
      "hex.pm",
      "rubygems.org",
      "sourcegraph.com",
      "codeberg.org",
      "bitbucket.org",
      "*.bitbucket.org",

      // ── Languages / runtimes ──
      "docs.python.org",
      "www.python.org",
      "www.rust-lang.org",
      "doc.rust-lang.org",
      "go.dev",
      "golang.org",
      "kotlinlang.org",
      "*.kotlinlang.org",
      "docs.oracle.com",

      // ── Cloud / infra / ops ──
      "docs.aws.amazon.com",
      "aws.amazon.com",
      "learn.microsoft.com",
      "docs.microsoft.com",
      "cloud.google.com",
      "kubernetes.io",
      "docs.docker.com",
      "hub.docker.com",
      "*.docker.io",
      "docs.gitlab.com",
      "docs.github.com",
      "www.terraform.io",
      "developer.hashicorp.com",
      "registry.terraform.io",
      "helm.sh",
      "nginx.org",
      "docs.nginx.com",

      // ── AI / LLM provider docs ──
      "docs.anthropic.com",
      "platform.openai.com",
      "ai.google.dev",
      "*.huggingface.co",

      // ── Git hosts (HTTPS clones, raw, releases) ──
      "github.com",
      "*.github.com",
      "*.githubusercontent.com",
      "gitlab.com",
      "*.gitlab.com",

      // ── Archive (when originals 404) ──
      "web.archive.org",
      "archive.org",

      // ── (optional) CDN edges for asset-heavy doc sites ──
      // Uncomment only if you switch to a real headless browser; not needed
      // for `curl … | lynx -dump` text-mode scraping.
      // "*.jsdelivr.net",
      // "*.unpkg.com",
      // "fonts.googleapis.com",
      // "fonts.gstatic.com",
      // "*.gstatic.com",
      // "*.cloudfront.net",
      // "*.cloudflare.com",
    ],
    deniedDomains: [],
  },
  filesystem: {
    denyRead: ["~/"],
    allowRead: [
      "~/repos",
      "~/projects",
      "/persist/nixos-config",
      "/tmp",
      "/private/tmp",
      "/var/folders",
      "/private/var/folders",
      "~/Library/Caches/pnpm",
      "~/.cache/pnpm",
      "~/.pi/agent/extensions",
      "~/.pi/agent/utils",
      "~/.pi/agent/skills",
      "~/.pi/agent/package.json",
      "~/.pi/agent/settings.json",
      "~/.config/git",
      "~/.gitconfig",
      "/nix/",
      "/opt/homebrew",
      "~/.nix-profile",
      "~/.nix-profile/bin",
      "/run/current-system/sw/bin",
      "/private/run/current-system/sw/bin",
      "/nix/var/nix/profiles/default/bin",
      "~/.local/state/nix",
    ],
    allowWrite: [
      "~/repos",
      "~/projects",
      "/persist/nixos-config",
      "/tmp",
      "/var/folders",
      "/private/tmp",
      "/private/var/folders",
    ],
    denyWrite: [".env", "*.env", "*.pem", "*.key"],
  },
};

export function loadSandboxConfig(): SandboxConfig {
  return DEFAULT_SANDBOX_CONFIG;
}

export function isSandboxablePlatform(): boolean {
  return process.platform === "darwin" || process.platform === "linux";
}

export async function initSandbox(config: SandboxConfig): Promise<void> {
  await SandboxManager.initialize({
    network: config.network,
    filesystem: config.filesystem,
    ignoreViolations: config.ignoreViolations,
    enableWeakerNestedSandbox: config.enableWeakerNestedSandbox,
  });
}

export async function resetSandbox(): Promise<void> {
  try {
    await SandboxManager.reset();
  } catch {
    // ignore cleanup errors
  }
}

export async function wrapCommandWithSandbox(command: string): Promise<string> {
  return SandboxManager.wrapWithSandbox(command);
}

export function isSandboxActive(): boolean {
  return SandboxManager.isSandboxingEnabled();
}
