import { ChildProcessWithoutNullStreams, spawn } from "node:child_process";
import EventEmitter from "node:events";
import { chmod, mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { QemuQgaSocket } from "./qemu-qga-socket-helper";
import { shellQuote } from "./shell-quote";

const PATH = "PATH=/run/current-system/sw/bin";

export enum SandboxStatus {
  STARTING,
  READY,
  CLOSED,
}

type SandboxEvents = {
  ready: [];
  status: [SandboxStatus];
  error: [Error];
  close: [];
};

export class Sandbox extends EventEmitter<SandboxEvents> {
  private sandboxProcess?: ChildProcessWithoutNullStreams;
  private tempDir?: string;
  private status: SandboxStatus = SandboxStatus.STARTING;
  private socket?: QemuQgaSocket;
  private destroyed = false;
  public readonly cwd: string;
  public readonly user: string;
  public readonly group: string;

  public constructor(args: { cwd: string; user: string; group: string }) {
    super();

    this.cwd = args.cwd;
    this.user = args.user;
    this.group = args.group;

    setImmediate(async () => {
      try {
        this.emit("status", this.status);

        this.tempDir = await mkdtemp(path.join(tmpdir(), "sandbox-"));
        await chmod(this.tempDir, "700");
        const qgaSocketPath = path.join(this.tempDir, "qga.sock");

        this.sandboxProcess = spawn(
          "bash",
          ["-c", "~/.nix-profile/bin/run-sandbox-vm"],
          {
            detached: true,
            stdio: "pipe",
            env: {
              NIX_DISK_IMAGE: path.join(this.tempDir, "root.qcow2"),
              SHARED_WORKSPACE_DIR: this.cwd,
              QEMU_OPTS: [
                `-chardev socket,id=qga0,path=${qgaSocketPath},server=on,wait=off`,
                "-device virtio-serial",
                "-device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0",
              ].join(" "),
            },
          },
        );

        this.once("error", async () => await this.destroy());

        this.sandboxProcess.once("error", (error) => this.emit("error", error));

        this.sandboxProcess.once("exit", (code, signal) => {
          if (this.destroyed) return;
          if (code !== null) {
            this.emit("error", new Error(`Sandbox exited with code: ${code}`));
          }
          if (signal !== null) {
            this.emit(
              "error",
              new Error(`Sandbox exited with signal: ${signal}`),
            );
          }
        });

        this.socket = new QemuQgaSocket({
          path: qgaSocketPath,
          timeout: 30_000,
        });

        this.socket.once("error", (error) => {
          if (!this.destroyed) this.emit("error", error);
        });

        this.socket.once("ready", async () => {
          try {
            const socket = this.socket;
            if (!socket) throw new Error("Sandbox QGA socket is not available");

            await this.execCommandRoot({
              command: [
                "bash",
                "-c",
                "mkdir -p $1 && sudo mount --bind $0 $1",
                "/workspace",
                this.cwd,
              ],
              timeout: 30_000,
            });

            this.status = SandboxStatus.READY;
            this.emit("status", this.status);
          } catch (e) {
            this.emit("error", e instanceof Error ? e : new Error(String(e)));
          }
        });
      } catch (e) {
        this.emit("error", e instanceof Error ? e : new Error(String(e)));
      }
    });
  }

  public async ensureSandbox(): Promise<void> {
    switch (this.status) {
      case SandboxStatus.READY:
        return;
      case SandboxStatus.CLOSED:
        throw new Error("Sandbox is already closed");
    }

    await new Promise<void>((resolve, reject) => {
      const cleanup = () => {
        this.off("status", onStatus);
        this.off("error", onError);
      };

      const onStatus = (status: SandboxStatus) => {
        if (status === SandboxStatus.READY) {
          cleanup();
          resolve();
        } else if (status === SandboxStatus.CLOSED) {
          cleanup();
          reject(new Error("Sandbox closed prematurely"));
        }
      };

      const onError = (error: Error) => {
        cleanup();
        reject(error);
      };

      this.on("status", onStatus);
      this.on("error", onError);

      onStatus(this.status);
    });
  }

  public async debugQga(payload: object) {
    return await this.socket?.write({
      payload,
    });
  }

  private sanitizeQgaResponse(message: unknown): unknown {
    if (message instanceof Object) {
      if ("error" in message && message.error instanceof Object) {
        if ("class" in message.error && "desc" in message.error) {
          throw new Error(`${message.error.class}; ${message.error.desc}`);
        }
      } else if ("return" in message) {
        return message.return;
      }
    }
    throw new Error(`Unknown QGA error; received message: ${message}`);
  }

  public async writeFile(args: { content: Buffer; path: string }) {
    await this.ensureSandbox();

    const socket = this.socket;
    if (!socket) throw new Error("Sandbox QGA socket is not available");

    const filePath = path.isAbsolute(args.path)
      ? args.path
      : path.join(this.cwd, args.path);

    const chunkSize = 4 * 1024 * 1024; // 4 MiB

    for (let offset = 0; offset < args.content.length; offset += chunkSize) {
      const chunk = args.content.subarray(
        offset,
        Math.min(offset + chunkSize, args.content.length),
      );

      const bufB64 = Buffer.from(chunk).toString("base64");

      const { exitCode, stdout } = await this.execCommand({
        command: `echo ${shellQuote(bufB64)} | base64 -d ${offset === 0 ? ">" : ">>"} ${shellQuote(filePath)}`,
        timeout: 15_000,
      });

      if (exitCode !== 0) {
        throw new Error(stdout);
      }
    }
  }

  public async readFile(path: string): Promise<Buffer> {
    await this.ensureSandbox();

    const socket = this.socket;
    if (!socket) throw new Error("Sandbox QGA socket is not available");

    const fileHandle = this.sanitizeQgaResponse(
      await socket.write({
        payload: {
          execute: "guest-file-open",
          arguments: {
            path,
            mode: "r",
          },
        },
      }),
    );

    if (typeof fileHandle !== "number") {
      throw new Error(
        `QGA command "guest-file-open" did not return an handle; response: ${JSON.stringify(fileHandle)}`,
      );
    }

    const chunks: Buffer[] = [];
    let eof = false;

    try {
      while (!eof) {
        const readOp = this.sanitizeQgaResponse(
          await socket.write({
            payload: {
              execute: "guest-file-read",
              arguments: {
                handle: fileHandle,
              },
            },
          }),
        );

        if (
          readOp instanceof Object &&
          "eof" in readOp &&
          "count" in readOp &&
          typeof readOp.count === "number" &&
          "buf-b64" in readOp &&
          typeof readOp["buf-b64"] === "string"
        ) {
          const chunk = Buffer.from(readOp["buf-b64"], "base64");
          if (chunk.length !== readOp.count) {
            throw new Error(
              `QGA command "guest-file-read" did not returned ${readOp.count} bytes, but ${chunk.length} bytes were decoded`,
            );
          }

          chunks.push(chunk);
          eof = Boolean(readOp.eof);
        } else {
          throw new Error(
            `QGA command "guest-file-read" did not return a valid response; response: ${JSON.stringify(readOp)}`,
          );
        }
      }

      return Buffer.concat(chunks);
    } finally {
      this.sanitizeQgaResponse(
        await socket.write({
          payload: {
            execute: "guest-file-close",
            arguments: {
              handle: fileHandle,
            },
          },
        }),
      );
    }
  }

  private async execCommandRoot(args: {
    command: string[];
    timeout?: number;
    signal?: AbortSignal;
  }) {
    const socket = this.socket;
    if (!socket) throw new Error("Sandbox QGA socket is not available");

    if (args.command.length === 0) throw new Error("No command provided");

    if (args.timeout && args.timeout <= 0) {
      throw new Error("Timeout must be at least 1 second");
    }

    if (args.timeout && !Number.isFinite(args.timeout)) {
      throw new Error("Timeout must be a finite number");
    }

    if (args.timeout && args.timeout > 2 ** 31) {
      throw new Error("Timeout is too big");
    }

    const results = this.sanitizeQgaResponse(
      await socket.write({
        payload: {
          execute: "guest-exec",
          arguments: {
            path: args.command[0],
            arg: args.command.slice(1),
            "capture-output": "merged",
            env: [PATH],
          },
        },
      }),
    );

    let pid: number;
    if (
      results instanceof Object &&
      "pid" in results &&
      typeof results.pid === "number"
    ) {
      pid = results.pid;
    } else {
      throw new Error(
        `QGA command "guest-exec" did not return a valid pid; response: ${JSON.stringify(results)}`,
      );
    }

    return await this.waitExecStatus({
      pid,
      timeout: args.timeout,
      signal: args.signal,
    });
  }

  private async waitExecStatus(args: {
    pid: number;
    timeout?: number;
    signal?: AbortSignal;
  }) {
    const socket = this.socket;
    if (!socket) throw new Error("Sandbox QGA socket is not available");

    const stdout: Buffer[] = [];
    const deadline = args.timeout
      ? Date.now() + Math.max(args.timeout, 10_000)
      : undefined;
    let exited = false;
    let exitCode: number | null = null;

    while (!exited) {
      if (args.signal?.aborted) {
        this.sanitizeQgaResponse(
          await socket.write({
            payload: {
              execute: "guest-exec",
              arguments: {
                path: "bash",
                arg: ["-c", "kill", "-9", String(args.pid)],
                "capture-output": "merged",
                env: [PATH],
              },
            },
          }),
        );
        throw new Error("Command aborted");
      }
      if (deadline && Date.now() > deadline) {
        this.sanitizeQgaResponse(
          await socket.write({
            payload: {
              execute: "guest-exec",
              arguments: {
                path: "bash",
                arg: ["-c", "kill", "-9", String(args.pid)],
                "capture-output": "merged",
                env: [PATH],
              },
            },
          }),
        );
        throw new Error(`Command timed out after ${args.timeout}ms`);
      }

      const status = this.sanitizeQgaResponse(
        await socket.write({
          payload: {
            execute: "guest-exec-status",
            arguments: {
              pid: args.pid,
            },
          },
        }),
      );

      if (status instanceof Object && "exited" in status) {
        if (!status.exited) {
          await new Promise((resolve) => setTimeout(resolve, 100));
          continue;
        } else {
          exited = true;

          if ("out-truncated" in status && status["out-truncated"]) {
            throw new Error(
              `QGA command "guest-exec-status" returned truncated out-data when it was not expected; response: ${JSON.stringify(status)}`,
            );
          }

          if ("out-data" in status) {
            if (typeof status["out-data"] === "string") {
              stdout.push(Buffer.from(status["out-data"], "base64"));
            } else {
              throw new Error(
                `QGA command "guest-exec-status" did not return a valid out-data; response: ${JSON.stringify(status)}`,
              );
            }
          }
        }

        if ("signal" in status && status.signal) {
          throw new Error("Command was killed");
        }

        if ("exitcode" in status && typeof status.exitcode === "number") {
          exitCode = status.exitcode;
        }
      } else {
        throw new Error(
          `QGA command "guest-exec-status" did not return a valid response; response: ${JSON.stringify(status)}`,
        );
      }
    }

    return {
      stdout: Buffer.concat(stdout).toString("utf8"),
      exitCode,
    };
  }

  public async execCommand(args: {
    command: string;
    timeout?: number;
    signal?: AbortSignal;
    cwd?: string;
  }) {
    await this.ensureSandbox();

    const socket = this.socket;
    if (!socket) throw new Error("Sandbox QGA socket is not available");

    const script = `
      __pi_out=$(mktemp 2>/dev/null)
      (
        cd -- "$0" && exec runuser -u "$1" -- bash -lc "$2"
      ) >"$__pi_out" 2>&1
      __pi_rc=$?
      echo "$__pi_out"
      exit $__pi_rc
    `;

    const { stdout, ...rest } = await this.execCommandRoot({
      command: [
        "bash",
        "-c",
        script,
        args.cwd ?? this.cwd,
        this.user,
        args.command,
      ],
      signal: args.signal,
      timeout: args.timeout,
    });

    if (stdout.split("\n").length !== 2) {
      throw new Error(
        `QGA command "guest-exec" did not return a valid path in out-data; response: ${JSON.stringify(stdout)}`,
      );
    }

    const outFile = stdout.split("\n")[0];

    return {
      ...rest,
      stdout: (await this.readFile(outFile)).toString("utf8"),
    };
  }

  public async destroy() {
    if (this.destroyed) return;
    this.destroyed = true;
    this.status = SandboxStatus.CLOSED;
    this.emit("status", this.status);

    try {
      if (this.sandboxProcess?.pid && this.sandboxProcess.exitCode === null) {
        try {
          process.kill(-this.sandboxProcess.pid);
        } catch {}
      }
      this.socket?.destroy();
      if (this.tempDir) {
        await rm(this.tempDir, {
          recursive: true,
          force: true,
          maxRetries: 3,
          retryDelay: 1000,
        });
      }
    } finally {
      this.emit("close");
    }
  }
}
