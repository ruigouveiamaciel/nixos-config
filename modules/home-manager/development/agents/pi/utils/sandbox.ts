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
    allowedDomains: [],
    deniedDomains: [],
  },
  filesystem: {
    denyRead: ["~/"],
    allowRead: [
      "~/repos/",
      "~/projects/",
      "/persist/nixos-config",
      "/tmp/",
      "/var/folders/",
      "~/Library/Caches/pnpm/",
      "~/.cache/pnpm/",
      "~/.pi/agent/extensions/",
      "~/.pi/agent/utils/",
      "~/.pi/agent/skills/",
      "~/.pi/agent/package.json",
      "~/.pi/agent/settings.json",
      "~/.config/git",
      "~/.gitconfig",
    ],
    allowWrite: ["~/repos/", "~/projects/", "/persist/nixos-config/", "/tmp/"],
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
