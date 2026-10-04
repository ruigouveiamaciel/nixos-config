import {
  BashOperations,
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
import { userInfo } from "node:os";
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
    if (!sandboxEnabled || !sb || ctx.cwd === sb.cwd) return undefined;
    const localLine = ctx.cwd;
    const guestLine = sb.cwd;
    return {
      systemPrompt: event.systemPrompt.replace(localLine, guestLine),
    };
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
