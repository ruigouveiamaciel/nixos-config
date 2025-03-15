{
  inputs,
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")

    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

  myNixOS = {
    locales.pt-pt.enable = true;
    networking.openssh.enable = true;
    security.disable-lecture.enable = true;
    nix = {
      nix-settings.enable = true;
      sops.enable = true;
    };
    users.authorized-keys.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = config.myNixOS.users.authorized-keys.users.rui;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  networking = {
    hostName = lib.mkDefault "minimal";
    useDHCP = lib.mkDefault true;
    enableIPv6 = lib.mkDefault false;
  };

  # QEMU Stuff
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
    growPartition = lib.mkDefault true;
  };
  fileSystems."/".autoResize = true;

  services.qemuGuest.enable = true;
  zramSwap.enable = false;
  systemd = {
    oomd.enable = false;
    services.clear-cache = {
      description = "Clear Page Cache";
      serviceConfig.Type = "oneshot";
      script = "sync && echo 3 > /proc/sys/vm/drop_caches";
    };
    timers.clear-cache = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
