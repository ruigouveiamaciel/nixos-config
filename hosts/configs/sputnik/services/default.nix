{
  imports = [
    ./atm9
    ./factorio
    ./firefly
    ./ssh
    ./taskserver
    ./acc
  ];

  virtualisation.oci-containers.backend = "docker";

  # Recommended settings for cloudflared tunnels
  boot.kernel.sysctl."net.core.rmem_max" = 2500000;
  boot.kernel.sysctl."net.core.wmem_max" = 2500000;
}
