{config, ...}: {
  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".local/share/Steam"
      ".steam"
    ];
  };
}
