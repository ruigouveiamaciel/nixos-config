{lib, ...}: {
  security = {
    pam.services.sudo = {config, ...}: {
      sshAgentAuth = true;
      rules.auth.ssh_agent_auth = {
        order = config.rules.auth.unix.order - 10;
        control = lib.mkDefault "[success=1 default=ignore]";
      };
    };
    
    sudo.extraConfig = ''
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults env_keep+=SSH_CLIENT
      Defaults env_keep+=SSH_TTY
    '';
  };

  security.pam.enableSSHAgentAuth = true;
}
