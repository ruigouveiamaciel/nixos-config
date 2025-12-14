{
  lib,
  pkgs,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_17;
    initrd.availableKernelModules = ["igc" "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod"];
    initrd.kernelModules = ["dm-snapshot"];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
