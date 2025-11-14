{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    package = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped.override {
        vapoursynthSupport = true;
      };
      youtubeSupport = true;
    };
  };

  home.packages = with pkgs; [
    imagemagick
  ];
}
