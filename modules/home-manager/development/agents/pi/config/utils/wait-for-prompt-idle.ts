import type { ExtensionContext } from "@mariozechner/pi-coding-agent";

/**
 * Helpers to defer interactive permission prompts while the user is busy
 * composing a steering / follow-up message in the input editor.
 *
 * Rationale: pi can request permission mid-turn (bash-guard, filesystem-guard,
 * etc.). If a prompt overlay pops up while the user is mid-sentence, focus is
 * stolen and partially-typed text is easy to lose. We instead wait for the
 * editor to settle: either the user submits / clears it, or they stop typing
 * for long enough that interrupting them is acceptable.
 */

/** Time of no edits after which it's acceptable to interrupt the user. */
const IDLE_MS = 15_000;

/** How often we re-read the editor to look for changes. */
const POLL_MS = 1_000;

function readEditor(ctx: ExtensionContext): string {
  try {
    return ctx.ui.getEditorText() ?? "";
  } catch {
    // In non-interactive contexts (print mode, RPC where unsupported) the
    // shim returns "" or throws. Either way: treat as empty so we never block.
    return "";
  }
}

function isEmpty(text: string): boolean {
  return text.trim().length === 0;
}

const sleep = (ms: number) =>
  new Promise<void>((resolve) => setTimeout(resolve, ms));

/**
 * Resolve once it's polite to interrupt the user with a permission prompt.
 *
 * Behaviour:
 *  - editor empty right now              → resolve immediately
 *  - editor has content                  → poll every {@link POLL_MS}:
 *      • editor becomes empty            → resolve
 *      • text unchanged for {@link IDLE_MS} → resolve (idle)
 *      • text changed                    → reset the idle timer
 *
 * Never throws. Designed to be a transparent "wait gate" inserted before
 * `ctx.ui.select(...)` / `ctx.ui.confirm(...)` in permission guards.
 */
export async function waitForPromptIdle(ctx: ExtensionContext): Promise<void> {
  // Fast path: nothing in the editor — go ahead and prompt.
  if (isEmpty(readEditor(ctx))) return;

  let lastText = readEditor(ctx);
  let lastChangeAt = Date.now();

  while (true) {
    await sleep(POLL_MS);

    const current = readEditor(ctx);

    if (isEmpty(current)) return;

    if (current !== lastText) {
      lastText = current;
      lastChangeAt = Date.now();
    } else if (Date.now() - lastChangeAt >= IDLE_MS) {
      return;
    }
  }
}
