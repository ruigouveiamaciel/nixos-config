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
 *   Footer status line Refreshes fresh after each turn, cached otherwise (2-minute TTL)
 */

import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Type, type Static } from "typebox";
import { Compile } from "typebox/compile";

const USAGE_URL = "https://opencode.ai/zen/go/v1/usage";
const STATUS_TTL_MS = 2 * 60 * 1000;
const REQUEST_TIMEOUT_MS = 10_000;

const UsageWindowSchema = Type.Object({
  status: Type.Union([Type.Literal("ok"), Type.Literal("rate-limited")]),
  percent: Type.Number(),
  resetsAt: Type.String(),
});

const UsageResponseSchema = Type.Object({
  usage: Type.Object({
    rolling: UsageWindowSchema,
    weekly: UsageWindowSchema,
    monthly: UsageWindowSchema,
  }),
});

type UsageWindow = Static<typeof UsageWindowSchema>;
type UsageResponse = Static<typeof UsageResponseSchema>;

const UsageResponseValidator = Compile(UsageResponseSchema);

/** Safely extract auth.json's ["opencode-go"].key without casts. */
function readApiKey(raw: unknown): unknown {
  if (typeof raw !== "object" || raw === null) return undefined;
  if (!("opencode-go" in raw)) return undefined;
  const entry: unknown = raw["opencode-go"];
  if (typeof entry !== "object" || entry === null) return undefined;
  if (!("key" in entry)) return undefined;
  return entry.key;
}

/** Resolve the OpenCode Go API key from pi's auth file. */
async function resolveApiKey(): Promise<string> {
  const authPath = join(homedir(), ".pi", "agent", "auth.json");
  const noKeyError = () =>
    new Error(
      `No OpenCode Go API key found at ${authPath}. Add an "opencode-go" entry with a "key" there.`,
    );

  let raw: unknown;
  try {
    raw = JSON.parse(await readFile(authPath, "utf-8"));
  } catch (error) {
    if (error instanceof Error && "code" in error && error.code === "ENOENT") {
      // A missing file just means the key was never configured.
      throw noKeyError();
    }
    throw new Error(`Cannot read ${authPath}: ${toErrorMessage(error)}`);
  }

  const key = readApiKey(raw);
  if (typeof key === "string" && key.length > 0) return key;
  throw noKeyError();
}

function bar(percent: number, width = 20): string {
  const filled = Math.round(
    (Math.min(100, Math.max(0, percent)) / 100) * width,
  );
  return "█".repeat(filled) + "░".repeat(width - filled);
}

function formatReset(resetsAt: string): string {
  const then = new Date(resetsAt);
  if (Number.isNaN(then.getTime())) return "reset time unknown";

  const ms = then.getTime() - Date.now();
  if (ms <= 0) return "already reset";
  const days = Math.floor(ms / 86_400_000);
  const hours = Math.floor((ms % 86_400_000) / 3_600_000);
  const minutes = Math.floor((ms % 3_600_000) / 60_000);
  const duration =
    days > 0
      ? `${days}d ${hours}h`
      : hours > 0
        ? `${hours}h ${minutes}m`
        : `${minutes}m`;
  const local = then.toLocaleString(undefined, {
    weekday: "long",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
  const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  return `${duration} (${local} ${tz})`;
}

function windowLine(label: string, w: UsageWindow): string {
  const flag = w.status === "rate-limited" ? " [RATE LIMITED]" : "";
  return `${label.padEnd(9)} ${bar(w.percent)} ${String(w.percent).padStart(3)}% used${flag} — resets in ${formatReset(w.resetsAt)}`;
}

/** Footer color for a window: error if rate-limited or >=90%, warning if >=70%. */
function windowStyle(w: UsageWindow): "error" | "warning" | "dim" {
  if (w.status === "rate-limited" || w.percent >= 90) return "error";
  if (w.percent >= 70) return "warning";
  return "dim";
}

/** Message for any thrown value, without assuming it is an Error. */
function toErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  if (typeof error === "string") return error;
  return `Unknown error: ${String(error)}`;
}

function describeHttpStatus(status: number): string {
  if (status === 401 || status === 403)
    return `API key rejected (HTTP ${status})`;
  if (status === 404)
    return "endpoint not found (HTTP 404) — the API may have moved";
  if (status === 429) return "too many requests (HTTP 429)";
  if (status >= 500) return `upstream server error (HTTP ${status})`;
  return `HTTP ${status}`;
}

/** Extract `error` / `error.message` from an error response body. */
function extractError(body: unknown): string | undefined {
  if (typeof body !== "object" || body === null) return undefined;
  if (!("error" in body)) return undefined;
  const err: unknown = body.error;
  if (typeof err === "string") return err;
  if (typeof err !== "object" || err === null) return undefined;
  if (!("message" in err)) return undefined;
  const message: unknown = err.message;
  return typeof message === "string" ? message : undefined;
}

function parseUsage(body: unknown): UsageResponse {
  if (!UsageResponseValidator.Check(body)) {
    const details = UsageResponseValidator.Errors(body)
      .slice(0, 5)
      .map((e) => `${e.instancePath || "(root)"}: ${e.message}`)
      .join("; ");
    throw new Error(
      `Usage endpoint returned unexpected data. Failed constraints: ${details}`,
    );
  }
  return body;
}

export default function (pi: ExtensionAPI) {
  let cachedUsage: { data: UsageResponse; fetchedAt: number } | null = null;
  let inFlight: Promise<UsageResponse> | null = null;
  let statusTimer: ReturnType<typeof setInterval> | null = null;
  let lastCtx: ExtensionContext | null = null;

  /** Fetch usage over the network. */
  async function fetchFromApi(): Promise<UsageResponse> {
    const key = await resolveApiKey();
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
    try {
      const response = await fetch(USAGE_URL, {
        headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
        signal: controller.signal,
      });
      const body: unknown = await response.json().catch(() => null);

      if (!response.ok) {
        const detail = extractError(body);
        throw new Error(
          `OpenCode Go usage request failed: ${detail ? `${detail} — ` : ""}${describeHttpStatus(response.status)}`,
        );
      }
      if (body === null) {
        throw new Error(
          "OpenCode Go usage request failed: response was not valid JSON",
        );
      }
      const parsed = parseUsage(body);
      cachedUsage = { data: parsed, fetchedAt: Date.now() };
      return parsed;
    } catch (error) {
      // Surface timeouts with a readable message; the rest passes through.
      if (error instanceof Error && error.name === "AbortError") {
        throw new Error(
          `OpenCode Go usage request timed out after ${REQUEST_TIMEOUT_MS / 1000}s`,
        );
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }

  /** Fetch usage. Returns cached data when fresh unless force=true; concurrent callers share one request. */
  async function fetchUsage(force = false): Promise<UsageResponse> {
    if (
      !force &&
      cachedUsage &&
      Date.now() - cachedUsage.fetchedAt < STATUS_TTL_MS
    ) {
      return cachedUsage.data;
    }
    if (!inFlight) {
      inFlight = fetchFromApi().finally(() => {
        inFlight = null;
      });
    }
    return inFlight;
  }

  /** Footer: R/W/M percentages, colored by threshold. */
  function footerText(
    ctx: ExtensionContext,
    usage: UsageResponse["usage"],
  ): string {
    const parts: Array<[UsageWindow, "R" | "W" | "M"]> = [
      [usage.rolling, "R"],
      [usage.weekly, "W"],
      [usage.monthly, "M"],
    ];
    return (
      "usage: " +
      parts
        .map(([w, prefix]) =>
          ctx.ui.theme.fg(windowStyle(w), `${prefix}${w.percent}%`),
        )
        .join(" ")
    );
  }

  /** Footer status: refreshed on session start and after each turn; forced fresh on agent_end. */
  const updateStatus = async (ctx: ExtensionContext, force = false) => {
    lastCtx = ctx;
    try {
      const usage = (await fetchUsage(force)).usage;
      ctx.ui.setStatus("usage", footerText(ctx, usage));
    } catch {
      // no key or offline — leave the status slot empty rather than error spam
    }
  };

  const stopTimer = () => {
    if (statusTimer) {
      clearInterval(statusTimer);
      statusTimer = null;
    }
  };

  pi.registerCommand("usage", {
    description:
      "Show OpenCode Go subscription usage (rolling / weekly / monthly)",
    handler: async (_args, ctx) => {
      try {
        const usage = (await fetchUsage(true)).usage;
        ctx.ui.notify(
          [
            windowLine("rolling:", usage.rolling),
            windowLine("weekly:", usage.weekly),
            windowLine("monthly:", usage.monthly),
          ].join("\n"),
          "info",
        );
      } catch (error) {
        ctx.ui.notify(`usage: ${toErrorMessage(error)}`, "error");
      }
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    await updateStatus(ctx);

    stopTimer();
    statusTimer = setInterval(() => {
      if (lastCtx) void updateStatus(lastCtx);
    }, STATUS_TTL_MS);
    statusTimer.unref();
  });

  pi.on("agent_end", async (_event, ctx) => {
    await updateStatus(ctx, true);
  });

  pi.on("session_shutdown", async () => {
    stopTimer();
  });
}
