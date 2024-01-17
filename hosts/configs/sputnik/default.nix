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
  
  security = {
    pam.services.sudo = {
      sshAgentAuth = true;
    };

    sudo.extraConfig = ''
      Defaults env_keep+=SSH_AUTH_SOCK
    '';
  };
  
  security.pam.enableSSHAgentAuth = true;
  
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
