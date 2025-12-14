{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_17;
    initrd.availableKernelModules = ["igc"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
