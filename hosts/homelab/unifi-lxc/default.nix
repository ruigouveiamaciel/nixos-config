{pkgs, ...}: {
  imports = [../minimal-lxc];

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unstable.unifi;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [8443];
}
