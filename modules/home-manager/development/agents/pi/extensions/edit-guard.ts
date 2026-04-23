import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { handlePathPermissionCheck } from "../utils/filesystem-guard-helpers";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (
      (isToolCallEventType("edit", event) ||
        isToolCallEventType("write", event)) &&
      event.input.path
    ) {
      await handlePathPermissionCheck({
        path: event.input.path,
        access: "write",
        ctx: ctx,
      });
    }
  });
}
