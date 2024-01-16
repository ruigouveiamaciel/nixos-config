{
  pkgs,
  config,
  ...
}: {
  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/OpenTabletDriver"
    ];
  };
}
