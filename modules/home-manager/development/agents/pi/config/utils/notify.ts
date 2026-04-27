import { spawn } from "node:child_process";
import { platform } from "node:os";

/**
 * Send a desktop notification on macOS or Linux.
 *
 * - macOS: uses `osascript` to invoke the Notification Center.
 * - Linux: uses `notify-send` (libnotify) if available.
 *
 * Failures are swallowed silently — the notification is purely informational
 * and must never block or break the agent flow.
 */
export function notify(args: { title: string; message: string }): void {
  const os = platform();

  try {
    if (os === "darwin") {
      // Escape double quotes and backslashes for AppleScript string literals.
      const escape = (s: string) => s.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
      const script = `display notification "${escape(args.message)}" with title "${escape(args.title)}" sound name "Glass"`;
      const child = spawn("osascript", ["-e", script], {
        detached: true,
        stdio: "ignore",
      });
      child.on("error", () => {});
      child.unref();
    } else if (os === "linux") {
      // The `sound-name` hint is honored by most freedesktop notification
      // daemons (XDG Sound Naming Spec). "message-new-instant" is the
      // canonical event name for an incoming interactive prompt.
      const child = spawn(
        "notify-send",
        [
          "--hint=string:sound-name:message-new-instant",
          args.title,
          args.message,
        ],
        {
          detached: true,
          stdio: "ignore",
        },
      );
      child.on("error", () => {});
      child.unref();
    }
    // Other platforms: no-op.
  } catch {
    // Never let a notification failure surface.
  }
}
