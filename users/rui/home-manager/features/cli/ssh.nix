{pkgs, ...}: {
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
      nine = {
        host = "ssh.ninegaming.pt";
        proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
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
}
