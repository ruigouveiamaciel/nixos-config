import { ExtensionContext } from "@mariozechner/pi-coding-agent";
import { lstatSync } from "node:fs";
import { homedir } from "node:os";
import { resolve, normalize, isAbsolute, basename, dirname } from "node:path";
import { minimatch } from "minimatch";

function matchesGlob(path: string, pattern: string): boolean {
  return minimatch(path, pattern, { dot: true });
}

function expandHome(path: string): string {
  if (path.startsWith("~/")) {
    return resolve(homedir(), path.slice(2));
  }

  return path;
}

type AccessMode = "read" | "write" | "readwrite";
type PermissionAction = "allow" | "deny" | "ask";

interface FilesystemPermissionRule {
  globs: string[];
  access: AccessMode;
  action: PermissionAction;
  reason?: string;
}

const FILESYSTEM_PERMISSION_RULES: FilesystemPermissionRule[] = (
  [
    {
      globs: ["~/Library/Caches/pnpm/**", "~/.cache/pnpm/**"],
      access: "read",
      action: "allow",
      reason: "can contain useful documentation.",
    },
    {
      globs: ["/var/folders/**"],
      access: "read",
      action: "ask",
      reason: "can contain tool outputs.",
    },
    {
      globs: ["~/.pi/agent/auth.json", "~/.ssh/id_*"],
      access: "readwrite",
      action: "deny",
      reason: "contains credentials.",
    },
    {
      globs: ["**/node_modules/**"],
      access: "write",
      action: "deny",
      reason: "never modify node_modules directly.",
    },
    {
      globs: ["**/.git/**"],
      access: "write",
      action: "deny",
      reason: "never modify .git directly.",
    },
    {
      globs: ["~/.pi/agent/**"],
      access: "read",
      action: "allow",
    },
    {
      globs: ["~/.pi/agent/**"],
      access: "write",
      action: "deny",
      reason:
        "pi agent configuration is now stored in the NixOS configuration, usually on: /persist/nixos-config/ or ~/repos/nixos-config/",
    },
    {
      globs: ["~/repos/**", "~/projects/**", "/persist/nixos-config/**"],
      access: "readwrite",
      action: "allow",
    },
    {
      globs: ["/tmp/**"],
      access: "readwrite",
      action: "ask",
      reason: "temporary files can contain sensitive information temporarily.",
    },
  ] satisfies FilesystemPermissionRule[]
).map((rule) => ({
  ...rule,
  globs: rule.globs.map(expandHome).map(normalize),
}));

const FILENAME_PERMISSION_RULES: FilesystemPermissionRule[] = (
  [
    {
      globs: ["~/Library/Caches/pnpm/**", "~/.cache/pnpm/**"],
      access: "read",
      action: "allow",
      reason: "can contain useful documentation.",
    },
    {
      globs: ["~/.pi/agent/skills/**"],
      access: "read",
      action: "allow",
      reason: "allow reading skills.",
    },
    {
      globs: ["**/"],
      access: "read",
      action: "allow",
    },
    {
      globs: [
        "**/*.nix",
        "**/*.md",
        "**/*.txt",
        "**/*.html",
        "**/*.css",
        "**/*.scss",
        "**/*.sass",
        "**/*.rs",
        "**/*.go",
        "**/*.java",
        "**/*.c",
        "**/*.cpp",
        "**/*.h",
        "**/*.hpp",
        "**/*.svg",
        "**/*.ts",
        "**/*.tsx",
        "**/*.js",
        "**/*.jsx",
        "**/*.mjs",
        "**/*.py",
      ],
      access: "read",
      action: "allow",
    },
  ] satisfies FilesystemPermissionRule[]
).map((rule) => ({
  ...rule,
  globs: rule.globs.map(expandHome).map(normalize),
}));

const SESSION_FILESYSTEM_PERMISSION_RULES: FilesystemPermissionRule[] = [];
const SESSION_FILENAME_PERMISSION_RULES: FilesystemPermissionRule[] = [];

function resolvePath(args: { path: string; cwd: string }): string {
  const expandedPath = normalize(expandHome(args.path));
  const absolutePath = isAbsolute(expandedPath)
    ? expandedPath
    : resolve(expandHome(args.cwd), expandedPath);

  try {
    if (lstatSync(absolutePath).isDirectory()) {
      return absolutePath + "/";
    }
  } catch {}

  return absolutePath;
}

function resolveRuleSet(args: {
  path: string;
  cwd: string;
  rules: FilesystemPermissionRule[];
}): FilesystemPermissionRule | undefined {
  const path = resolvePath({ path: args.path, cwd: args.cwd });

  return args.rules.find((rule) =>
    rule.globs.some((glob) => matchesGlob(path, glob)),
  );
}

function isAccessAllowed(args: {
  path: string;
  cwd: string;
  access: AccessMode;
}): { action: PermissionAction; reason?: string } {
  const accessFilter = [
    "readwrite",
    args.access !== "readwrite" ? args.access : undefined,
  ].filter(Boolean);

  const matchFilesystem = resolveRuleSet({
    path: args.path,
    cwd: args.cwd,
    rules: [
      ...SESSION_FILESYSTEM_PERMISSION_RULES,
      ...FILESYSTEM_PERMISSION_RULES,
    ].filter((rule) => accessFilter.includes(rule.access)),
  });

  if (matchFilesystem && matchFilesystem.action !== "allow") {
    return {
      action: matchFilesystem.action,
      reason: matchFilesystem.reason,
    };
  } else if (!matchFilesystem) {
    const allowedPaths = FILESYSTEM_PERMISSION_RULES.filter((rule) =>
      accessFilter.includes(rule.access),
    )
      .filter((rule) => rule.action === "allow" || rule.action === "ask")
      .flatMap((rule) => rule.globs)
      .map((x) => "- " + x)
      .join("\n");

    return {
      action: "deny",
      reason: "it lies outside the allowed directories:\n\n" + allowedPaths,
    };
  }

  const matchFilename = resolveRuleSet({
    path: args.path,
    cwd: args.cwd,
    rules: [
      ...SESSION_FILENAME_PERMISSION_RULES,
      ...FILENAME_PERMISSION_RULES,
    ].filter((rule) => accessFilter.includes(rule.access)),
  });

  if (matchFilename) {
    return {
      action: matchFilename.action,
      reason: matchFilename.reason,
    };
  }

  return {
    action: "ask",
    reason: "untrusted file.",
  };
}

export function isReadAllowed(args: { path: string; cwd: string }): {
  action: PermissionAction;
  reason?: string;
} {
  return isAccessAllowed({ ...args, access: "read" });
}

export function isWriteAllowed(args: { path: string; cwd: string }): {
  action: PermissionAction;
  reason?: string;
} {
  return isAccessAllowed({ ...args, access: "write" });
}

export function getGlobSuggestions(args: { path: string; cwd: string }) {
  const path = resolvePath({ path: args.path, cwd: args.cwd });

  const name = basename(path);
  const extensions: string[] = [];
  let idx = name.indexOf(".", name.startsWith(".") ? 1 : 0);
  while (idx !== -1) {
    extensions.unshift(name.slice(idx));
    idx = name.indexOf(".", idx + 1);
  }

  const dirs: string[] = [];
  let current = dirname(path);
  while (current !== dirname(current)) {
    dirs.push(current);
    current = dirname(current);
  }
  dirs.push(current);

  return [
    path,
    ...["", ...extensions].map((ext) => resolve(dirs[0], "*" + ext)),
    ...dirs
      .map((dir) =>
        ["", extensions].map((ext) => resolve(dir, ext ? "**/*" + ext : "**")),
      )
      .flat(),
  ].filter((x) => isReadAllowed({ path: x, cwd: args.cwd }).action !== "deny");
}

export function allowSessionFilename(args: {
  glob: string;
  access: AccessMode;
}): void {
  SESSION_FILENAME_PERMISSION_RULES.unshift({
    globs: [args.glob],
    access: args.access,
    action: "allow",
    reason: "always allowed in this session.",
  });
}

export function allowSessionFilesystem(args: {
  glob: string;
  access: AccessMode;
}): void {
  SESSION_FILESYSTEM_PERMISSION_RULES.unshift({
    globs: [args.glob],
    access: args.access,
    action: "allow",
    reason: "always allowed in this session.",
  });
}

export async function handlePathPermissionCheck(args: {
  path: string;
  access: AccessMode;
  ctx: ExtensionContext;
}) {
  const permission =
    args.access === "read"
      ? isReadAllowed({ path: args.path, cwd: args.ctx.cwd })
      : isWriteAllowed({ path: args.path, cwd: args.ctx.cwd });

  const gerund = args.access === "read" ? "reading" : "editing";

  if (permission.action === "deny") {
    return {
      block: true,
      reason: [`${gerund} ${args.path} is blocked`, permission.reason].join(
        ` — `,
      ),
    };
  } else if (permission.action === "ask") {
    if (!args.ctx.hasUI) {
      return {
        block: true,
        reason: `${gerund} ${args.path} is blocked — no UI available to grant permission.`,
      };
    }

    const options = ["Yes", "Yes, allow edits during this session", "No"];

    const selectedOption = await args.ctx.ui.select(
      `Allow ${gerund}? Reason: ${permission.reason || "None provided."}\n${args.path}`,
      options,
    );

    if (!selectedOption) {
      return args.ctx.abort();
    } else if (selectedOption === options[2]) {
      const reason = await args.ctx.ui.input(
        `Deny reason?`,
        "Leave empty to deny silently",
      );

      return { block: true, reason: reason?.trim() || undefined };
    } else if (selectedOption === options[1]) {
      const suggestedGlob = getGlobSuggestions({
        path: args.path,
        cwd: args.ctx.cwd,
      });
      const selectedGlob = await args.ctx.ui.select(
        "What should be allowed this session?",
        suggestedGlob,
      );

      if (selectedGlob) {
        allowSessionFilename({
          glob: selectedGlob,
          access: args.access === "read" ? "read" : "readwrite",
        });
      } else {
        return args.ctx.abort();
      }
    }
  }
}
