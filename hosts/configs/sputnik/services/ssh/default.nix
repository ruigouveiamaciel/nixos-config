{
  pkgs,
  config,
  ...
}: {
  virtualisation.oci-containers.containers = {
    ssh-tunnel = {
      image = "cloudflare/cloudflared@sha256:01d46a12aa9e10f679a6a62b1b2052ce67675845caef268c7929249d08e5fbbd";
      extraOptions = [
        "--network=host"
      ];
      cmd = [
        "tunnel"
        "run"
      ];
      environmentFiles = [
        config.sops.templates."ssh-tunnel.env".path
      ];
    };
  };

  # Only allow SSH connections through cloudflared
  services.openssh.openFirewall = false;
  services.openssh.listenAddresses = [
    {
      addr = "127.0.0.1";
      port = 22;
    }
  ];

  sops.secrets.ssh-tunnel-token = {
    sopsFile = ../../secrets.yaml;
  };

  sops.templates."ssh-tunnel.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.ssh-tunnel-token}
  '';
}
