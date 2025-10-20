{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
  };

  home = lib.mkIf (builtins.hasAttr "persistance" config.home) {
    persistence."/persist" = {
      directories = [
        ".librewolf"
      ];
    };
  };
}
