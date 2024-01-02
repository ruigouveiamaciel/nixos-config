{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [deluge];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/deluge"
    ];
  };
}
