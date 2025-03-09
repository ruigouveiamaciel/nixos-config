_: {
  imports = [
    ../minimal-vm
  ];

  services.jellyfin = {
    enable = true;
  };

  networking.hostName = "jellyfin";

  services.rpcbind.enable = true;
  fileSystems."/mnt/media-server" = {
    device = "10.0.102.3:/media-server";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };
}
