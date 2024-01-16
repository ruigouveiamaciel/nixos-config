{config, ...}: {
  home.persistence."/nix/backup${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".factorio"
    ];
  };
}
