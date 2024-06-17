{outputs, ...}: {
  imports =
    [
      ../features/networking/openssh.nix

      ../features/cli
      ../features/virtualisation/docker.nix

      # For now, all my computers use the pt-pt keyboard and locale
      ../features/locale/pt-pt.nix

      ../features/system

      ../features/boot/systemd-initrd.nix
    ]
    ++ builtins.attrValues outputs.nixosModules;

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };
}
