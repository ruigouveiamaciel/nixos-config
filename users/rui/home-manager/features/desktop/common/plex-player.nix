{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    plex-media-player
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/plex.tv"
      ".local/share/plexmediaplayer"
    ];
  };
}
