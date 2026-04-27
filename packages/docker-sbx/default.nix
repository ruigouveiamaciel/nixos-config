{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  e2fsprogs,
}: let
  pname = "docker-sbx";
  version = "0.27.0";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/docker/sbx-releases/releases/download/v${version}/DockerSandboxes-darwin.tar.gz";
      hash = "sha256-yDoYYrpkPOnQHaDxqx/SKRmaHurCZDYOuCCdef/ulf4=";
    };
    "x86_64-linux" = {
      url = "https://github.com/docker/sbx-releases/releases/download/v${version}/DockerSandboxes-linux.tar.gz";
      hash = "sha256-g8+ETVOrduIsEg2K4DmI+a5teOGBs5wCGUHp0xqzuIc=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
    or (throw "${pname} ${version}: unsupported system ${stdenvNoCC.hostPlatform.system}");

  isDarwin = stdenvNoCC.hostPlatform.isDarwin;
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl source;

    sourceRoot = ".";

    nativeBuildInputs =
      [installShellFiles]
      ++ lib.optionals (!isDarwin) [autoPatchelfHook];

    # libkrun.so on linux is dynamically linked; let autoPatchelfHook resolve it.
    buildInputs = lib.optionals (!isDarwin) [stdenv.cc.cc.lib];

    dontBuild = true;
    dontConfigure = true;

    installPhase =
      if isDarwin
      then ''
        runHook preInstall

        mkdir -p $out
        cp -r bin libexec $out/

        installShellCompletion --cmd sbx \
          --bash completions/bash/sbx \
          --zsh completions/zsh/_sbx \
          --fish completions/fish/sbx.fish

        install -Dm644 LICENSE $out/share/doc/${pname}/LICENSE
        install -Dm644 THIRD-PARTY-NOTICES $out/share/doc/${pname}/THIRD-PARTY-NOTICES

        runHook postInstall
      ''
      else ''
        runHook preInstall

        cd docker-sbx

        install -Dm755 sbx $out/bin/sbx

        install -Dm755 containerd-shim-nerdbox-v1 $out/libexec/containerd-shim-nerdbox-v1
        install -Dm755 mkfs.erofs $out/libexec/mkfs.erofs

        for f in nerdbox-kernel-* nerdbox-initrd-*; do
          install -Dm644 "$f" "$out/libexec/$f"
        done

        install -Dm755 libkrun.so $out/libexec/lib/libkrun.so

        install -Dm644 apparmor-profile $out/share/apparmor.d/docker-sbx-nerdbox-shim
        install -Dm644 LICENSE $out/share/doc/${pname}/LICENSE
        install -Dm644 THIRD-PARTY-NOTICES $out/share/doc/${pname}/THIRD-PARTY-NOTICES

        runHook postInstall
      '';

    # On Linux, sbx shells out to mkfs.ext4 (from e2fsprogs) at runtime.
    # On Darwin the tarball ships its own mkfs.ext4 in libexec.
    postInstall = lib.optionalString (!isDarwin) ''
      ln -s ${e2fsprogs}/bin/mkfs.ext4 $out/libexec/mkfs.ext4
    '';

    meta = {
      description = "Docker Sandboxes (sbx) — lightweight VM-based sandboxes for Docker";
      homepage = "https://github.com/docker/sbx-releases";
      # Proprietary; use governed by the Docker Subscription Service Agreement
      # (https://www.docker.com/legal/docker-subscription-service-agreement).
      # Bundled third-party components are listed in THIRD-PARTY-NOTICES.
      license = lib.licenses.unfree;
      platforms = lib.attrNames sources;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "sbx";
    };
  }
