{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.discord;
  discordPackage = pkgs.discord;

  patcher = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/sersorrel/sys/f3c8e8b4812f8069279da492fd830025e08ef580/hm/discord/krisp-patcher.py";
    hash = "sha256-87VlZKw6QoXgQwEgxT3XeFY8gGoTDWIopGLOEdXkkjE=";
  };

  python = pkgs.python3.withPackages (ps: [ps.pyelftools ps.capstone]);

  wrapperScript = pkgs.writeShellScript "discord-wrapper" ''
    set -euxo pipefail
    ${pkgs.findutils}/bin/find -L $HOME/.config/discord -name 'discord_krisp.node' -exec ${python}/bin/python3 ${patcher} {} +
    ${discordPackage}/bin/discord "$@"
  '';

  wrappedDiscord = pkgs.runCommand "discord" {} ''
    mkdir -p $out/share/applications $out/bin
    ln -s ${wrapperScript} $out/bin/discord
    ${pkgs.gnused}/bin/sed 's!Exec=.*!Exec=${wrapperScript}!g' ${discordPackage}/share/applications/discord.desktop > $out/share/applications/discord.desktop
  '';
in {
  options.programs.discord = {
    enable = lib.mkEnableOption "Discord";
    wrapDiscord = lib.mkEnableOption "wrap Discord to patch and enable Krisp audio support";
  };

  config = lib.mkIf (cfg.enable) {
    home.packages =
      if cfg.wrapDiscord
      then [wrappedDiscord]
      else [pkgs.discord];
  };
}
