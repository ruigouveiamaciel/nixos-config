_: {
  config = {
    myHomeManager = {
      shell = {
        gpg.enable = true;
        fish.enable = true;
        git.enable = true;
        ssh.enable = true;
        starship.enable = true;
        utils.enable = true;
      };

      nix = {
        nix-settings.enable = true;
      };
    };
  };
}
