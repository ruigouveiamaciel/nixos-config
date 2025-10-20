{
  security = {
    pam = {
      sshAgentAuth.enable = true;
      services.sudo = {config, ...}: {
        sshAgentAuth = true;
        # Workaround for ssh_agent_auth randomly failing and falling back
        # to a password prompt
        rules.auth = {
          ssh_agent_auth_retry = {
            order = config.rules.auth.ssh_agent_auth.order + 1;
            inherit (config.rules.auth.ssh_agent_auth) control modulePath args enable;
          };
          ssh_agent_auth_retry_retry = {
            order = config.rules.auth.ssh_agent_auth.order + 2;
            inherit (config.rules.auth.ssh_agent_auth) control modulePath args enable;
          };
        };
      };
    };

    sudo.extraConfig = ''
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults env_keep+=SSH_CLIENT
      Defaults env_keep+=SSH_TTY
    '';
  };
}
