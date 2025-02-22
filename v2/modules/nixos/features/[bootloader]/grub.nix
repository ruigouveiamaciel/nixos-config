{...}: {
  config = {
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
    };
  };
}
