{pkgs, ...}: {
  imports = [
    ./browsers.nix
    ./discord.nix
    ./fonts.nix
    ./gthumb.nix
    ./gtk.nix
    ./obsidian.nix
    ./slack.nix
    ./vscode.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;

  home.packages = with pkgs; [
    audacity
    deluge
    gimp
    qjackctl
    plex-media-player
    qalculate-gtk
    spotify
    vlc
    xournalpp
    zoom-us
    soundux
  ];
}
