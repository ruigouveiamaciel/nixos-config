import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { isBashAllowed } from "../utils/bash-guard-helpers";
import { notify } from "../utils/notify";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event) || !event.input.command) return;

    const command = event.input.command;
    const permission = isBashAllowed({ command, pwd: ctx.cwd });

    if (permission.action === "deny") {
      return {
        block: true,
        reason: ["Operation was blocked", permission.reason].join(` — `),
      };
    }

    if (permission.action === "ask") {
      if (!ctx.hasUI) {
        return {
          block: true,
          reason:
            "Operation was blocked — no UI available to grant permission.",
        };
      }

      const lines = command.split("\n");
      const firstLine = lines[0] ?? "";
      const MAX_LEN = 160;
      const truncatedFirstLine = firstLine.length > MAX_LEN;
      const extraLines = lines.length - 1;

      const notes: string[] = [];
      if (truncatedFirstLine) {
        notes.push(`+${firstLine.length - MAX_LEN} chars`);
      }
      if (extraLines > 0) {
        notes.push(`+${extraLines} more line${extraLines === 1 ? "" : "s"}`);
      }

      const head = truncatedFirstLine ? firstLine.slice(0, MAX_LEN) : firstLine;
      const preview =
        notes.length > 0 ? `${head} […truncated: ${notes.join(", ")}]` : head;

      notify({
        title: `pi: permission requested (${event.toolName})`,
        message: `Allow ${event.toolName}?`,
      });

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
        return {
          block: true,
          reason: [
            "Operation was blocked by the user",
            reason.trim() || undefined,
          ].join(` — `),
        };
      }
    }
  });
}
