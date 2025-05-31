{lib, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  myNixOS = {
    profiles = {
      essentials.enable = true;
    };
    users.rui.enable = true;
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

  # TODO: Move this to a generic desktop setting
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  # TODO: This should be part of impermancence config
  programs.fuse.userAllowOther = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  services.playerctld.enable = true;

  system.stateVersion = "25.05";
}
