/**
 * Pi Ping Extension
 *
 * Plays a sound when the agent settles or when another extension fires a ping
 * manually via the event bus:
 *
 *   pi.events.emit("ping:input", { source: "my-extension" });
 *   pi.events.emit("ping:done",  { source: "my-extension" });
 *
 * Supported: Linux, with terminal bell (OSC 777 notification + BEL), which
 * works over SSH. Other platforms are not supported.
 *
 * PI_PING_COMMAND / PI_PING_DONE_COMMAND can be set to run a custom command
 * instead of the bell.
 *
 * Built-in ctx.ui prompts (select/input/confirm/editor) deliberately do NOT
 * ping — extensions that show prompts they consider important fire "ping:input"
 * themselves.
 */

import { execFile } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Terminal bell: OSC 777 notification + BEL. */
function bell(title: string): void {
  process.stdout.write(`\x1b]777;notify;Pi;${title}\x07`);
  process.stdout.write("\x07");
}

function play(command: string | undefined, title: string): void {
  if (command) {
    execFile("sh", ["-c", command], { timeout: 5_000 }, (err) => {
      if (err) bell(title); // command failed -> fall back to the bell
    });
    return;
  }
  bell(title);
}

export default function (pi: ExtensionAPI) {
  if (process.platform !== "linux") return;

  pi.events.on("ping:input", () => {
    play(process.env.PI_PING_COMMAND, "Needs your input");
  });

  pi.events.on("ping:done", () => {
    play(process.env.PI_PING_DONE_COMMAND, "Agent done");
  });

  // agent_end fires before retries/compaction may continue; wait for settle.
  pi.on("agent_settled", async () => {
    play(process.env.PI_PING_DONE_COMMAND, "Agent done");
  });
}
