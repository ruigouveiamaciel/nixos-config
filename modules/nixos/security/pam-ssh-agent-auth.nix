{lib, ...}: {
  # Only allow sudo via an authorized ssh agent
  security = {
    pam = {
      rssh.enable = true;
      services.sudo = {
        rssh = true;
        rules.auth.unix.enable = lib.mkForce false;
      };
    };
    sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
        Defaults env_keep+=SSH_CLIENT
        Defaults env_keep+=SSH_TTY
      '';
    };
  };
}
