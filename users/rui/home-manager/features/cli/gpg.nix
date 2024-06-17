{
  pkgs,
  config,
  lib,
  ...
}: let
  pinentry =
    if config.gtk.enable
    then {
      name = "gnome3";
      package = pkgs.pinentry-gnome3;
    }
    else {
      name = "curses";
      package = pkgs.pinentry-curses;
    };
in {
  home.packages = [pinentry.package];

  services.gpg-agent = lib.mkIf (!config.wsl.enable) {
    enable = true;
    enableSshSupport = true;
    enableFishIntegration = true;
    enableScDaemon = true;
    sshKeys = ["55C5D38F750C59A49768EEF8A97A927F3F94F16B"];
    pinentryPackage = pinentry.package;
    enableExtraSocket = true;
  };

  programs = {
    # Start gpg-agent if it's not running or tunneled in
    # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
    # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
    bash.initExtra = lib.mkIf (!config.wsl.enable) ''
      if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      fi
    '';
    fish.shellInit = lib.mkIf (!config.wsl.enable) ''
      if test -z "$SSH_CLIENT" -a -z "$SSH_TTY"
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      end
    '';
    zsh.initExtra = lib.mkIf (!config.wsl.enable) ''
      if [[ -z $SSH_CLIENT && -z $SSH_TTY ]]; then
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      fi
    '';

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

  systemd.user.services = lib.mkIf (!config.wsl.enable) {
    # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
    # So that SSH config does not have to know the UID
    link-gnupg-sockets = {
      Unit = {
        Description = "link gnupg sockets from /run to /home";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
        ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
        RemainAfterExit = true;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
