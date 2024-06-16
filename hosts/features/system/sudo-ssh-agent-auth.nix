{
  security = {
    pam.services.sudo = {config, ...}: {
      sshAgentAuth = true;
      # Retry ssh_agent_auth several times before falling back to a password prompt.
      # Without this it will occasionally fall back to a password prompt.
      rules.auth.ssh_agent_auth_retry = {
        order = config.rules.auth.ssh_agent_auth.order + 1;
        control = config.rules.auth.ssh_agent_auth.control;
        modulePath = config.rules.auth.ssh_agent_auth.modulePath;
        args = config.rules.auth.ssh_agent_auth.args;
      };
      rules.auth.ssh_agent_auth_retry_retry = {
        order = config.rules.auth.ssh_agent_auth.order + 2;
        control = config.rules.auth.ssh_agent_auth.control;
        modulePath = config.rules.auth.ssh_agent_auth.modulePath;
        args = config.rules.auth.ssh_agent_auth.args;
      };
    };

    sudo.extraConfig = ''
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults env_keep+=SSH_CLIENT
      Defaults env_keep+=SSH_TTY
    '';
  };
}
