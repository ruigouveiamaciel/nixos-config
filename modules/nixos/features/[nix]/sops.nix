{
  inputs,
  config,
  pkgs,
  ...
}: let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
    environment.systemPackages = with pkgs; [
      sops
      ssh-to-age
    ];
    sops = {
      age.sshKeyPaths = map getKeyPath keys;
    };
  };
}
