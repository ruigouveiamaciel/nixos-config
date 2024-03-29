{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports =
    [
      ../features/networking/encrypted-dns.nix
      ../features/networking/openssh.nix

      ../features/cli/disable-lecture.nix
      ../features/cli/fish.nix
      ../features/cli/git.nix
      ../features/cli/utils.nix

      ../features/virtualisation/docker.nix

      ../features/system/home-manager.nix
      ../features/system/locale.nix
      ../features/system/nix-ld.nix
      ../features/system/nix.nix
      ../features/system/sops.nix
      ../features/system/sudo-ssh-agent-auth.nix

      ../features/boot/systemd-initrd.nix
      inputs.nur.nixosModules.nur
    ]
    ++ builtins.attrValues outputs.nixosModules;

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };
}
