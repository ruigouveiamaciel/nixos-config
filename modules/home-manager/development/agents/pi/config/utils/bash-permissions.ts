import { homedir } from "node:os";

export type PermissionAction = "allow" | "deny" | "ask";

export interface BashPermissionRule {
  commands: string[];
  argsGlobs: string[];
  action: PermissionAction;
  reason?: string;
}

export const BASH_PERMISSION_RULES: BashPermissionRule[] = [
  // Skills
  {
    commands: [`${homedir()}/.pi/agent/skills/atlassian/atlassian.sh`],
    argsGlobs: ["*"],
    action: "ask",
  },
  {
    commands: [
      `${homedir()}/.pi/agent/skills/web-search/search.sh`,
      `${homedir()}/.pi/agent/skills/nix-search/nix-search.sh`,
    ],
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
    action: "ask",
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
  },

  // Compilers & build tools — write build artifacts to disk + execute
  // arbitrary build scripts. No sandbox → confirm before mutating the FS.
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
    action: "ask",
    reason: "build tool — writes artifacts and runs arbitrary build scripts.",
  },

  // Linters / formatters / test runners — many rewrite files in place
  // (`prettier --write`, `rustfmt`, `gofmt -w`, `eslint --fix`, vitest snapshots).
  {
    commands: ["eslint", "prettier", "vitest", "rustfmt", "gofmt"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "linter/formatter — may rewrite files in place.",
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
  {
    commands: ["nix-prefetch-url", "nix-prefetch-git", "nix-prefetch-github"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "network operation — fetches remote content to compute its hash.",
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
  },

  // Filesystem metadata & navigation.
  {
    commands: [
      "cd",
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

  // Environment dumps — process env often holds API tokens, AWS keys, etc.
  {
    commands: ["env", "printenv"],
    argsGlobs: ["*"],
    action: "ask",
    reason:
      "environment dump — may expose secrets stored in env vars (API tokens, credentials).",
  },

  // File inspection — can dump arbitrary file contents (e.g. ~/.ssh/id_*,
  //   ~/.aws/credentials, .env). Warn before reading.
  {
    commands: ["cat", "head", "tail", "hexdump"],
    argsGlobs: ["*"],
    action: "ask",
    reason:
      "file content read — may expose secrets (SSH keys, .env, credentials, tokens).",
  },

  // Hashing — pure local compute over files / stdin.
  {
    commands: [
      "shasum",
      "sha1sum",
      "sha256sum",
      "sha512sum",
      "md5sum",
      "md5",
      "cksum",
      "b2sum",
    ],
    argsGlobs: ["*"],
    action: "allow",
  },

  // Path-only search — lists names, does not read file contents.
  {
    commands: ["fd", "tree"],
    argsGlobs: ["*"],
    action: "allow",
  },
  {
    commands: ["find"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "`find` is not allowed, use `fd` instead.",
  },

  // Content search — reads file contents and prints matching lines, which
  //   may include secrets if pointed at config / dotfile dirs.
  {
    commands: ["rg"],
    argsGlobs: ["*"],
    action: "ask",
    reason:
      "content search — may expose secrets in matched lines (.env, configs, history files).",
  },
  {
    commands: ["grep"],
    argsGlobs: ["*"],
    action: "deny",
    reason: "`grep` is not allowed, use `rg` instead.",
  },

  // Text processing — pipeline-friendly, do not modify FS by default.
  //   (`tee` is excluded: it writes files.)
  {
    commands: ["sort", "uniq", "join", "column", "fold", "nl", "rev"],
    argsGlobs: ["*"],
    action: "allow",
  },

  // `tee` writes to files — filesystem modification.
  {
    commands: ["tee"],
    argsGlobs: ["*"],
    action: "ask",
    reason: "writes to files — filesystem modification.",
  },

  // Comparison — reads both inputs in full; may surface secrets.
  {
    commands: ["diff"],
    argsGlobs: ["*"],
    action: "ask",
    reason:
      "file comparison — may expose secrets from either side of the diff.",
  },

  // Structured data queries — typically run over config files that contain
  //   tokens / keys / credentials.
  {
    commands: ["jq"],
    argsGlobs: ["*"],
    action: "ask",
    reason:
      "reads structured files — may expose secrets in JSON configs / credential stores.",
  },

  // File / directory creation
  {
    commands: ["mkdir", "touch", "cp", "mv"],
    argsGlobs: ["*"],
    action: "ask",
  },

  // Process inspection
  {
    commands: ["ps", "pgrep", "lsof", "top", "htop", "pstree"],
    argsGlobs: ["*"],
    action: "ask",
  },
];
