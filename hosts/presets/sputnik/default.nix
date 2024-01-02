{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ../../optional/boot/grub.nix

    ../../global
    ../../optional/server
  ];

  networking = {
    hostName = "sputnik";
  };

  virtualisation.vmVariant.virtualisation.forwardPorts = [
    {
      from = "host";
      proto = "tcp";
      host.port = 2222;
      host.address = "0.0.0.0";
      guest.port = 22;
      guest.address = "10.0.2.15";
    }
  ];

  virtualisation.vmVariant.services.openssh = {
    extraConfig = ''
      ListenAddress 10.0.2.15
    '';
  };
  
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
