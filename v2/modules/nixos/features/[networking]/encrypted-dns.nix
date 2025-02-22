{...}: {
  config = {
    # Ensure that the system does not use any DNS servers provided by DHCP.
    networking = {
      nameservers = ["127.0.0.1" "::1"];
      dhcpcd.extraConfig = "nohook resolv.conf";
      networkmanager.dns = "none";
      resolvconf.useLocalResolver = true;
    };

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };

        bootstrap_resolvers = ["1.1.1.1:53" "9.9.9.11:53" "8.8.8.8:53"];

        server_names = [
          "cloudflare"
          "cloudflare-ipv6"
        ];
      };
    };
  };
}
