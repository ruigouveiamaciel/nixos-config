/**
 * OpenCode Go Usage Extension
 *
 * Checks the current usage of your OpenCode Go subscription from inside pi,
 * using the official usage endpoint:
 *
 *   GET https://opencode.ai/zen/go/v1/usage  (Authorization: Bearer <key>)
 *
 * The API key is resolved from pi's own auth file:
 *   ~/.pi/agent/auth.json -> ["opencode-go"].key
 *
 * Features:
 *   /usage             Show rolling / weekly / monthly usage and reset times
 *   Footer status line Refreshes after each turn (cached for 2 minutes)
 */

import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const USAGE_URL = "https://opencode.ai/zen/go/v1/usage";
const STATUS_TTL_MS = 2 * 60 * 1000; // footer status cache

type Window = {
  status: "ok" | "rate-limited";
  percent: number;
  resetsAt: string;
};

type UsageResponse = {
  usage: {
    rolling: Window;
    weekly: Window;
    monthly: Window;
  };
};

/** Resolve the OpenCode Go API key from pi's auth file. */
async function resolveApiKey(): Promise<string> {
  const authPath = join(homedir(), ".pi", "agent", "auth.json");
  try {
    const raw = JSON.parse(await readFile(authPath, "utf-8"));
    const key = raw?.["opencode-go"]?.key;
    if (typeof key === "string" && key.length > 0) {
      return key;
    }
  } catch {
    // missing/unreadable file — fall through to the error below
  }
  throw new Error(
    `No OpenCode Go API key found at ${authPath}. Add an "opencode-go" entry with a "key" there.`,
  );
}

let cachedUsage: { data: UsageResponse; fetchedAt: number } | null = null;

/** Fetch usage. Returns cached data when fresh unless force=true. */
async function fetchUsage(force = false): Promise<UsageResponse> {
  if (
    !force &&
    cachedUsage &&
    Date.now() - cachedUsage.fetchedAt < STATUS_TTL_MS
  ) {
    return cachedUsage.data;
  }

  const key = await resolveApiKey();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10_000);
  try {
    const response = await fetch(USAGE_URL, {
      headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
      signal: controller.signal,
    });
    const body = (await response.json().catch(() => null)) as
      UsageResponse | { error?: { message?: string } | string } | null;

    if (!response.ok) {
      const message =
        (typeof body?.error === "string" ? body.error : body?.error?.message) ||
        `HTTP ${response.status}`;
      throw new Error(`OpenCode Go usage request failed: ${message}`);
    }
    if (!body || typeof (body as UsageResponse).usage !== "object") {
      throw new Error("Unexpected response from usage endpoint");
    }

    cachedUsage = { data: body as UsageResponse, fetchedAt: Date.now() };
    return body as UsageResponse;
  } finally {
    clearTimeout(timeout);
  }
}

function bar(percent: number, width = 20): string {
  const filled = Math.round(
    (Math.min(100, Math.max(0, percent)) / 100) * width,
  );
  return "█".repeat(filled) + "░".repeat(width - filled);
}

function formatReset(resetsAt: string): string {
  const then = new Date(resetsAt);
  const ms = then.getTime() - Date.now();
  if (ms <= 0) return "already reset";
  const hours = Math.floor(ms / 3_600_000);
  const minutes = Math.floor((ms % 3_600_000) / 60_000);
  const duration = hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
  return `${duration} (${then.toISOString().slice(0, 16).replace("T", " ")} UTC)`;
}

function windowLine(label: string, w: Window): string {
  const flag = w.status === "rate-limited" ? " ⚠️LIMIT" : "";
  return `${label.padEnd(9)} ${bar(w.percent)} ${String(w.percent).padStart(3)}% used${flag} — resets in ${formatReset(w.resetsAt)}`;
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("usage", {
    description:
      "Show OpenCode Go subscription usage (rolling / weekly / monthly)",
    handler: async (_args, ctx) => {
      try {
        const usage = await fetchUsage(true);
        await ctx.ui.select("OpenCode Go Usage", [
          windowLine("rolling:", usage.usage.rolling),
          windowLine("weekly:", usage.usage.weekly),
          windowLine("monthly:", usage.usage.monthly),
        ]);
      } catch (error) {
        ctx.ui.notify(`usage: ${(error as Error).message}`, "error");
      }
    },
  });

  // Footer status: refreshed on session start and after each turn (cached).
  const updateStatus = async (ctx: ExtensionContext) => {
    try {
      const usage = await fetchUsage();
      const { rolling, weekly, monthly } = usage.usage;
      const styleRolling =
        rolling.status === "rate-limited" || monthly.percent >= 90
          ? "error"
          : rolling.percent >= 70
            ? "warning"
            : "dim";
      const styleWeekly =
        weekly.status === "rate-limited" || monthly.percent >= 90
          ? "error"
          : weekly.percent >= 70
            ? "warning"
            : "dim";
      const styleMonthly =
        monthly.status === "rate-limited" || monthly.percent >= 90
          ? "error"
          : monthly.percent >= 70
            ? "warning"
            : "dim";
      ctx.ui.setStatus(
        "usage",
        [
          "usage: ",
          ctx.ui.theme.fg(styleRolling, `R${rolling.percent}% `),
          ctx.ui.theme.fg(styleWeekly, `W${weekly.percent}% `),
          ctx.ui.theme.fg(styleMonthly, `M${monthly.percent}%`),
        ].join(""),
      );
    } catch {
      // no key or offline — leave the status slot empty rather than error spam
    }
  };

  pi.on("session_start", async (_event, ctx) => {
    await updateStatus(ctx);
  });

  pi.on("agent_end", async (_event, ctx) => {
    await updateStatus(ctx);
  });
}
