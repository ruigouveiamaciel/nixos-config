import { randomInt } from "node:crypto";
import EventEmitter from "node:events";
import { access } from "node:fs/promises";
import { createConnection, Socket } from "node:net";
import { Mutex } from "../mutex";

type QemuQgaSocketEvents = {
  ready: [];
  message: [unknown];
  error: [Error];
};

export class QemuQgaSocket extends EventEmitter<QemuQgaSocketEvents> {
  private socket?: Socket;
  private receivedMessages: unknown[] = [];
  private lock = new Mutex();
  private destroyed = false;

  public constructor(args: { path: string; timeout: number }) {
    super();

    setImmediate(async () => {
      let errored = false;
      let timeOutTimer = setTimeout(() => {
        if (!this.socket)
          this.emit(
            "error",
            new Error(
              `Connecting to QGA socket timed out after ${args.timeout}ms`,
            ),
          );
      }, args.timeout);

      this.once("error", () => {
        clearTimeout(timeOutTimer);
        errored = true;
      });

      while (!errored) {
        try {
          await access(args.path);
          continue;
        } catch {
          await new Promise((resolve) => setTimeout(resolve, 1_000));
        }

        try {
          const syncId = randomInt(0, 2 ** 31);
          const socket = createConnection(args.path, () => {
            if (errored) {
              socket.destroy();
            } else {
              socket.write(
                JSON.stringify({
                  execute: "guest-sync",
                  arguments: {
                    id: syncId,
                  },
                }) + "\n",
              );
            }
          });

          this.once("error", () => socket.destroy());

          socket.once("close", (hadError) => {
            if (!hadError && !errored && !this.destroyed) {
              this.emit("error", new Error("QGA socket closed prematurely"));
            }
          });

          socket.once("error", (error) => this.emit("error", error));

          let buffer = "";

          socket.on("data", (chunk) => {
            try {
              buffer += chunk.toString("utf8");
              let newlineIndex: number;

              while ((newlineIndex = buffer.indexOf("\n")) !== -1) {
                const line = buffer.slice(0, newlineIndex);
                buffer = buffer.slice(newlineIndex + 1);
                const msg = JSON.parse(line);

                if (this.socket) {
                  this.receivedMessages.push(msg);
                  this.emit("message", msg);
                } else if (
                  msg instanceof Object &&
                  "return" in msg &&
                  msg.return === syncId
                ) {
                  this.socket = socket;
                  this.emit("ready");
                }
              }
            } catch (e) {
              if (this.socket) {
                this.emit(
                  "error",
                  e instanceof Error ? e : new Error(String(e)),
                );
              }
            }
          });

          await new Promise((resolve) => setTimeout(resolve, 1_000));
          break;
        } catch (e) {
          this.emit("error", e instanceof Error ? e : Error(String(e)));
          return;
        }
      }
    });
  }

  public async write(args: {
    payload: unknown;
    timeout?: number;
  }): Promise<unknown> {
    if (!this.socket) {
      throw new Error(
        "Failed to write on the QGA socket, the socket is not ready",
      );
    }

    const release = await this.lock.acquire();

    this.socket?.write(JSON.stringify(args.payload) + "\n");
    const result = await this.read({ timeout: args.timeout ?? 5_000 });

    release();

    return result;
  }

  private async read(args: { timeout: number }): Promise<unknown> {
    if (this.receivedMessages.length > 0) {
      return this.receivedMessages.shift();
    }

    return await new Promise((resolve, reject) => {
      let timer: NodeJS.Timeout;

      const onMessage = () => {
        clearTimeout(timer);
        this.off("message", onMessage);
        resolve(this.receivedMessages.shift());
      };

      timer = setTimeout(() => {
        this.off("message", onMessage);
        reject(
          new Error(
            `Writing to the QGA socket timed out after ${args.timeout}ms`,
          ),
        );
      }, args.timeout);

      this.once("message", onMessage);

      if (this.receivedMessages.length > 0) {
        onMessage();
      }
    });
  }

  public destroy() {
    this.destroyed = true;
    this.socket?.destroy();
  }
}
