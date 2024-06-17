{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
      GatewayPorts = "clientspecified";
    };

    hostKeys = [
      {
        path = "/persist/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  security.pam.sshAgentAuth.enable = true;
}
