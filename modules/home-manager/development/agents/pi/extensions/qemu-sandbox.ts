import {
  BashOperations,
  isBashToolResult,
  isPowerShellToolResult,
  type ToolResultEvent,
  createBashToolDefinition,
  createEditToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
  EditOperations,
  WriteOperations,
  type ExtensionAPI,
  type ReadOperations,
  type ToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { parseColor } from "@earendil-works/pi-tui";
import { readFile } from "node:fs/promises";
import { tmpdir, userInfo } from "node:os";
import path from "node:path";
import { Sandbox, SandboxStatus } from "../utils/sandbox/sandbox";
import { type TSchema } from "typebox/type";
import { shellQuote } from "../utils/sandbox/shell-quote";

/** Status label colors (palette mirrors permission-gate's mode colors). */
const STATUS_COLOR: Record<SandboxStatus, string> = {
  [SandboxStatus.STARTING]: "#eab308", // in progress
  [SandboxStatus.READY]: "#4ade4f", // good
  [SandboxStatus.CLOSED]: "#ef4444", // bad
};

const IMAGE_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
]);

function createBashOps(sandbox: Sandbox): BashOperations {
  return {
    exec: async (command, cwd, { onData, signal, timeout }) => {
      if (signal?.aborted) throw new Error("aborted");
      const res = await sandbox.execCommand({
        command,
        cwd,
        timeout: timeout ? timeout * 1000 : undefined,
        signal,
      });
      const output = res.stdout;
      if (output) onData(Buffer.from(output));
      return { exitCode: res.exitCode };
    },
  };
}

function createReadOps(sandbox: Sandbox): ReadOperations {
  return {
    readFile: async (path) => await sandbox.readFile(path),
    access: async (path) => {
      const { exitCode } = await sandbox.execCommand({
        command: `test -r ${shellQuote(path)}`,
        timeout: 5_000,
      });
      if (exitCode !== 0) throw new Error(`File is not readable: ${path}`);
    },
    detectImageMimeType: async (path) => {
      try {
        const { stdout } = await sandbox.execCommand({
          command: `file --mime-type -b ${shellQuote(path)}`,

          timeout: 5_000,
        });
        const mime = stdout.trim();
        return IMAGE_MIME_TYPES.has(mime) ? mime : null;
      } catch {
        return null;
      }
    },
  };
}

function createWriteOps(sandbox: Sandbox): WriteOperations {
  return {
    writeFile: async (path, content) => {
      await sandbox.writeFile({
        content: Buffer.from(content, "utf8"),
        path,
      });
    },
    mkdir: async (dir) => {
      const { exitCode } = await sandbox.execCommand({
        command: `mkdir -p ${shellQuote(dir)}`,
        timeout: 5_000,
      });
      if (exitCode !== 0) throw new Error(`Failed to create directory: ${dir}`);
    },
  };
}

function createEditOps(sandbox: Sandbox): EditOperations {
  return {
    readFile: (path) => sandbox.readFile(path),
    writeFile: async (path, content) => {
      await sandbox.writeFile({
        content: Buffer.from(content, "utf8"),
        path,
      });
    },
    access: async (path) => {
      const { exitCode } = await sandbox.execCommand({
        command: `test -r ${shellQuote(path)} && test -w ${shellQuote(path)} `,
        timeout: 5_000,
      });
      if (exitCode !== 0)
        throw new Error(`File is not readable/writable: ${path}`);
    },
  };
}

/** Type guard for custom tools' result details (MCP tools carry `details: unknown`). */
function hasFullOutputPath(details: unknown): details is { fullOutputPath: string } {
  return (
    typeof details === "object" && details !== null && "fullOutputPath" in details &&
    typeof (details as Record<string, unknown>).fullOutputPath === "string"
  );
}

/**
 * The host temp file holding the full (untruncated) output of a tool result, if any.
 * Only returns absolute paths inside the OS temp directory, so nothing else from the host
 * is ever mirrored into the sandbox. Does not parse result content: paths come exclusively
 * from the result's structured `details`.
 */
function extractFullOutputPath(event: ToolResultEvent): string | undefined {
  let hostPath: string | undefined;
  if (isBashToolResult(event) || isPowerShellToolResult(event)) {
    // details: BashToolDetails, with truncation set only when output was actually truncated.
    const details = event.details;
    if (details?.truncation?.truncated && details.fullOutputPath)
      hostPath = details.fullOutputPath;
  } else if (hasFullOutputPath(event.details)) {
    // Custom tools (MCP `mcp__*` and others pi wraps the same way): they set
    // details.fullOutputPath only when their output was truncated and saved to a file.
    hostPath = event.details.fullOutputPath;
  }

  if (!hostPath || !path.isAbsolute(hostPath)) return undefined;
  // `resolve` norms away `..`/`.` segments (purely lexical, no fs access), so e.g.
  // `/tmp/../etc/shadow` resolves to `/etc/shadow` and fails the temp-dir check.
  const resolvedHostPath = path.resolve(hostPath);
  if (!resolvedHostPath.startsWith(`${tmpdir()}/`)) return undefined;
  return resolvedHostPath;
}

/**
 * Copy a host file into the sandbox VM. Mirroring at the same absolute path keeps the
 * `Full output: <path>` reference from the tool result valid inside the sandbox.
 */
async function mirrorFileToSandbox(sandbox: Sandbox, hostPath: string): Promise<void> {
  const content = await readFile(hostPath);
  const { exitCode, stdout } = await sandbox.execCommand({
    command: `mkdir -p ${shellQuote(path.dirname(hostPath))}`,
    timeout: 5_000,
  });
  if (exitCode !== 0) throw new Error(stdout);
  await sandbox.writeFile({ content, path: hostPath });
}

export default function (pi: ExtensionAPI) {
  let sb: Sandbox | undefined;
  let sandboxEnabled = true;

  const localCwd = process.cwd();
  const localBash = createBashToolDefinition(localCwd);
  const localRead = createReadToolDefinition(localCwd);
  const localWrite = createWriteToolDefinition(localCwd);
  const localEdit = createEditToolDefinition(localCwd);

  function sandboxTool<TParams extends TSchema, TDetails, TState>(
    local: ToolDefinition<TParams, TDetails, TState>,
    makeRemote: (
      cwd: string,
      sandbox: Sandbox,
    ) => ToolDefinition<TParams, TDetails, TState>,
  ): ToolDefinition<TParams, TDetails, TState> {
    return {
      ...local,
      async execute(toolCallId, params, signal, onUpdate, ctx) {
        if (!sandboxEnabled)
          return local.execute(toolCallId, params, signal, onUpdate, ctx);

        const sandbox = sb;
        if (!sandbox) throw new Error("Sandbox is not initialized");
        await sandbox.ensureSandbox();

        const sandboxCtx: typeof ctx = Object.create(ctx, {
          cwd: { value: sandbox.cwd },
        });

        return makeRemote(sandbox.cwd, sandbox).execute(
          toolCallId,
          params,
          signal,
          onUpdate,
          sandboxCtx,
        );
      },
    };
  }

  pi.registerTool(
    sandboxTool(localBash, (cwd, sb) =>
      createBashToolDefinition(cwd, { operations: createBashOps(sb) }),
    ),
  );
  pi.registerTool(
    sandboxTool(localRead, (cwd, sb) =>
      createReadToolDefinition(cwd, { operations: createReadOps(sb) }),
    ),
  );
  pi.registerTool(
    sandboxTool(localWrite, (cwd, sb) =>
      createWriteToolDefinition(cwd, { operations: createWriteOps(sb) }),
    ),
  );
  pi.registerTool(
    sandboxTool(localEdit, (cwd, sb) =>
      createEditToolDefinition(cwd, { operations: createEditOps(sb) }),
    ),
  );

  pi.registerFlag("no-sandbox", {
    description: "Run commands on the host instead of in the sandboxed QEMU VM",
    type: "boolean",
    default: false,
  });

  // After each tool call, mirror the temp file that holds truncated output into the VM so the
  // model can read it: the `Full output: <path>` reference in the result becomes valid in-sandbox.
  pi.on("tool_result", async (event: ToolResultEvent, ctx) => {
    if (!sandboxEnabled || !sb) return;

    const hostPath = extractFullOutputPath(event);
    if (!hostPath) return;

    try {
      await mirrorFileToSandbox(sb, hostPath);
    } catch (error) {
      ctx.ui.notify(
        `Could not mirror truncated tool output into the sandbox: ${
          error instanceof Error ? error.message : String(error)
        }`,
        "warning",
      );
    }
  });

  pi.on("session_start", async (_event, ctx) => {
    sandboxEnabled = !pi.getFlag("no-sandbox");
    if (!sandboxEnabled) return;

    sb = new Sandbox({
      cwd: ctx.cwd,
      user: userInfo().username,
      group: String(userInfo().uid),
    });

    sb.on("status", function updateStatusLabel(status: SandboxStatus) {
      const theme = ctx.ui.theme;
      const label = SandboxStatus[status].toLowerCase();
      const statusText = theme.style(label, {
        fg: parseColor(STATUS_COLOR[status]),
      });

      ctx.ui.setStatus("sandbox", `sandbox: ${statusText}`);
    });

    sb.once("error", (error) => {
      ctx.ui.notify(
        error.name === "Error" ? error.message : String(error),
        "error",
      );
    });
  });

  pi.on("before_agent_start", async (event, ctx) => {
    if (!sandboxEnabled || !sb) return undefined;

    event.systemPromptOptions.sections.sandbox_environment = [
      "You are running inside a sandboxed QEMU virtual machine, not directly on the host.",
      "- All tool commands (bash, read, write, edit) execute inside this VM, isolated from the host OS.",
      `- \`$PWD\` (currently ${sb.cwd}) is bind-mounted from the host: files created or changed there persist to the host. Everything else in the VM is ephemeral and wiped when the session ends.`,
      "- Host paths do not exist inside the VM; never access files outside `$PWD`.",
      "- The VM runs NixOS, trimmed down relative to the host system: some tools available on the host may be absent. Verify (`uname -a`, command -v) instead of assuming host facts.",
      "- `/tmp` is an unrestricted scratch box (exempt from the read/write/edit permission gate): use it for throwaway scripts, fixtures, and prototypes. Copy anything worth keeping under `$PWD` — `/tmp` is wiped when the session ends.",
      "- Truncated tool output is saved to a temp file (e.g. `Full output: /tmp/pi-bash-….log`) mirrored into the VM at the same path, so the reference is readable.",
    ].join("\n");

    return undefined;
  });

  pi.on("session_shutdown", async (_event, _ctx) => {
    const sandbox = sb;
    sb = undefined;
    if (sandbox) {
      sandbox.on("error", () => {});
      await sandbox.destroy();
      sandbox.removeAllListeners();
    }
  });
}
