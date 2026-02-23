{lib, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkForce false;
      PermitRootLogin = lib.mkForce "no";
      GatewayPorts = "clientspecified";
      StreamLocalBindUnlink = "yes";
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "yes";
    };

    hostKeys = [
      {
        path = "/persist/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
