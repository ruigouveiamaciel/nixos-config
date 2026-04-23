import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("undo", {
    description: "Revert to just before the last user prompt",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();

      const branch = ctx.sessionManager.getBranch();

      // Walk backwards through the branch to find the most recent prompt
      let targetEntry: (typeof branch)[number] | null = null;
      for (let i = branch.length - 1; i >= 0; i--) {
        const entry = branch[i];
        if (entry.type === "message" && entry.message.role === "user") {
          targetEntry = entry;
          break;
        }
      }

      if (!targetEntry) {
        ctx.ui.notify("Nothing to undo", "error");
        return;
      }

      const result = await ctx.navigateTree(targetEntry.id, {
        summarize: false,
      });

      if (!result.cancelled && result.editorText) {
        ctx.ui.setEditorText(result.editorText);
      }
    },
  });
}
