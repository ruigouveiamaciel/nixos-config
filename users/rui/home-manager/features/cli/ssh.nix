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
    matchBlocks = {
      sputnik = {
        host = "sputnik.maciel.sh";
        proxyCommand = "${pkgs.unstable.cloudflared}/bin/cloudflared access ssh --hostname %h";
        forwardAgent = true;
        remoteForwards = [{
          bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
          host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
        }];
      };
    };
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [".ssh"];
  };
}
