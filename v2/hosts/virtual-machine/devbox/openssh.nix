{config, ...}: {
  myNixOS.networking.openssh.enable = true;

  virtualisation.oci-containers.containers = {
    ssh-tunnel = {
      inherit (config.myNixOS.networking.cloudflared) image;
      extraOptions = [
        "--network=host"
      ];
      cmd = [
        "tunnel"
        "run"
      ];
      environmentFiles = [
        config.sops.templates."ssh-cloudflared-tunnel.env".path
      ];
    };
  };

  sops.secrets.ssh-cloudflared-tunnel-token = {
    sopsFile = ./secrets.yaml;
  };

  sops.templates."ssh-cloudflared-tunnel.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.ssh-cloudflared-tunnel-token}
  '';
}
