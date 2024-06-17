{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../global.nix
    ../../features/wsl
  ];

  wsl.defaultUser = "rui";

  networking = {
    hostName = "shenzhou";
  };

nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
