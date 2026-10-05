{
  config,
  pkgs,
  lib,
  ...
}: {
  # Shutdown computer if YubiKey is removed
  services.udev.extraRules = ''
    ACTION=="remove",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/systemctl poweroff -i"
  '';

  # Allow sudo and login via an authorized fido key
  security = {
    pam = {
      u2f = {
        enable = true;
        control = "sufficient";
        settings = {
          cue = true;
        };
      };
      services = {
        login = {
          u2fAuth = true;
          unixAuth = lib.mkForce false;
        };
        sudo = {
          u2fAuth = true;
          unixAuth = lib.mkForce false;
          # If rssh is enabled, make sure u2f takes priority
          rules.auth.rssh.order =
            config.security.pam.services.sudo.rules.auth.u2f.order + 10;
        };
      };
    };

    sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
      '';
    };
  };
}
