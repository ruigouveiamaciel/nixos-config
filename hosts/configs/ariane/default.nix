{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix

    ../global.nix

    ../../features/boot/systemd-boot.nix
    ../../features/desktop/gnome
    ../../features/desktop/gaming
  ];

  networking = {
    hostName = "ariane";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
