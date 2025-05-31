_: {
  config = {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        # example = {
        #   host = "example.maciel.sh";
        #   proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        #   forwardAgent = true;
        #   remoteForwards = [
        #     {
        #       bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
        #       host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
        #     }
        #   ];
        # };
      };
    };
  };
}
