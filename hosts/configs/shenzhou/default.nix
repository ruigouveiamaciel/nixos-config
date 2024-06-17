{lib, ...}: {
  imports = [
    ../global.nix
  ];

  wsl.defaultUser = "rui";

  networking = {
    hostName = "shenzhou";
  };

  wsl.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
