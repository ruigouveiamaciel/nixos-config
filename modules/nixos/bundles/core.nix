_: {
  config = {
    myNixOS = {
      locales.pt-pt.enable = true;

      nix = {
        nix-settings.enable = true;
        sops.enable = true;
        home-manager.enable = true;
      };

      security = {
        disable-lecture.enable = true;
        sudo-using-ssh-agent.enable = true;
      };

      shell = {
        fish.enable = true;
        git.enable = true;
        ssh.enable = true;
      };

      users = {
        authorized-keys.enable = true;
      };
    };
  };
}
