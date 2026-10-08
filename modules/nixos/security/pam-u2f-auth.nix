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
          smokewow:hI+PA5nNxWztCj5DM0cuXftci9GadWTIFwZummcjt+a+gNTQUu2tXjF1tEcGZd35hpI3mi7/Q5dXBHukHAPnug==,EInXw6B826OV+VYCpUm5FsHuLi02TiG1GtXcrOd+DSdRj3Cu710OEkfzbJKPHwFcYJQtPayB9T7hikmhPTx1Sw==,es256,+presence:QBEsYxs1OnXJgd2LufcQxasL05T4yg64dYdb7ZYRIQJfaMRT8DFLET17HhsnTf5h2c5jDX4ZsSjLACRGMaS1cw==,NbLQ6pO/d0+uZ+pDWk5+6BzuQmx+8Kv3Fftj8uT7ybr4e81stXE3Gw8BuS0zGDE79IG/81v3fyyoe8iUardQ4Q==,es256,+presence:Q+IrjVq4Yb8jn6yHutLSu3DfqtOX1COL6S4vme1ao6+Ew13A6ZRzG8L02uNIJq2LnVqcL5zC3ZjSCMhlEWwGow==,+zru0aJvHe1fXekbRoJ2crX98iuXFMxlGBU/dWwxB3w72cUG2BGmu3WLDmTRqq+7EJOZuoC25kBIxSHvE4LRsw==,es256,+presence
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
