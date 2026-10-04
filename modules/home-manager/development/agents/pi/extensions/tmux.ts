/**
 * Pi tmux Extension
 *
 * Window name in the tmux status bar: "pi" + a pulsing dot while the agent
 * is working, a blinking "!" while Pi needs input, plain when idle. On quit the custom
 * name is dropped so tmux auto-names the window again.
 */

import { execFileSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Pane id: $TMUX_PANE ("%N"), or the 4th $TMUX field on non-standard builds. */
function tmuxWindowId(): string | null {
  if (process.env.TMUX_PANE) return process.env.TMUX_PANE;
  const tmux = process.env.TMUX;
  if (!tmux) return null;
  const parts = tmux.split(",");
  return parts.length >= 4 && parts[3] ? parts[3] : null;
}

function tmuxGet(windowId: string | null): string | null {
  if (!windowId) return null;
  try {
    return execFileSync(
      "tmux",
      ["display-message", "-p", "-t", windowId, "#{window_name}"],
      {
        encoding: "utf8",
      },
    ).replace(/[\r\n]+$/, "");
  } catch {
    return null;
  }
}

function tmuxSet(windowId: string | null, name: string): void {
  if (!windowId || !name) return;
  try {
    execFileSync("tmux", ["rename-window", "-t", windowId, name]);
  } catch {
    /* window is gone */
  }
}

type TmuxState = { windowId: string | null; baseName: string | null };

let tmuxState: TmuxState | null = null;

function ensureState(): void {
  if (tmuxState) return;
  tmuxState = { windowId: tmuxWindowId(), baseName: tmuxGet(tmuxWindowId()) };
}

function tmuxClear(): void {
  if (!tmuxState) return;
  tmuxSet(tmuxState.windowId, tmuxState.baseName ?? "");
}

function tmuxRelease(): void {
  if (!tmuxState) return;
  stopSpinner();
  stopAttention();
  if (tmuxState.windowId) {
    try {
      execFileSync("tmux", ["rename-window", "-t", tmuxState.windowId, ""]);
      execFileSync("tmux", [
        "set-option",
        "-w",
        "-t",
        tmuxState.windowId,
        "automatic-rename",
        "on",
      ]);
    } catch {
      /* window is gone */
    }
  }
  tmuxState = null;
}

const SPINNER = ["·", "•", "●", "•"];
const SPINNER_MS = 80;
const ATTENTION_BLINK = ["!", " "]; // fixed width so the status bar doesn't shift
const ATTENTION_MS = 250;
const WINDOW_NAME = "pi";

let spinnerTimer: ReturnType<typeof setInterval> | null = null;
let spinnerFrame = 0;
let attentionTimer: ReturnType<typeof setInterval> | null = null;
let attentionFrame = 0;

function startSpinner(): void {
  if (spinnerTimer) return;
  ensureState();
  if (!tmuxState?.windowId) return;
  spinnerFrame = 0;
  spinnerTimer = setInterval(() => {
    if (!tmuxState?.windowId) return stopSpinner();
    tmuxSet(
      tmuxState.windowId,
      tmuxState.baseName + SPINNER[spinnerFrame++ % SPINNER.length],
    );
  }, SPINNER_MS);
  spinnerTimer.unref?.();
}

function stopSpinner(): void {
  if (!spinnerTimer) return;
  clearInterval(spinnerTimer);
  spinnerTimer = null;
}

function startAttention(): void {
  if (attentionTimer) return;
  ensureState();
  if (!tmuxState?.windowId) return;
  attentionFrame = 0;
  attentionTimer = setInterval(() => {
    if (!tmuxState?.windowId) return stopAttention();
    tmuxSet(
      tmuxState.windowId,
      tmuxState.baseName + ATTENTION_BLINK[attentionFrame++ % ATTENTION_BLINK.length],
    );
  }, ATTENTION_MS);
  attentionTimer.unref?.();
}

function stopAttention(): void {
  if (!attentionTimer) return;
  clearInterval(attentionTimer);
  attentionTimer = null;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async () => {
    ensureState();
    if (!tmuxState?.windowId) return;
    tmuxState.baseName = WINDOW_NAME;
    tmuxSet(tmuxState.windowId, WINDOW_NAME);
  });

  pi.on("agent_start", async () => {
    tmuxClear();
    startSpinner();
  });

  pi.on("ui_prompt_start", async (event) => {
    void event;
    stopSpinner();
    startAttention();
  });

  // The next agent_start restarts the pulse.
  pi.on("ui_prompt_end", async () => {
    stopAttention();
    tmuxClear();
  });

  // leave the spinner alone if the agent is working
  pi.on("input", async () => {
    if (!spinnerTimer) {
      stopAttention();
      tmuxClear();
    }
  });

  pi.on("agent_settled", async () => {
    stopSpinner();
    stopAttention();
    tmuxClear();
  });

  pi.on("session_shutdown", async () => {
    tmuxRelease();
  });
}
