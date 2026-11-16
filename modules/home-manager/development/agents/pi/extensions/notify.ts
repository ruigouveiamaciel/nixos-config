/**
 * Pi Notify Extension
 *
 * Desktop notifications via `notify` (an alias of `kitten notify` with
 * support for tmux) when the agent settles or another extension fires a
 * ping: "ping:input" / "ping:done". Built-in ctx.ui prompts do NOT notify
 * — extensions that consider their prompts important ping themselves.
 */

import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Quote a string as a single POSIX shell word. */
const q = (text: string) => `'${text.replace(/'/g, `'\\''`)}'`;

const cmd = (title: string, body: string) =>
  `notify --app-name Pi --icon utilities-terminal ${q(title)} ${q(body)}`;

/**
 * Run `notify` via the user's login shell so the alias resolves. Best-effort:
 * failures are silent.
 */
function notify(title: string, body: string): void {
  const command = cmd(title, body);
  const shell = process.env.SHELL || "sh";

  // stdout inherits pi's terminal so kitten notify's escape sequence
  // (tmux passthrough wrapper included) reaches the real TTY instead of a
  // dead pipe. stdin/stderr are not needed.
  const child = spawn(shell, ["-lic", command], {
    stdio: ["ignore", "inherit", "ignore"],
  });
  const timer = setTimeout(() => child.kill(), 5_000);
  timer.unref?.();
  child.on("error", () => {}); // best-effort: failures are silent
  child.on("exit", () => clearTimeout(timer));
}

/** Max length of a shell command shown in a notification body. */
const MAX_DETAIL = 100;

interface PingPayload {
  tool?: string;
  detail?: string;
}

/** "edit"/"write"/"read" -> "edit file", etc. */
const actionFor = (tool: string) =>
  ["read", "write", "edit"].includes(tool) ? `${tool} file` : `use "${tool}"`;

/** Human sentence for a permission request, based on the ping payload. */
function describeInput({ tool, detail }: PingPayload): string {
  const target = detail ? `: ${detail.length > MAX_DETAIL ? detail.slice(0, MAX_DETAIL) + "…" : detail}` : "";
  if (!tool) return "The agent is waiting for your input.";
  if ((tool === "bash" || tool === "powershell") && detail)
    return `Permission requested to run a command${target}`;
  return `Permission requested to ${actionFor(tool)}${target}`;
}

export default function (pi: ExtensionAPI) {
  if (process.platform !== "linux") return;

  pi.events.on("ping:input", (payload) => {
    notify("Pi needs your input", describeInput((payload ?? {}) as PingPayload));
  });

  const doneBody = "The agent has finished.";

  pi.events.on("ping:done", () => {
    notify("Pi is done", doneBody);
  });

  // agent_end fires before retries/compaction may continue; wait for settle.
  pi.on("agent_settled", async () => {
    notify("Pi is done", doneBody);
  });
}
