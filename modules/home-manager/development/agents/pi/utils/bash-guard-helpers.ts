import { parse } from "unbash";

type PermissionAction = "allow" | "deny" | "ask";

interface BashPermissionRule {
  commands: string[];
  argsGlobs: string[];
  action: PermissionAction;
  reason?: string;
}

const BASH_PERMISSION_RULES: BashPermissionRule[] = [
  {
    commands: ["sudo", "su", "doas", "pkexec"],
    argsGlobs: ["*"],
    action: "deny",
    reason:
      "privilege escalation is not allowed, ask the user to run these commands manually if they're required to complete the task.",
  },
  {
    commands: ["dd", "mkfs", "fdisk", "parted"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "disk modification is not allowed.",
  },
  {
    commands: ["rm", "rmdir"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "destructive file operation.",
  },
  {
    commands: [
      "curl",
      "wget",
      "scp",
      "sftp",
      "ftp",
      "nc",
      "netcat",
      "telnet",
      "ssh",
    ],
    argsGlobs: ["*"],
    action: "ask",
    reason: "network operation.",
  },
  {
    commands: ["bash", "sh", "zsh", "fish"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "nested shell.",
  },
  {
    commands: ["eval", "source", "."],
    argsGlobs: ["*"],
    action: "ask",
    reason: "dynamic execution.",
  },
  {
    commands: ["chown", "chmod"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "permission change.",
  },
  {
    commands: [
      "node",
      "bun",
      "npm",
      "yarn",
      "pnpm",
      "cargo",
      "rustc",
      "python",
      "python3",
      "git",
      "pip",
      "pip3",
    ],
    argsGlobs: ["-v", "--version"],
    action: "allow",
  },
  {
    commands: ["go", "git"],
    argsGlobs: ["version"],
    action: "allow",
  },
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
];

export function isBashAllowed(args: { command: string; pwd: string }): {
  action: PermissionAction;
  reason?: string;
} {
  return { action: "ask" };
}
