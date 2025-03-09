_: {
  imports = [../minimal-vm];

  fileSystems."/export/media" = {
    device = "/mnt/media";
    options = ["bind"];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export         10.0.102.0/24(rw,fsid=0,no_subtree_check) 10.0.100.0/24(rw,fsid=0,no_subtree_check)
      /export/media  10.0.102.0/24(rw,nohide,insecure,no_subtree_check) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
    '';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };

  networking.firewall = {
    enable = true;
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [111 2049 4000 4001 4002 20048];
    allowedUDPPorts = [111 2049 4000 4001 4002 20048];
  };

  networking.hostName = "storagebox";
}
