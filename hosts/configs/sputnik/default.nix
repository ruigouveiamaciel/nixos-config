{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix

    ../global.nix
    ../../features/boot/grub.nix
    ../../features/server
    ../../features/networking/wireless.nix
    ./services
  ];

  networking = {
    hostName = "sputnik";
    firewall.allowPing = false;
  };
  
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
