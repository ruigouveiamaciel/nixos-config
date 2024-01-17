{
  imports = [
    ./atm9
    ./firefly
    ./taskserver
  ];

  virtualisation.oci-containers.backend = "docker";

  # Recommended settings for cloudflared tunnels
  boot.kernel.sysctl."net.core.rmem_max" = 2500000;
  boot.kernel.sysctl."net.core.wmem_max" = 2500000;
}
