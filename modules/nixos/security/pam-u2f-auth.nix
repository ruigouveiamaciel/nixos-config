{
  config,
  pkgs,
  ...
}: {
  # Lock computer if a YubiKey is removed
  services.udev.extraRules = ''
    ACTION=="remove",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  # Allow sudo and login via an authorized fido key
  security = {
    pam = {
      u2f.settings = {
        cue = true;
        # 1. nix-shell -p pam_u2f
        # 2. pamu2fcfg > u2f_keys
        # 3. add another yubikey (optional): pamu2fcfg -n >> u2f_keys
        authfile = pkgs.writeText "u2f_keys" ''
          smokewow:hI+PA5nNxWztCj5DM0cuXftci9GadWTIFwZummcjt+a+gNTQUu2tXjF1tEcGZd35hpI3mi7/Q5dXBHukHAPnug==,EInXw6B826OV+VYCpUm5FsHuLi02TiG1GtXcrOd+DSdRj3Cu710OEkfzbJKPHwFcYJQtPayB9T7hikmhPTx1Sw==,es256,+presence
        '';
      };
      services = {
        login = {
          u2f = {
            enable = true;
            control = "required";
          };
        };
        kde = {
          u2f = {
            enable = true;
            control = "required";
          };
        };
        sudo = {
          u2f = {
            enable = true;
            control = "sufficient";
          };
          unixAuth = false;
          rules.auth.rssh.order =
            config.security.pam.services.sudo.rules.auth.u2f.order + 10;
        };
      };
    };
  };
}
