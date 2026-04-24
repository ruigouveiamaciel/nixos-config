import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { isBashAllowed } from "../utils/bash-guard-helpers";
import {
  initSandbox,
  isSandboxablePlatform,
  isSandboxActive,
  loadSandboxConfig,
  resetSandbox,
  wrapCommandWithSandbox,
} from "../utils/sandbox";

export default function (pi: ExtensionAPI) {
  pi.registerFlag("no-sandbox", {
    description: "Disable OS-level sandboxing for bash commands",
    type: "boolean",
    default: false,
  });

  let sandboxEnabled = false;

  pi.on("session_start", async (_event, ctx) => {
    if (pi.getFlag("no-sandbox") as boolean) {
      ctx.ui.notify("Sandbox disabled via --no-sandbox", "warning");
      return;
    }

    if (!isSandboxablePlatform()) {
      ctx.ui.notify(
        `Sandbox not supported on ${process.platform}; running unsandboxed.`,
        "warning",
      );
      return;
    }

    const config = loadSandboxConfig(ctx.cwd);
    if (!config.enabled) {
      ctx.ui.notify("Sandbox disabled via config", "info");
      return;
    }

    try {
      await initSandbox(config);
      sandboxEnabled = true;

      ctx.ui.setStatus(
        "sandbox",
        ctx.ui.theme.fg("accent", "🔒 Sandbox enabled"),
      );
      ctx.ui.notify("Sandbox initialized", "info");
    } catch (err) {
      sandboxEnabled = false;
      ctx.ui.notify(
        `Sandbox initialization failed: ${err instanceof Error ? err.message : err}`,
        "error",
      );
    }
  });

  pi.on("session_shutdown", async () => {
    if (sandboxEnabled) await resetSandbox();
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event) || !event.input.command) return;

    const command = event.input.command;
    const permission = isBashAllowed({ command, pwd: ctx.cwd });

    if (permission.action === "deny") {
      return {
        block: true,
        reason: [`Bash command was blocked`, permission.reason].join(` — `),
      };
    }

    if (permission.action === "ask") {
      if (!ctx.hasUI) {
        return {
          block: true,
          reason:
            "Bash command was blocked — no UI available to grant permission.",
        };
      }

      const firstLine = command.split("\n", 1)[0] ?? "";
      const MAX_LEN = 160;
      const preview =
        firstLine.length > MAX_LEN
          ? `${firstLine.slice(0, MAX_LEN)}…`
          : command.includes("\n")
            ? `${firstLine} …`
            : firstLine;

      const choice = await ctx.ui.select(
        `Allow ${event.toolName}?\n\n${preview}`,
        ["Yes", "No"],
      );

      if (!choice) return ctx.abort();
      if (choice === "No") {
        const reason = await ctx.ui.input(
          `Deny reason?`,
          "Leave empty to deny silently",
        );
        if (reason === undefined) return ctx.abort();
        return { block: true, reason: reason.trim() || undefined };
      }
    }

    // Permission granted — wrap command with OS-level sandbox when active.
    if (sandboxEnabled && isSandboxActive()) {
      try {
        event.input.command = await wrapCommandWithSandbox(command);
      } catch (err) {
        return {
          block: true,
          reason: `Sandbox wrapping failed — ${err instanceof Error ? err.message : String(err)}`,
        };
      }
    }
  });

  pi.registerCommand("sandbox", {
    description: "Show sandbox configuration",
    handler: async (_args, ctx) => {
      if (!sandboxEnabled) {
        ctx.ui.notify("Sandbox is disabled", "info");
        return;
      }

      const config = loadSandboxConfig(ctx.cwd);
      const lines = [
        "Sandbox Configuration:",
        "",
        "Network:",
        `  Allowed: ${config.network?.allowedDomains?.join(", ") || "(none)"}`,
        `  Denied:  ${config.network?.deniedDomains?.join(", ") || "(none)"}`,
        "",
        "Filesystem:",
        `  Deny Read:   ${config.filesystem?.denyRead?.join(", ") || "(none)"}`,
        `  Allow Write: ${config.filesystem?.allowWrite?.join(", ") || "(none)"}`,
        `  Deny Write:  ${config.filesystem?.denyWrite?.join(", ") || "(none)"}`,
      ];
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });
}
