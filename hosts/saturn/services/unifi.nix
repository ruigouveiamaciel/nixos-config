{
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.interfaces.enp90s0.allowedTCPPorts = [
    8443
  ];
}
