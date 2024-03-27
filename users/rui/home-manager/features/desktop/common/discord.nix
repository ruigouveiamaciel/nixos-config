{pkgs, ...}: {
  programs.discord = {
    enable = true;
    wrapDiscord = true;
  };
}
