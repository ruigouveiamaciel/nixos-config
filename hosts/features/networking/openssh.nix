{
  outputs,
  lib,
  config,
  ...
}: {
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
        path = "/nix/backup/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
