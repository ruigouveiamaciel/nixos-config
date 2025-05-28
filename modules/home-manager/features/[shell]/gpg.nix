{
  pkgs,
  config,
  ...
}: let
  pinentryPackage =
    if config.gtk.enable
    then pkgs.pinentry-gnome3
    else if pkgs.stdenv.isDarwin
    then pkgs.pinentry_mac
    else pkgs.pinentry-tty;
in {
  config = {
    services.gpg-agent = {
      enable = true;
      pinentry.package = pinentryPackage;
      enableSshSupport = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableScDaemon = true; # Enable support for smart cards
      sshKeys = config.myConstants.users.rui.gpg-agent-keygrips;
      enableExtraSocket = true; # Required for agent forwarding
    };

    programs = {
      # TODO: I think this is currently the default and no longer needed:

      # Start gpg-agent if it's not running or tunneled in
      # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
      # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
      # bash.initExtra = ''
      #   if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
      #     export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      #   fi
      # '';
      # fish.shellInit = ''
      #   if test -z "$SSH_CLIENT" -a -z "$SSH_TTY"
      #     export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      #   end
      # '';
      # zsh.initExtra = ''
      #   if [[ -z $SSH_CLIENT && -z $SSH_TTY ]]; then
      #     export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      #   fi
      # '';

      gpg = {
        enable = true;
        settings = {
          trust-model = "tofu+pgp";
        };
        publicKeys = [
          {
            text = config.myConstants.users.rui.pgp;
            trust = 5;
          }
        ];
      };
    };

    systemd.user.services = {
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
  };
}
