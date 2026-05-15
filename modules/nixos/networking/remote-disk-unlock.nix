{
  lib,
  config,
  ...
}: let
  wheelUsers = builtins.filter (user: (builtins.elem "wheel" user.extraGroups)) (builtins.attrValues config.users.users);
  wheelAuthorizedKeys = builtins.concatMap (user: user.openssh.authorizedKeys.keys) wheelUsers;
  KEY_PATH = "/persist/initrd_ssh_host_ed25519_key";
  KEY_TYPE = "ed25519";
in {
  boot = {
    initrd = {
      systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = wheelAuthorizedKeys;
          hostKeys = [KEY_PATH];
        };
      };
    };

    postBootCommands = ''
      if [[ ! -f "${KEY_PATH}" ]]; then
        ${lib.getExe' config.services.openssh.package "ssh-keygen"} -t ${KEY_TYPE} -f "${KEY_PATH}" -N "" -C ""
      fi
      chmod 600 "$KEY_PATH"
      if [[ -f "${KEY_PATH}.pub" ]]; then
          chmod 644 "${KEY_PATH}.pub"
      fi
    '';
  };
}
