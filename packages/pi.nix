{
  pkgs,
  lib,
  ...
}: let
  version = "0.78.0";

  # pi-coding-agent ships a prebuilt `dist/` and an `npm-shrinkwrap.json`,
  # but its shrinkwrap is missing `integrity` for the sibling
  # @earendil-works/pi-* tarballs. We patch them in before letting
  # `fetchNpmDeps` populate the offline cache.
  integrityFixups = {
    "node_modules/@earendil-works/pi-agent-core" = "sha512-xhWd59Qzd8yO88gYQw2S4dEQstJJEiUtxRP01//YzVJ61jCtUASMfcyAmYhgGYR4Onp7GmwEAbBBGOiV6Iwk9g==";
    "node_modules/@earendil-works/pi-ai" = "sha512-q0hUrvT6ngT6cgBX0oIbzfQfmzztgdkZobP8OTL+sCOOBlnG6+1YRt8g7zO9CC/4NdeYEqa7uGqWdQhH0fjCLA==";
    "node_modules/@earendil-works/pi-tui" = "sha512-3a705FnsVVUhAyceShNB3kS2rpxcxLcx+hqB0u6MMMpHwQGbW+m++MqA6r7eOzq/8FLx5e3vDh38h/SVTk2qzw==";
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
      hash = "sha256-oEfadYAdkTXjaKRxHQbQyktqtwiAGrgv0TZt3h7t0O4=";
    };

    postPatch = patchShrinkwrap;

    npmDepsHash = "sha256-ZkjJKdGLklcisgmIuZ2XPhBNLmRKhukpsaVjIjqQ8/I=";
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
