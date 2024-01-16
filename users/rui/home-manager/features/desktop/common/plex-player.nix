{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    plex-media-player
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/plex.tv"
      ".local/share/plexmediaplayer"
    ];
  };
}
