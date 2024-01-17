{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [deluge];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/deluge"
    ];
  };
}
