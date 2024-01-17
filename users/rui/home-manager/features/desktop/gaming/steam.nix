{config, ...}: {
  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".local/share/Steam"
      ".steam"
    ];
  };
}
