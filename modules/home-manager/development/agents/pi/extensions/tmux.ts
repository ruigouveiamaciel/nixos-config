/**
 * Pi tmux Extension
 *
 * Window name in the tmux status bar: "pi" + a pulsing dot while the agent
 * is working, a blinking "!" while Pi needs input, plain when idle. On quit
 * the custom name is dropped so tmux auto-names the window again.
 */

import { execFileSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const WINDOW_NAME = "pi";
const SPINNER_FRAMES = ["·", "•", "●", "•"];
const SPINNER_MS = 80;
const ATTENTION_FRAMES = ["!", " "]; // fixed width so the status bar doesn't shift
const ATTENTION_MS = 250;

/** Target for tmux -t: $TMUX_PANE ("%N"), or the 4th $TMUX field on non-standard builds. */
function paneTarget(): string | null {
  if (process.env.TMUX_PANE) return process.env.TMUX_PANE;
  const tmux = process.env.TMUX;
  if (!tmux) return null;
  const parts = tmux.split(",");
  return parts.length >= 4 && parts[3] ? parts[3] : null;
}

function tmux(...args: string[]): void {
  try {
    execFileSync("tmux", args, { stdio: "ignore" });
  } catch {
    /* tmux missing or the target window is gone */
  }
}

let target: string | null = null; // resolved once at session_start
let spinner: ReturnType<typeof setInterval> | null = null;
let attention: ReturnType<typeof setInterval> | null = null;

function setName(name: string): void {
  if (!target) return;
  tmux("rename-window", "-t", target, name);
}

/** Blink `frames` after the window name until the timer is cleared. */
function startTicker(
  frames: string[],
  ms: number,
): ReturnType<typeof setInterval> {
  let frame = 0;
  const timer = setInterval(
    () => setName(WINDOW_NAME + frames[frame++ % frames.length]),
    ms,
  );
  timer.unref?.();
  return timer;
}

function stopSpinner(): void {
  if (spinner) clearInterval(spinner);
  spinner = null;
}

function stopAttention(): void {
  if (attention) clearInterval(attention);
  attention = null;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async () => {
    target = paneTarget();
    setName(WINDOW_NAME);
  });

  pi.on("agent_start", async () => {
    stopAttention();
    stopSpinner();
    spinner = startTicker(SPINNER_FRAMES, SPINNER_MS);
  });

  pi.on("ui_prompt_start", async () => {
    stopSpinner();
    stopAttention();
    attention = startTicker(ATTENTION_FRAMES, ATTENTION_MS);
  });

  pi.on("ui_prompt_end", async () => {
    stopAttention();
    setName(WINDOW_NAME);
  });

  pi.on("agent_settled", async () => {
    stopSpinner();
    stopAttention();
    setName(WINDOW_NAME);
  });

  // Idempotent: safe if the session is already torn down.
  pi.on("session_shutdown", async () => {
    stopSpinner();
    stopAttention();
    if (target) {
      tmux("rename-window", "-t", target, "");
      tmux("set-option", "-w", "-t", target, "automatic-rename", "on");
    }
    target = null;
  });
}
