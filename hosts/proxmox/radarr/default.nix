_: {
  imports = [
    ../minimal-vm
  ];

  networking.hostName = "radarr";

  services.rpcbind.enable = true;
  fileSystems."/mnt/torrenting" = {
    device = "10.0.102.3:/torrenting";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };
}
