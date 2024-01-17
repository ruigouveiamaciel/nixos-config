{config, ...}: {
  home.persistence."/nix/backup${config.home.homeDirectory}" = {
    directories = [
      ".factorio"
    ];
  };
}
