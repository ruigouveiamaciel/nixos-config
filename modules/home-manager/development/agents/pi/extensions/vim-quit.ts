/**
 * vim-quit — muscle memory from vim: typing `:q`, `:wq`, `:qa`, ... in the
 * input box closes pi instead of sending the text to the agent.
 *
 * Matches only exact commands (plus an optional `!` and whitespace), so
 * prompts that merely start with `:q` still go through. Non-interactive
 * input (rpc/extension) is ignored, and { action: "handled" } keeps the
 * command out of the conversation.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const QUIT_COMMANDS = [
  ":q",
  ":q!",
  ":qa",
  ":qa!",
  ":qall",
  ":qall!",
  ":quit",
  ":quit!",
  ":wq",
  ":wq!",
  ":wqall",
  ":wqall!",
  ":x",
  ":x!",
  ":xa",
  ":xa!",
  ":xall",
  ":xall!",
  ":xit",
  ":xit!",
  ":exit",
  ":exit!",
];

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    if (event.source !== "interactive") return;

    if (!QUIT_COMMANDS.includes(event.text.trim().toLowerCase())) return;

    ctx.shutdown();
    return { action: "handled" };
  });
}
