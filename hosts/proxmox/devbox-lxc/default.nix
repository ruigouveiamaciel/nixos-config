{config, ...}: {
  imports = [
    ../minimal-lxc

    ./cloudflared-tunnel.nix
    ./ttyd.nix
  ];

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
