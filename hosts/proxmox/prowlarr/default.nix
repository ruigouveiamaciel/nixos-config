_: {
  imports = [
    ../minimal-vm
  ];

  networking.hostName = "prowlarr";

  services.rpcbind.enable = true;
  fileSystems."/mnt/torrenting" = {
    device = "10.0.102.3:/torrenting";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
