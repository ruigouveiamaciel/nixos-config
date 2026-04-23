import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { isBashAllowed } from "../utils/bash-guard-helpers";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("bash", event) && event.input.command) {
      const command = event.input.command;
      const permission = isBashAllowed({
        command: command,
        pwd: ctx.cwd,
      });

      if (permission.action === "deny") {
        return {
          block: true,
          reason: [`Bash command was blocked`, permission.reason].join(` — `),
        };
      } else if (permission.action === "ask") {
        if (!ctx.hasUI) {
          return {
            block: true,
            reason:
              "Bash command was blocked — no UI available to grant permission.",
          };
        }

        const choice = await ctx.ui.select(
          `Allow ${event.toolName}?\n${command}`,
          ["Yes", "No"],
        );

        if (!choice) {
          return ctx.abort();
        } else if (choice === "No") {
          const reason = await ctx.ui.input(
            `Deny reason?`,
            "Leave empty to deny silently",
          );

          return { block: true, reason: reason?.trim() || undefined };
        }
      }
    }
  });
}
