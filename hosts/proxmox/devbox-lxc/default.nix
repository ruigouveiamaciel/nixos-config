{config, ...}: {
  imports = [../minimal-lxc ./openssh.nix];

  myNixOS = {
    bundles.core.enable = true;

    networking = {
      openssh.enable = true;
      cloudflared.enable = true;
    };

    users.rui.enable = true;
  };

  sops.secrets.deploy-key = {
    sopsFile = ./secrets.yaml;
  };

  nix.settings.secret-key-files = [
    config.sops.secrets.deploy-key.path
  ];

  networking.hostName = "devbox";
}
