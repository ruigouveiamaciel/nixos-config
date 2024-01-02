{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  services.gnome.core-shell.enable = lib.mkForce true;
  services.gnome.at-spi2-core.enable = lib.mkForce true;
  services.gnome.glib-networking.enable = lib.mkForce true;
  services.gnome.core-os-services.enable = lib.mkForce true;
  services.gnome.gnome-settings-daemon.enable = lib.mkForce true;
  services.gnome.gnome-keyring.enable = lib.mkForce true;
  services.gnome.sushi.enable = lib.mkForce false;
  services.gnome.gnome-online-miners.enable = lib.mkForce false;
  services.gnome.tracker.enable = lib.mkForce false;
  services.gnome.tracker-miners.enable = lib.mkForce false;
  services.gnome.gnome-online-accounts.enable = lib.mkForce false;
  services.gnome.core-developer-tools.enable = lib.mkForce false;
  services.gnome.rygel.enable = lib.mkForce false;
  services.gnome.games.enable = lib.mkForce false;
  services.gnome.core-utilities.enable = lib.mkForce false;
  services.gnome.gnome-user-share.enable = lib.mkForce false;
  services.gnome.gnome-remote-desktop.enable = lib.mkForce false;
  services.gnome.gnome-initial-setup.enable = lib.mkForce false;
  services.gnome.evolution-data-server.plugins = lib.mkForce false;
  services.gnome.evolution-data-server.enable = lib.mkForce false;
  services.gnome.gnome-browser-connector.enable = lib.mkForce false;

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.touchegg.enable = true; # Touchpad gestures on X11
  
  # Required to declaratively configure gnome settings
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.gnome-shell
    gnome.gnome-tweaks
    gnome-console
    gnome.file-roller
    gnome.nautilus
    gnome-extension-manager
    gnome.gnome-font-viewer
  ];
  
  environment.gnome.excludePackages = with pkgs; [
    gnome-connections
    gnome-text-editor
    gnome-tour
    gnome.adwaita-icon-theme
    gnome.epiphany
    gnome.geary
    gnome.gnome-backgrounds
    gnome.gnome-calendar
    gnome.gnome-characters
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.gnome-logs
    gnome.gnome-maps
    gnome.gnome-music
    gnome.gnome-screenshot
    gnome.gnome-themes-extra
    gnome.gnome-weather
    gnome.simple-scan
    gnome.sushi
    gnome.totem
    gnome.yelp
    gnome.gnome-shell-extensions
    orca
  ];
}
