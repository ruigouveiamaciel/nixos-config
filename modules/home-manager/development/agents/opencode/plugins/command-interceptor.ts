import type { Plugin } from "@opencode-ai/plugin";
import { parse } from "unbash";

export const CommandInterceptorPlugin: Plugin = async ({ client }) => {
  await client.app.log({
    body: {
      service: "command-interceptor",
      level: "info",
      message: "Plugin initialized",
    },
  });

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const ast = parse(output.args.command);

        await client.app.log({
          body: {
            service: "command-interceptor",
            level: "info",
            message: "testing...",
          },
        });
      }
    },
  };
};
