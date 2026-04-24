import { isMatch } from "matcher";
import { parse, type Node } from "unbash";
import { expandHome } from "./filesystem-guard-helpers";

type PermissionAction = "allow" | "deny" | "ask";

interface BashPermissionRule {
  commands: string[];
  argsGlobs: string[];
  action: PermissionAction;
  reason?: string;
  yolable?: boolean;
}

const BASH_PERMISSION_RULES: BashPermissionRule[] = [
  // Skills

  {
    commands: ["~/.pi/agent/skills/atlassian/atlassian.sh"].map(expandHome),
    argsGlobs: ["*"],
    action: "ask",
    yolable: true,
  },
  {
    commands: [
      "~/.pi/agent/skills/web-search/search.sh",
      "~/.pi/agent/skills/nix-search/nix-search.sh",
    ].map(expandHome),
    argsGlobs: ["*"],
    action: "ask",
    reason: "network operation — remote content can carry prompt injection.",
  },

  // Privilege escalation.
  {
    commands: ["sudo", "su", "doas", "pkexec"],
    argsGlobs: ["*"],
    action: "deny",
    reason:
      "privilege escalation is not allowed, ask the user to run these commands manually if they're required to complete the task.",
  },

  // Disk / filesystem destruction.
  {
    commands: [
      "dd",
      "mkfs",
      "fdisk",
      "parted",
      "diskutil",
      "shred",
      "wipefs",
      "blkdiscard",
      "mount",
      "umount",
    ],
    argsGlobs: ["*"],
    action: "deny",
    reason: "disk / filesystem modification is not allowed.",
  },

  // System power / init.
  {
    commands: ["reboot", "shutdown", "halt", "poweroff", "init"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "system power / init control is not allowed.",
  },

  // macOS system / security configuration.
  {
    commands: [
      "csrutil",
      "spctl",
      "kextload",
      "kextunload",
      "launchctl",
      "tmutil",
    ],
    argsGlobs: ["*"],
    action: "deny",
    reason: "macOS system / security configuration is not allowed.",
  },

  // Versions
  {
    commands: [
      "node",
      "bun",
      "deno",
      "npm",
      "yarn",
      "pnpm",
      "npx",
      "pnpx",
      "bunx",
      "cargo",
      "rustc",
      "rustup",
      "python",
      "python3",
      "pip",
      "pip3",
      "uv",
      "pipx",
      "poetry",
      "git",
      "go",
      "make",
      "cmake",
      "ninja",
      "nix",
      "docker",
      "podman",
    ],
    argsGlobs: ["-v", "--version", "version"],
    action: "allow",
  },

  {
    commands: ["rm", "rmdir"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "destructive file operation.",
    yolable: true,
  },
  {
    commands: ["chown", "chmod"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "permission change.",
  },
  {
    commands: ["kill", "killall", "pkill"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "process termination is not allowed.",
  },
  {
    commands: ["patch"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "`patch` command is not allowed — use the `edit` tool instead.",
  },

  {
    commands: ["curl", "wget", "rsync"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "network operation — remote content can carry prompt injection.",
  },

  // Nested shells
  {
    commands: ["bash", "sh", "zsh", "fish", "dash", "ash"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "nested shell — bypasses this guard's per-command parsing.",
  },
  {
    commands: ["eval", "source", ".", "exec"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "dynamic execution.",
  },

  // sed / awk
  {
    commands: ["sed", "awk", "gawk", "nawk"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "sed / awk is not allowed.",
  },

  // open browser and other stuff
  {
    commands: ["open"],
    argsGlobs: ["*"],
    action: "ask",
  },

  // VCS — remote fetches can carry prompt injection; hooks execute code.
  {
    commands: ["git"],
    argsGlobs: ["status *", "add *", "rm *", "log *"],
    action: "allow",
  },
  {
    commands: ["git"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "version control operation — remote content + hook execution.",
  },

  // Language runtimes — execute arbitrary scripts (potentially injected).
  {
    commands: [
      "node",
      "deno",
      "bun",
      "python",
      "python3",
      "ruby",
      "perl",
      "lua",
      "php",
      "tsx",
      "ts-node",
    ],
    argsGlobs: ["*"],
    action: "ask",
    reason: "language runtime — executes arbitrary code.",
    yolable: true,
  },

  // Package managers — fetch and execute remote code.
  {
    commands: [
      "npm",
      "pnpm",
      "yarn",
      "npx",
      "pnpx",
      "bunx",
      "pip",
      "pip3",
      "uv",
      "pipx",
      "poetry",
    ],
    argsGlobs: ["*"],
    action: "ask",
    reason:
      "package manager — fetches remote code and can execute install scripts.",
    yolable: true,
  },

  // Compilers & build tools — execute arbitrary build scripts.
  {
    commands: [
      "cargo",
      "rustc",
      "rustup",
      "go",
      "tsc",
      "make",
      "cmake",
      "ninja",
    ],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Linters / formatters / test runners
  {
    commands: ["eslint", "prettier", "vitest", "rustfmt", "gofmt"],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Nix — `nix run` / `nix shell` execute code; rebuilds mutate the system.
  {
    commands: [
      "nix",
      "nix-build",
      "nix-shell",
      "nix-env",
      "nix-store",
      "nix-instantiate",
      "nixos-rebuild",
      "darwin-rebuild",
      "home-manager",
      "nom",
    ],
    argsGlobs: ["*"],
    action: "ask",
    reason: "Nix tooling — can execute code and mutate system config.",
  },

  // Containers
  {
    commands: ["docker", "podman", "docker-compose", "compose"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "manipulating container runtime is not allowed",
  },

  // Archives
  {
    commands: ["tar", "zip", "unzip", "gzip", "xz", "unxz", "zstd", "unzstd"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "archive / compression",
  },

  // Wrappers
  {
    commands: ["xargs"],
    argsGlobs: ["*"],
    action: "ask",
    yolable: true,
  },

  // Filesystem metadata & navigation.
  {
    commands: [
      "ls",
      "pwd",
      "which",
      "wc",
      "stat",
      "file",
      "basename",
      "dirname",
      "readlink",
      "realpath",
      "seq",
      "date",
      "uptime",
      "uname",
      "man",
      "exit",
    ],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Shell primitives & environment queries.
  {
    commands: [
      "echo",
      "true",
      "false",
      "test",
      "env",
      "printenv",
      "sleep",
      "hostname",
      "whoami",
      "id",
      "groups",
      "tty",
      "logname",
    ],
    argsGlobs: ["*"],
    action: "allow",
  },

  // File inspection
  {
    commands: ["cat", "head", "tail", "hexdump"],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Search
  {
    commands: ["grep", "rg", "fd", "tree"],
    argsGlobs: ["*"],
    action: "allow",
  },
  {
    commands: ["find"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "`find` is not allowed, use `fd` instead.",
  },

  // Text processing
  {
    commands: ["sort", "uniq", "join", "column", "fold", "nl", "rev", "tee"],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Comparison
  {
    commands: ["diff"],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Structured data queries
  {
    commands: ["jq"],
    argsGlobs: ["*"],
    action: "allow",
  },

  // File / directory creation
  {
    commands: ["mkdir", "touch", "cp", "mv"],
    argsGlobs: ["*"],
    action: "ask",
    yolable: true,
  },

  // Process inspection
  {
    commands: ["ps", "pgrep", "lsof", "top", "htop", "pstree"],
    argsGlobs: ["*"],
    action: "ask",
  },
];

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
        allPatterns: true,
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

  for (const command of parsed) {
    const match = resolveRuleSet({
      command,
      rules: BASH_PERMISSION_RULES,
    });

    if (!match) {
      return {
        action: "deny",
        reason: "one or more commands in this script is not whitelisted.",
      };
    } else if (match.action !== "allow") {
      return {
        action: match.action,
        reason: match.reason,
      };
    }
  }

  return {
    action: "allow",
  };
}
