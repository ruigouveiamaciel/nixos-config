{
  pkgs,
  inputs,
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
  fileSystems."/mnt/media-server" = {
    device = "10.0.102.3:/media-server";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };

  systemd.services.jellyfin = {
    after = ["remote-fs.target"]; # Ensure it starts after remote mounts
    requires = ["remote-fs.target"]; # Stop service if remote-fs.target goes down
    serviceConfig = {
      RestartSec = 60; # Wait 60 seconds before restarting
    };
    # Stop retrying after 60 minutes (60 retries)
    startLimitBurst = 60; # Allow up to 60 starts
    startLimitIntervalSec = 3600; # Time window for retry count (1 hour)
  };
}
