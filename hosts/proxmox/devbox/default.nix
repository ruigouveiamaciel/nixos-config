{config, ...}: {
  imports = [
    ../minimal-vm

    ./cloudflared-tunnel.nix
    ./ttyd.nix
  ];

  networking.hostName = "devbox";

  myNixOS = {
    bundles.core.enable = true;
    users.rui.enable = true;
  };

  sops.secrets.deploy-key = {
    sopsFile = ./secrets.yaml;
  };

  nix.settings.secret-key-files = [
    config.sops.secrets.deploy-key.path
  ];
}
