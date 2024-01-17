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
      directories = [
        ".config/spotify"
      ];
    };
  };
}
