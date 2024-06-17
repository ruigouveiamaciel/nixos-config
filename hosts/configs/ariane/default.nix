{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix

    ../global.nix
    ../features/networking/encrypted-dns.nix

    # Grub for dual booting with windows
    ../../features/boot/grub.nix

    ../../features/desktop/gnome
    ../../features/desktop/gaming
  ];

  networking = {
    hostName = "ariane";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
