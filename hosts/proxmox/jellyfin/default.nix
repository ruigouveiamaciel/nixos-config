{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    ../minimal-vm

    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  networking.hostName = "jellyfin";

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = "/mnt/media/.jellyfin";
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  users.users.jellyfin.extraGroups = ["video" "render"];

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot = {
    kernelParams = [
      "i915.force_probe=46a6"
      "i915.modeset=1"
      "i915.enable_guc=2"
    ];
  };

  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  services.rpcbind.enable = true;
  fileSystems."/mnt/media" = {
    device = "10.0.102.3:/media";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };

  systemd.services = let
    inherit (config.virtualisation.oci-containers) backend;
  in
    lib.attrsets.mapAttrs' (serviceName: _:
      lib.attrsets.nameValuePair "${backend}-${serviceName}" {
        bindsTo = ["mnt-media.mount"];
        after = ["mnt-media.mount"];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
        startLimitBurst = 60;
        startLimitIntervalSec = 3600;
      })
    config.virtualisation.oci-containers.containers;
}
