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

/** Quiet time (ms) in the prompt editor after typing before showing a prompt. */
const TYPE_IDLE_MS = 3000;

/** Quiet time (ms) after a prompt was submitted before showing a prompt. */
const SUBMIT_IDLE_MS = 1000;

/** How often the editor is polled for typing activity. */
const ACTIVITY_POLL_MS = 100;

const isMode = (value: string | undefined): value is Mode =>
  MODES.includes(value as Mode);

function settingsPath(): string {
  return join(homedir(), ".pi", "agent", "permissions.json");
}

function loadMode(): Mode {
  try {
    const parsed = JSON.parse(readFileSync(settingsPath(), "utf8")) as {
      mode?: string;
    };
    if (isMode(parsed.mode)) return parsed.mode;
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

/** Human-readable description of what needs permission in a mode. */
function gatedLabel(mode: Mode): string {
  if (GATED[mode] === "*") return "needs permission: everything";
  const gated = GATED[mode];
  if (gated.length === 0) return "needs permission: nothing";
  return `needs permission: ${gated.join(", ")}`;
}

// -- Prompt rendering --------------------------------------------------------

/** Argument keys whose value is the file path a tool call targets. */
const PATH_KEYS = ["path", "file_path", "filepath", "file"];

/** First non-empty string value among the given keys of a tool input. */
function firstString(input: unknown, keys: string[]): string {
  const record = (input ?? {}) as Record<string, unknown>;
  for (const key of keys) {
    const value = record[key];
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  return "";
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
  const allLines = text.split("\n");
  const lines = allLines.slice(0, MAX_LINES);

  const kept: string[] = [];
  let used = 0; // chars kept, +1 per line for the join separator
  for (const line of lines) {
    if (used + line.length > MAX_CHARS) break;
    kept.push(line);
    used += line.length + 1;
  }

  const keptText = kept.join("\n");
  const omittedLines = allLines.length - kept.length;
  const omittedChars = text.length - keptText.length;

  if (omittedLines === 0 && omittedChars === 0) {
    return theme.fg("text", keptText);
  }

  const parts: string[] = [];
  if (omittedLines > 0)
    parts.push(`+${omittedLines} line${omittedLines === 1 ? "" : "s"}`);
  if (omittedChars > 0)
    parts.push(`+${omittedChars} char${omittedChars === 1 ? "" : "s"}`);
  const notice = theme.fg("warning", `[${parts.join(", ")} truncated]`);
  return keptText ? `${theme.fg("text", keptText)}\n${notice}` : notice;
}

/**
 * Build the full text of the tool permission prompt: an "Accept tool?" title
 * with the file path (if any) appended in dim gray; for shell tools, the
 * command appended as a truncated message block.
 */
function buildPrompt(name: string, input: unknown, theme: Theme): string {
  const title = `Accept ${name}?`;
  const path = firstString(input, PATH_KEYS);
  const head = path ? `${title} ${theme.fg("dim", path)}` : title;
  if (name !== "bash" && name !== "powershell") return head;
  const command = firstString(input, ["command", "cmd"]);
  return command ? `${head}\n\n${truncateText(command, theme)}` : head;
}

// -- Extension ---------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  let mode = loadMode();

  // --permission-mode <mode>: for this session only (not persisted).
  pi.registerFlag("permission-mode", {
    description:
      "Permission mode for this session: relaxed | balanced | careful | strict",
    type: "string",
  });
  const flagMode = pi.getFlag("permission-mode");
  if (typeof flagMode === "string" && isMode(flagMode)) mode = flagMode;

  // Debounce: poll the prompt editor, and only prompt once it has been quiet
  // for a while. Polling editor text (rather than listening for keystrokes) is
  // deliberate: keys pressed to answer a dialog must not register as activity.
  // A new submit always restarts the quiet window via the "input" event; an
  // editor that becomes empty (submit clear, or deleting everything) counts as
  // stopped typing.
  let currentCtx: ExtensionContext | undefined;
  let activityTimer: NodeJS.Timeout | undefined;
  let quietUntil = 0; // absolute time from which a prompt may be shown

  const stopActivityTracking = () => {
    if (activityTimer) {
      clearInterval(activityTimer);
      activityTimer = undefined;
    }
  };

  // Session-scoped: currentCtx is refreshed on every session_start and the
  // timer is torn down in session_shutdown, so it never touches a context
  // that was invalidated by session replacement or reload.
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
        if (text !== "") quietUntil = Date.now() + TYPE_IDLE_MS;
      } catch {
        // Stale ctx after session replacement: wait for a fresh session_start.
      }
    }, ACTIVITY_POLL_MS);
    activityTimer.unref?.();
  };

  // A submitted prompt restarts the quiet window with SUBMIT_IDLE_MS.
  pi.on("input", () => {
    quietUntil = Date.now() + SUBMIT_IDLE_MS;
  });

  /** Hold the prompt back until the quiet window has elapsed. */
  const waitForQuietPrompt = async (ctx: ExtensionContext) => {
    ensureActivityTracking(ctx);
    if (ctx.mode !== "tui" || Date.now() >= quietUntil) return;

    ctx.ui.setWorkingMessage("Permission prompt deferred while typing...");
    while (Date.now() < quietUntil) {
      // The poller keeps pushing quietUntil forward while typing continues,
      // so this loop naturally extends as long as the user is typing.
      await new Promise((resolve) => setTimeout(resolve, ACTIVITY_POLL_MS));
    }
    ctx.ui.setWorkingMessage();
  };

  /** Footer status showing the mode and what needs permission. */
  const statusText = (ctx: ExtensionContext) => {
    const theme = ctx.ui.theme;
    const label = theme.fg("text", "permissions:");
    const modeText = theme.style(mode, { fg: parseColor(MODE_COLOR[mode]) });
    const detail = theme.fg("dim", `(${gatedLabel(mode)})`);
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
      const index = choice ? options.indexOf(choice) : -1;
      const selected = index >= 0 ? MODES[index] : undefined;
      if (!selected) return;

      // Ask whether the change should persist beyond this session.
      const scope = await ctx.ui.select(
        `How long should "${selected}" mode stay active?`,
        ["this session only", "set as default"],
      );
      const isDefault = scope?.startsWith("set as default") ?? false;

      mode = selected;
      if (isDefault) saveMode(mode);
      ctx.ui.notify(
        `Permission mode: ${theme.style(mode, { fg: parseColor(MODE_COLOR[mode]) })}` +
          (isDefault ? " (new default)" : " (this session only)"),
        "info",
      );
      updateStatus(ctx);
    },
  });

  /** Loop until the user enters a non-empty rejection reason or cancels. */
  const askRejectionReason = async (ctx: ExtensionContext) => {
    for (;;) {
      const reason = await ctx.ui.input(
        "Reason for rejection",
        "enter a reason",
      );
      if (reason === undefined) return undefined;
      const trimmed = reason.trim();
      if (trimmed) return trimmed;
      ctx.ui.notify("Please provide a rejection reason", "warning");
    }
  };

  pi.on("tool_call", async (event, ctx) => {
    const gated = GATED[mode];
    if (gated !== "*" && !gated.includes(event.toolName)) return undefined;

    // Checked before debouncing: with no UI there is no editor to wait on.
    if (!ctx.hasUI) {
      return {
        block: true,
        reason:
          `Permission required for "${event.toolName}" but no UI is available ` +
          `(non-interactive mode). Start with --permission-mode relaxed (or another mode) to bypass.`,
      };
    }

    await waitForQuietPrompt(ctx);

    // Let ping.ts (and anything else listening) know a permission is requested.
    // Core's ui_prompt_start is intentionally not pinged, so this fires it here.
    pi.events.emit("ping:input", {
      source: "permission-gate",
      tool: event.toolName,
    });

    const choice = await ctx.ui.select(
      buildPrompt(event.toolName, event.input, ctx.ui.theme),
      ["accept", "reject with reason", "abort"],
    );

    if (choice === "accept") return undefined;

    if (choice === "reject with reason") {
      const reason = await askRejectionReason(ctx);
      if (reason) return { block: true, reason: `Rejected by user: ${reason}` };
    }

    ctx.abort();
  });
}
