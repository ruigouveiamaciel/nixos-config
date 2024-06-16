{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix

    ../global.nix
    ../../features/boot/grub.nix
    ../../features/server
    ../../features/networking/encrypted-dns.nix
    ./services
  ];

  networking = {
    hostName = "sputnik";
    useDHCP = lib.mkDefault false;
    usePredictableInterfaceNames = lib.mkDefault false;
  };

  systemd.network = {
    enable = true;
    networks."eth0".extraConfig = ''
      [Match]
      Name = eth0
      [Network]
      # IPv6
      Address = 2a01:4f8:171:28a3::/64
      Gateway = fe80::1
      # IPv4
      Address = 138.201.17.172/26
      Gateway = 138.201.17.129
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
