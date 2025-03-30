{config, ...}: {
  myNixOS.networking.cloudflared.enable = true;

  virtualisation.oci-containers.containers = {
    ssh-cloudflared-tunnel = {
      inherit (config.myNixOS.networking.cloudflared) image;
      extraOptions = ["--network=host"];
      cmd = ["tunnel" "run"];
      environmentFiles = [
        config.sops.templates."ssh-cloudflared-tunnel.env".path
      ];
    };
  };

  sops = {
    secrets.ssh-cloudflared-tunnel-token.sopsFile = ./secrets.yaml;

    templates."ssh-cloudflared-tunnel.env" = {
      restartUnits = [
        "${config.virtualisation.oci-containers.containers.ssh-cloudflared-tunnel.serviceName}.service"
      ];
      content = ''
        TUNNEL_TOKEN=${config.sops.placeholder.ssh-cloudflared-tunnel-token}
      '';
    };
  };

  systemd.services."${config.virtualisation.oci-containers.containers.ssh-cloudflared-tunnel.serviceName}".after = [
    "sops-nix.service"
  ];
}
