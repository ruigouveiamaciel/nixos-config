_: {
  config = {
    security = {
      pam.services.sudo = {config, ...}: {
        sshAgentAuth = true;
        # Retry ssh_agent_auth several times before falling back to a password prompt.
        # Without this it will occasionally fall back to a password prompt.
        rules.auth.ssh_agent_auth_retry = {
          order = config.rules.auth.ssh_agent_auth.order + 1;
          inherit (config.rules.auth.ssh_agent_auth) control modulePath args;
        };
        rules.auth.ssh_agent_auth_retry_retry = {
          order = config.rules.auth.ssh_agent_auth.order + 2;
          inherit (config.rules.auth.ssh_agent_auth) control modulePath args;
        };
      };

      sudo.extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
        Defaults env_keep+=SSH_CLIENT
        Defaults env_keep+=SSH_TTY
      '';
    };
  };
}
