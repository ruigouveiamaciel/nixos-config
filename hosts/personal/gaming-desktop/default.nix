_: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  myNixOS = {
    profiles = {
      essentials.enable = true;
    };
    users.rui.enable = true;
    desktop = {
      hyprland.enable = true;
      gaming.enable = true;
    };
  };

  networking = {
    hostName = "gaming-desktop";
    hostId = "397d7c75";
    useDHCP = true;
  };

  boot = {
    plymouth.enable = true;
    loader.systemd-boot = {
      enable = true;
    };
  };

  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
