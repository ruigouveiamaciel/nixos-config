{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      spotify
    ];
    persistence."/nix/persist${config.home.homeDirectory}" = {
      allowOther = true;
      directories = [
        ".cache/spotify"
        ".config/spotify"
      ];
    };
  };
}
