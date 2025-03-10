_: {
  imports = [
    ../minimal-vm
  ];

  networking.hostName = "sonarr";

  services.rpcbind.enable = true;
  fileSystems."/output" = {
    device = "10.0.102.3:/media-server/shows";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };
  fileSystems."/downloads" = {
    device = "10.0.102.3:/torrenting/downloads";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.sonarr = {
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
