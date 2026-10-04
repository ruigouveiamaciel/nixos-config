/**
 * Permission Gate
 *
 * Keeps the agent from running tools until you approve them. Tools are gated
 * based on the permission mode (/permissions opens a picker to choose it; the
 * descriptions of the available modes are shown there and in the status bar).
 *
 * The mode is remembered across sessions in ~/.pi/agent/permissions.json
 * (only the mode is stored, not individual approvals). To override it for a
 * single session, start pi with --permission-mode <mode>.
 *
 * Prompts are also debounced against user activity: a permission prompt is not
 * shown until the prompt window has been quiet — no text typed — for a set
 * amount of time (3s after typing, 1s after submitting a prompt), so approval
 * dialogs don't interrupt you while you are still typing.
 */

import type {
  ExtensionAPI,
  ExtensionContext,
  Theme,
} from "@earendil-works/pi-coding-agent";
import { parseColor } from "@earendil-works/pi-tui";
import { readFileSync, writeFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

type Mode = "relaxed" | "balanced" | "careful" | "strict";

const MODES: Mode[] = ["relaxed", "balanced", "careful", "strict"];

/** Tools that need permission in each mode (empty = all allowed, "*" = everything). */
const GATED: Record<Mode, string[] | "*"> = {
  relaxed: [],
  balanced: ["write", "edit"],
  careful: ["bash", "write", "edit"],
  strict: "*",
};

const DEFAULT_MODE: Mode = "balanced";

const MODE_COLOR: Record<Mode, string> = {
  strict: "#4ade4f",
  careful: "#f97316",
  balanced: "#eab308",
  relaxed: "#ef4444",
};

/** Quiet time (ms) in the prompt window after typing before showing a prompt. */
const TYPE_IDLE_MS = 3000;

/** Quiet time (ms) after a prompt was submitted before showing a prompt. */
const SUBMIT_IDLE_MS = 1000;

/** Human-readable description of what requires permission in a mode. */
function gatedLabel(mode: Mode): string {
  const gated = GATED[mode];
  if (gated === "*") return "everything needs permission";
  return gated.length > 0
    ? `only ${gated.join(", ")} need${gated.length === 1 ? "s" : ""} permission`
    : "nothing needs permission";
}

function settingsPath(): string {
  return join(homedir(), ".pi", "agent", "permissions.json");
}

function loadMode(): Mode {
  try {
    const raw = readFileSync(settingsPath(), "utf8");
    const parsed = JSON.parse(raw) as { mode?: string };
    const m = parsed.mode as Mode | undefined;
    if (m && MODES.includes(m)) return m;
  } catch {
    // missing or unreadable file -> default
  }
  return DEFAULT_MODE;
}

function saveMode(mode: Mode): void {
  try {
    writeFileSync(settingsPath(), JSON.stringify({ mode }, null, "\t") + "\n");
  } catch {
    // non-fatal; mode just won't persist
  }
}

/** Argument keys whose value is the file path a tool call targets. */
const PATH_KEYS = ["path", "file_path", "filepath", "file"];

/** The file path a tool call targets, if any. */
function filePath(input: Record<string, unknown>): string | undefined {
  for (const key of PATH_KEYS) {
    const value = input[key];
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  return undefined;
}

/**
 * Build the title of the tool permission prompt:
 * "Accept tool?" with the file path (if any) appended in dim gray.
 */
function promptTitle(name: string, input: unknown, theme: Theme): string {
  const path = filePath((input ?? {}) as Record<string, unknown>);
  const label = `Accept ${name}?`;
  return path ? `${label} ${theme.fg("dim", path)}` : label;
}

/** Max visible lines for rendered text before truncation. */
const MAX_LINES = 5;
/** Max characters for rendered text before truncation. */
const MAX_CHARS = 1024;

/**
 * Render text in the theme's text color, truncated when it exceeds MAX_LINES
 * lines or MAX_CHARS characters (whichever limit is hit first). The omitted
 * remainder is reported in a warning-colored notice line.
 */
function truncateText(text: string, theme: Theme): string {
  const lines = text.split("\n");

  const kept: string[] = [];
  let used = 0;
  for (let i = 0; i < Math.min(lines.length, MAX_LINES); i++) {
    if (used + lines[i].length > MAX_CHARS) break;
    kept.push(lines[i]);
    used += lines[i].length + 1; // +1 for the newline between lines
  }

  const keptText = kept.join("\n");
  const omittedLines = lines.length - kept.length;
  const omittedChars = text.length - keptText.length;

  if (omittedLines === 0 && omittedChars === 0) {
    return theme.fg("text", keptText);
  }

  const parts: string[] = [];
  if (omittedLines > 0)
    parts.push(`+${omittedLines} line${omittedLines === 1 ? "" : "s"}`);
  if (omittedChars > 0)
    parts.push(`+${omittedChars} char${omittedChars === 1 ? "" : "s"}`);
  const notice = parts.join(", ");
  const truncated = theme.fg("warning", `[${notice} truncated]`);
  return keptText ? `${theme.fg("text", keptText)}\n${truncated}` : truncated;
}

/**
 * Build the message body for the tool permission prompt.
 *
 * Shell tools: the command, rendered via truncateText. Empty line between the
 * title and the command comes from joining title and message in the caller.
 *
 * Other tools: no message.
 */
function promptMessage(name: string, input: unknown, theme: Theme): string {
  const i = (input ?? {}) as Record<string, unknown>;
  if (name === "bash" || name === "powershell") {
    const raw = String(i.command ?? i.cmd ?? "").trim();
    return raw ? truncateText(raw, theme) : "";
  }
  return "";
}

export default function (pi: ExtensionAPI) {
  let mode = loadMode();

  // Editor-changes-only detection for permission-prompt debouncing: keystrokes
  // used to answer a dialog never register as activity. TUI mode only.
  type PromptActivity = { at: number; kind: "typed" | "submitted" };
  let lastActivity: PromptActivity = { at: 0, kind: "typed" };
  // The editor clear on submit is the submit itself, not new typing.
  let expectSubmitClear = false;

  // Session-scoped polling: currentCtx is refreshed on every session_start and
  // the timer is torn down in session_shutdown, so it never touches a
  // context that was invalidated by session replacement or reload.
  let currentCtx: ExtensionContext | undefined;
  let activityTimer: NodeJS.Timeout | undefined;
  const stopActivityTracking = () => {
    if (activityTimer) {
      clearInterval(activityTimer);
      activityTimer = undefined;
    }
  };
  const ensureActivityTracking = (ctx: ExtensionContext) => {
    currentCtx = ctx;
    stopActivityTracking();
    if (ctx.mode !== "tui") return;
    let lastEditorText = ctx.ui.getEditorText();
    activityTimer = setInterval(() => {
      try {
        if (!currentCtx) return;
        const text = currentCtx.ui.getEditorText();
        if (text === lastEditorText) return;
        lastEditorText = text;
        if (expectSubmitClear && text === "") {
          expectSubmitClear = false;
          return;
        }
        expectSubmitClear = false;
        lastActivity = { at: Date.now(), kind: "typed" };
      } catch {
        // Stale ctx after session replacement: wait for a fresh session_start.
      }
    }, 100);
    activityTimer.unref?.();
  };

  // A submitted prompt restarts the quiet window with SUBMIT_IDLE_MS.
  pi.on("input", () => {
    lastActivity = { at: Date.now(), kind: "submitted" };
    expectSubmitClear = true;
  });

  /** Hold the prompt back until the quiet window has elapsed. */
  const waitForQuietPrompt = async (ctx: ExtensionContext) => {
    ensureActivityTracking(ctx);
    if (ctx.mode !== "tui") return;

    let waiting = false;
    const quietMs = () =>
      lastActivity.kind === "submitted" ? SUBMIT_IDLE_MS : TYPE_IDLE_MS;
    while (Date.now() - lastActivity.at < quietMs()) {
      if (!waiting) {
        waiting = true;
        ctx.ui.setWorkingMessage("Permission prompt deferred while typing...");
      }
      await new Promise<void>((resolve) => setTimeout(resolve, 100));
    }
    if (waiting) ctx.ui.setWorkingMessage();
  };

  // --permission-mode <mode>: for this session only (not persisted).
  pi.registerFlag("permission-mode", {
    description:
      "Permission mode for this session: relaxed | balanced | careful | strict",
    type: "string",
  });
  const flagMode = pi.getFlag("permission-mode");
  if (typeof flagMode === "string" && MODES.includes(flagMode as Mode)) {
    mode = flagMode as Mode;
  }

  /** Footer status showing the mode and which tools require permission. */
  const statusText = (ctx: ExtensionContext) => {
    const theme = ctx.ui.theme;
    const gated = GATED[mode];
    let require: string;
    if (gated === "*") {
      require = "all tools require permission";
    } else if (gated.length === 0) {
      require = "no tools require permission";
    } else {
      const names =
        gated.length <= 2
          ? gated.join(" and ")
          : `${gated.slice(0, -1).join(", ")} and ${gated[gated.length - 1]}`;
      require = `${names} require${gated.length === 1 ? "s" : ""} permission`;
    }
    const label = theme.fg("text", "permissions:");
    const modeText = theme.style(mode, { fg: parseColor(MODE_COLOR[mode]) });
    const detail = theme.fg("dim", `(${require})`);
    return `${label} ${modeText} ${detail}`;
  };

  const updateStatus = (ctx: ExtensionContext) =>
    ctx.ui.setStatus("permission-gate", statusText(ctx));

  pi.on("session_start", (_event, ctx) => {
    updateStatus(ctx);
    ensureActivityTracking(ctx);
  });

  // Stop the poller so the old context is never used after
  // session replacement or reload.
  pi.on("session_shutdown", () => {
    stopActivityTracking();
    currentCtx = undefined;
  });

  pi.registerCommand("permissions", {
    description: `Show the permission mode picker. Modes: ${MODES.join(" | ")}`,
    handler: async (_args, ctx) => {
      const theme = ctx.ui.theme;
      const options = MODES.map(
        (m) =>
          `${theme.style(m, { fg: parseColor(MODE_COLOR[m]) })}  ${theme.fg("dim", gatedLabel(m))}`,
      );

      const choice = await ctx.ui.select(`Permission mode (${mode})`, options);
      const index = typeof choice === "string" ? options.indexOf(choice) : -1;
      const selected = index >= 0 ? MODES[index] : undefined;
      if (!selected) return;

      // Ask whether the change should persist beyond this session.
      const scope = await ctx.ui.select(
        `How long should "${selected}" mode stay active?`,
        [`this session only`, `set as default`],
      );

      mode = selected;
      const modeName = theme.style(mode, {
        fg: parseColor(MODE_COLOR[mode]),
      });
      const isDefault = scope?.startsWith("set as default");
      if (isDefault) {
        saveMode(mode);
        ctx.ui.notify(`Permission mode: ${modeName} (new default)`, "info");
      } else {
        ctx.ui.notify(
          `Permission mode: ${modeName} (this session only)`,
          "info",
        );
      }
      updateStatus(ctx);
    },
  });

  pi.on("tool_call", async (event, ctx) => {
    const gated = GATED[mode];
    if (gated !== "*" && !gated.includes(event.toolName)) return undefined;

    await waitForQuietPrompt(ctx);

    if (!ctx.hasUI) {
      return {
        block: true,
        reason:
          `Permission required for "${event.toolName}" but no UI is available ` +
          `(non-interactive mode). Start with --permission-mode relaxed (or another mode) to bypass.`,
      };
    }

    const theme = ctx.ui.theme;
    const title = promptTitle(event.toolName, event.input, theme);
    const message = promptMessage(event.toolName, event.input, theme);

    // Let ping.ts (and anything else listening) know a permission is requested.
    // Core's ui_prompt_start is intentionally not pinged, so this fires it here.
    pi.events.emit("ping:input", { source: "permission-gate", tool: event.toolName });

    const choice = await ctx.ui.select(
      message ? `${title}\n\n${message}` : title,
      ["accept", "reject with reason", "abort"],
    );
    if (choice === "accept") return undefined;

    if (choice === "reject with reason") {
      let reason: string | undefined;
      while (!reason?.trim()) {
        reason = await ctx.ui.input("Reason for rejection", "enter a reason");
        if (reason === undefined) break;
        if (!reason.trim()) {
          ctx.ui.notify("Please provide a rejection reason", "warning");
        }
      }
      if (reason?.trim()) {
        return { block: true, reason: `Rejected by user: ${reason.trim()}` };
      }
    }

    ctx.abort();
  });
}
