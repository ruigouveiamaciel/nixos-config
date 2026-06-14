{
  pkgs,
  lib,
  ...
}: {
  # Allow sudo and login only via an authorized fido key
  services.udev.extraRules = ''
    ACTION=="remove",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/systemctl poweroff -i"
  '';
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
