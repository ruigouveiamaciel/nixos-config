/**
 * Pi Ping Extension
 *
 * Plays a sound when the agent finishes (PI_PING_DONE_COMMAND) or when another
 * extension fires a ping manually via the event bus:
 *
 *   pi.events.emit("ping:input", { source: "my-extension" });
 *   pi.events.emit("ping:done",   { source: "my-extension" });
 *
 * Falls back to afplay / PowerShell beep /
 * terminal notification (OSC 777 + BEL, works over SSH). Built-in ctx.ui
 * prompts (select/input/confirm/editor) deliberately do NOT ping — extensions
 * that show prompts they consider important (e.g. permission-gate) fire
 * "ping:input" themselves.
 *
 * tmux window renaming lives in tmux.ts.
 */

import { execFile } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function playWithCommand(cmd: string, args: string[], quiet = false): boolean {
  try {
    execFile(cmd, args, { timeout: 5_000 }, (err) => {
      if (err && !quiet) process.stdout.write("\x07");
    });
    return true;
  } catch {
    return false;
  }
}

function playFromEnv(command: string | undefined, fallbackTitle: string): void {
  if (command) {
    try {
      execFile("sh", ["-c", command], { timeout: 5_000 }, (err) => {
        if (err) process.stdout.write("\x07");
      });
      return;
    } catch {
      // fall through
    }
  }

  if (process.platform === "win32") {
    playWithCommand(
      "powershell.exe",
      ["-NoProfile", "-Command", "[console]::beep(1000,300)"],
      true,
    );
    return;
  }

  if (process.platform === "darwin") {
    if (playWithCommand("afplay", ["/System/Library/Sounds/Ping.aiff"], true))
      return;
    process.stdout.write("\x07");
    return;
  }

  // Terminal notification: works over SSH on hosts without audio.
  process.stdout.write(`\x1b]777;notify;Pi;${fallbackTitle}\x07`);
  process.stdout.write("\x07");
}

export default function (pi: ExtensionAPI) {
  // Other extensions fire these via the event bus, e.g. permission-gate when
  // it is about to show a permission prompt.
  pi.events.on("ping:input", () => {
    playFromEnv(process.env.PI_PING_COMMAND, "Needs your input");
  });

  pi.events.on("ping:done", () => {
    playFromEnv(process.env.PI_PING_DONE_COMMAND, "Agent done");
  });

  // agent_end fires before retries/compaction may continue; wait for settle.
  pi.on("agent_settled", async () => {
    playFromEnv(process.env.PI_PING_DONE_COMMAND, "Agent done");
  });
}
