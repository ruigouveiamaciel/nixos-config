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
        proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
            host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
          }
        ];
      };
      sputnik-ipv6 = {
        host = "2a01:4f8:171:28a3::";
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
            host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
          }
        ];
      };
    };
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [".ssh"];
  };
}
