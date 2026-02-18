{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "igc"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-amd"];
    kernelParams = ["amd_pstate=active"];
    extraModulePackages = [];
  };

  services.xserver.videoDrivers = ["modesetting"];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu.initrd.enable = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
