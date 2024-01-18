{
  security = {
    pam.services.sudo = {config, ...}: {
      sshAgentAuth = true;
      rules.auth.ssh_agent_auth = {
        order = config.rules.auth.unix.order - 10;
      };
    };
  };

  security.pam.enableSSHAgentAuth = true;
}
