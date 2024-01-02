{
  pkgs,
  config,
  ...
}: let
  inherit (config.colorscheme) colors;
in {
  home.packages = with pkgs; [
    vlc
  ];
}
