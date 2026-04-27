import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// Guarded by edit-guard extension
const QUIT_COMMANDS = new Set([
  // quit
  ":q",
  ":quit",
  ":q!",
  ":quit!",
  // quit all
  ":qa",
  ":qall",
  ":qa!",
  ":qall!",
  // write & quit
  ":wq",
  ":wq!",
  ":x",
  ":xit",
  ":exit",
  ":ex",
  ":x!",
  // write all & quit all
  ":wqa",
  ":wqall",
  ":wqa!",
  ":wqall!",
  ":xa",
  ":xall",
  ":xa!",
  ":xall!",
  // quit with error code
  ":cq",
]);

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    if (QUIT_COMMANDS.has(event.text.toLowerCase().trim())) {
      ctx.shutdown();
      return { action: "handled" };
    }
    return { action: "continue" };
  });
}
