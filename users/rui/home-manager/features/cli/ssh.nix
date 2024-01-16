{
  outputs,
  lib,
  config,
  ...
}: let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in {
  programs.ssh = {
    enable = true;
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = lib.mkDefault false;
    directories = [".ssh"];
  };
}
