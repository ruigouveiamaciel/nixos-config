import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";
import { handlePathPermissionCheck } from "../utils/filesystem-guard-helpers";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("read", event) && event.input.path) {
      return await handlePathPermissionCheck({
        path: event.input.path,
        access: "read",
        ctx: ctx,
      });
    }
  });
}
