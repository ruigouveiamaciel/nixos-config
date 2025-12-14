{config, ...}: let
  wheelUsers = builtins.filter (user: (builtins.elem "wheel" user.extraGroups)) (builtins.attrValues config.users.users);
  wheelAuthorizedKeys = builtins.concatMap (user: user.openssh.authorizedKeys.keys) wheelUsers;
in {
  boot.initrd = {
    systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = wheelAuthorizedKeys;
        hostKeys = ["/persist/initrd_ssh_host_ed25519_key"];
      };
    };
  };
}
