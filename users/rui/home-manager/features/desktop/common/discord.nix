{
  pkgs,
  config,
  ...
}: {
  programs.discord = {
    enable = true;
    wrapDiscord = true;
  };

  home = {
    persistence."/nix/persist${config.home.homeDirectory}" = {
      directories = [
        ".config/discord"
      ];
    };
  };
}
