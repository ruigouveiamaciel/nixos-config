{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in {
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host sputnik.maciel.sh
        ProxyCommand ${pkgs.unstable.cloudflared} access ssh --hostname %h
    '';
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [".ssh"];
  };
}
