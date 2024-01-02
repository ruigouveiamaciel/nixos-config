{pkgs, lib, config, ...}: {
  programs.steam = {
    enable = true;
    package = pkgs.steam;
  };
}
