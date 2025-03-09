_: {
  imports = [../minimal-vm ./disko.nix];

  fileSystems = {
    "/mnt/media-server".autoResize = true;
    "/export/media-server" = {
      device = "/mnt/media-server";
      options = ["bind"];
    };

    "/mnt/torrenting".autoResize = true;
    "/export/torrenting" = {
      device = "/mnt/torrenting";
      options = ["bind"];
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export         10.0.102.0/24(rw,fsid=0,no_subtree_check) 10.0.100.0/24(rw,fsid=0,no_subtree_check)
      /export/media-server  10.0.102.0/24(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
      /export/torrenting  10.0.102.0/24(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
    '';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [111 2049 4000 4001 4002 20048];
    allowedUDPPorts = [111 2049 4000 4001 4002 20048];
  };

  networking.hostName = "storagebox";
}
