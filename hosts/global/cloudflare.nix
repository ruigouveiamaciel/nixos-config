{lib, ...}: {
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  # Prevent networkmanager from appending DNS servers to resolv.conf
  networking.networkmanager.dns = "none";

  # Prevent dhcpcd from appending DNS servers to resolv.conf
  networking.dhcpcd.extraConfig = "nohook resolv.conf";

  networking.resolvconf.enable = lib.mkDefault true;
  services.resolved.extraConfig = ''
    nameserver 1.1.1.1
    nameserver 1.0.0.1
    nameserver 2606:4700:4700::1111
    nameserver 2606:4700:4700::1001
  '';
}
