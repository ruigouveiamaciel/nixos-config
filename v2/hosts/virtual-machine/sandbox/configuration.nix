{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./filesystems.nix
  ];

  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      extraConfig = ''
        set timeout=10
      '';
    };
  };

  networking = {
    hostName = "ariane";
    useDHCP = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    eza
    ranger
  ];

  system.stateVersion = "24.11";
}
