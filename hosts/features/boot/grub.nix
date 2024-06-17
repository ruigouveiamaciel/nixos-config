{inputs, ...}: {
  imports = [
    inputs.grub2-themes.nixosModules.default
  ];

  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      extraConfig = ''
        set timeout=10
      '';
    };
    grub2-theme = {
      enable = true;
      theme = "stylish";
      footer = true;
    };
  };
}
