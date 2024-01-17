{
  pkgs,
  config,
  ...
}: {
  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/OpenTabletDriver"
    ];
  };
}
