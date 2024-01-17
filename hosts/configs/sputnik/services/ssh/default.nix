{pkgs, config, ...}: {
  virtualisation.oci-containers.containers = {
    ssh-tunnel = {
      image = "cloudflare/cloudflared@sha256:0006c0e922784b9bbba542b8ccf82a6261698a82a78ff54632103f6036b34ab3";
      extraOptions = [
        "--network=host"
      ];
      dependsOn = [
        "firefly-app"
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
  
  #services.openssh.openFirewall = false;
  services.openssh.listenAddresses = [
    {
      addr = "::1";
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