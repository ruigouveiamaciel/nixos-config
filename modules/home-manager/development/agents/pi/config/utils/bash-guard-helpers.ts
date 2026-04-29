import { isMatch } from "matcher";
import { parse, type Node } from "unbash";
import {
  BASH_PERMISSION_RULES,
  BashPermissionRule,
  PermissionAction,
} from "./bash-permissions";

interface ParsedCommand {
  name: string;
  args: string[];
}

function extractCommands(source: string): ParsedCommand[] {
  const commands: ParsedCommand[] = [];
  const root = parse(source);
  const stack: Array<Node | ReturnType<typeof parse>> = [root];

  while (stack.length > 0) {
    const node = stack.pop();
    if (!node) continue;

    switch (node.type) {
      case "Command":
        if (node.name?.value) {
          commands.push({
            name: node.name.value,
            args: (node.suffix ?? []).map((w) => w.value),
          });
        }
        break;
      case "Script":
      case "Pipeline":
      case "AndOr":
      case "CompoundList":
        stack.push(...node.commands);
        break;
      case "Statement":
        stack.push(node.command);
        break;
      case "If":
        stack.push(node.clause, node.then);
        if (node.else) stack.push(node.else);
        break;
      case "For":
      case "Select":
      case "ArithmeticFor":
      case "Subshell":
      case "BraceGroup":
        stack.push(node.body);
        break;
      case "While":
        stack.push(node.clause, node.body);
        break;
      case "Function":
      case "Coproc":
        stack.push(node.body);
        break;
      case "Case":
        for (const item of node.items) stack.push(item.body);
        break;
      case "TestCommand":
      case "ArithmeticCommand":
        // no nested commands to extract
        break;
      default: {
        const _exhaustive: never = node;
        throw new Error(
          `Unexpected node type: ${(_exhaustive as { type?: string }).type ?? "<unknown>"}`,
        );
      }
    }
  }

  return commands;
}

function resolveRuleSet(args: {
  command: ParsedCommand;
  rules: BashPermissionRule[];
}): BashPermissionRule | undefined {
  return args.rules.find(
    (rule) =>
      rule.commands.includes(args.command.name) &&
      isMatch(args.command.args.join(" "), rule.argsGlobs, {
        caseSensitive: true,
      }),
  );
}

export function isBashAllowed(args: { command: string; pwd: string }): {
  action: PermissionAction;
  reason?: string;
} {
  let parsed: ParsedCommand[];
  try {
    parsed = extractCommands(args.command);
  } catch {
    return { action: "deny", reason: "failed to parse command." };
  }

  if (parsed.length === 0) {
    return { action: "deny", reason: "no command found." };
  }

  let pendingAsk: { action: PermissionAction; reason?: string } | undefined;

  for (const command of parsed) {
    const match = resolveRuleSet({
      command,
      rules: BASH_PERMISSION_RULES,
    });

    if (!match) {
      return {
        action: "deny",
        reason: `\`${command.name}\` is not whitelisted.`,
      };
    }

    if (match.action === "deny") {
      return { action: "deny", reason: match.reason };
    }

    if (match.action === "ask" && !pendingAsk) {
      pendingAsk = { action: "ask", reason: match.reason };
    }
  }

  if (pendingAsk) return pendingAsk;

  return { action: "allow" };
}
