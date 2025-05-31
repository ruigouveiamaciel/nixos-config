_: {
  config = {
    myNixOS = {
      locales.pt-pt.enable = true;

      nix = {
        nix-settings.enable = true;
      };

      networking = {
        homelab-hosts.enable = true;
      };

      security = {
        disable-lecture.enable = true;
        ssh-agent-auth.enable = true;
      };

      shell = {
        git.enable = true;
      };
    };
  };
}
