{pkgs, ...}: {
  config = {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        devbox = {
          host = "devbox.maciel.sh";
          proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          forwardAgent = true;
          remoteForwards = [
            {
              bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
              host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
            }
          ];
        };
        minimal = {
          host = "10.0.100.100";
          #proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
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
  };
}
