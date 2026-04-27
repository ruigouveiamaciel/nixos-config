import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { isBashAllowed } from "../utils/bash-guard-helpers";

export default function (pi: ExtensionAPI) {
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
  });
}
