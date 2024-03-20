{
  pkgs,
  ...
}: {
  programs.discord = {
    enable = true;
    wrapDiscord = false;
  };
}
