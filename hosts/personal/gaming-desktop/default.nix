{config, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  myNixOS = {
    profiles.essentials.enable = true;
    security.no-sudo-passwd.enable = true;
    users.rui = {
      enable = true;
      extraHomeManagerConfigFile = ./home.nix;
    };
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
    loader.systemd-boot.enable = true;
  };

  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${config.programs.hyprland.package}/bin/hyprland";
        user = "rui";
      };
      default_session = initial_session;
    };
  };

  services.udev = {
    enable = true;
    extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Keymapp Flashing rules for the Voyager
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"

      # Make ZSA not be shown as a controller in Steam
      SUBSYSTEM=="input", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1977", ENV{ID_INPUT_JOYSTICK}=""
    '';
  };

  system.stateVersion = "25.05";
}
