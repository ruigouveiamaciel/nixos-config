{
  pkgs,
  config,
  lib,
  ...
}: let
  pinentry =
    if config.gtk.enable
    then {
      packages = [pkgs.pinentry-gnome pkgs.gcr];
      name = "gnome3";
    }
    else {
      packages = [pkgs.pinentry-curses];
      name = "curses";
    };
in {
  home.packages = pinentry.packages;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableFishIntegration = true;
    enableScDaemon = true;
    sshKeys = ["55C5D38F750C59A49768EEF8A97A927F3F94F16B"];
    pinentryFlavor = pinentry.name;
    enableExtraSocket = true;
  };

  programs = {
    gpg = {
      enable = true;
      settings = {
        trust-model = "tofu+pgp";
      };
      publicKeys = [
        {
          source = ../../../pgp.asc;
          trust = 5;
        }
      ];
    };
  };

  programs.fish.shellInit = ''
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
