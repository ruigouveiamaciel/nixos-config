{config, ...}: {
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.interfaces.enp90s0.allowedTCPPorts = [
    8443
  ];

  environment.persistence."/persist".directories = [
    {
      directory = config.users.users.unifi.home;
      user = "unifi";
      group = "unifi";
      mode = "0700";
    }
  ];
}
