{
  pkgs,
  lib,
  ...
}: let
  version = "0.75.5";

  # pi-coding-agent ships a prebuilt `dist/` and an `npm-shrinkwrap.json`,
  # but its shrinkwrap is missing `integrity` for the sibling
  # @earendil-works/pi-* tarballs. We patch them in before letting
  # `fetchNpmDeps` populate the offline cache.
  integrityFixups = {
    "node_modules/@earendil-works/pi-agent-core" = "sha512-LHygOgsW2pgXKb3IkXkOAeZPovHr9VF+EixgXVsDNuB4jmhEOXgshy/zksZ7slkUAx10OQ9W1Ed/2jsnhd1NqA==";
    "node_modules/@earendil-works/pi-ai" = "sha512-zf1F5kXk1pqZeFShXOqq9ibUk8QdtRoLCDPAjO+hj44e3EUs9/GFO2qnhTC5+JA2uwVCx+WCNe1PiCjlBYWm5w==";
    "node_modules/@earendil-works/pi-tui" = "sha512-LkXUM1/49pvzzeI39Y5wjBMlgafcCf67HCLhB9Z7yuXHy4XgT+VqxWcZVW5hBdhQsHZd0znjJotfGH1BzxMfiA==";
  };

  patchScript = pkgs.writeText "patch-pi-coding-agent.py" ''
    import json
    fixups = ${builtins.toJSON integrityFixups}
    # 1. Inject missing integrity hashes for sibling @earendil-works/* tarballs.
    p = "npm-shrinkwrap.json"
    with open(p) as f:
        d = json.load(f)
    for k, v in fixups.items():
        if k in d["packages"]:
            d["packages"][k]["integrity"] = v
    with open(p, "w") as f:
        json.dump(d, f, indent="\t")
    # 2. Drop devDependencies from package.json — they aren't in the shrinkwrap
    # and npm would otherwise try to fetch them from the network.
    p = "package.json"
    with open(p) as f:
        pkg = json.load(f)
    pkg.pop("devDependencies", None)
    pkg.pop("scripts", None)
    with open(p, "w") as f:
        json.dump(pkg, f, indent="\t")
  '';

  patchShrinkwrap = ''
    ${lib.getExe pkgs.python3} ${patchScript}
  '';
in
  pkgs.buildNpmPackage {
    pname = "pi-coding-agent";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
      hash = "sha256-iP/3TR/MkzQ+g5qoherLNeiM2quX2sJjaxG+zDskmfw=";
    };

    postPatch = patchShrinkwrap;

    npmDepsHash = "sha256-YcgMqgduPUnF8uve5EQ2Hh3ubIxhG0l6+cdVKU7jUcE=";
    npmDepsFetcherVersion = 2;
    makeCacheWritable = true;

    # The published tarball already contains `dist/`; no build step needed.
    dontNpmBuild = true;

    # Optional native dep `@mariozechner/clipboard` lacks prebuilts for some
    # platforms and isn't required for normal operation.
    npmFlags = ["--omit=optional" "--omit=dev" "--legacy-peer-deps"];

    nodejs = pkgs.nodejs_24;

    meta = {
      description = "pi coding agent CLI";
      homepage = "https://www.npmjs.com/package/@earendil-works/pi-coding-agent";
      license = lib.licenses.mit;
      mainProgram = "pi";
      platforms = lib.platforms.unix;
    };
  }
