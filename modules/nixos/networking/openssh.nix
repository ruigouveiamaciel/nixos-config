{
  lib,
  config,
  ...
}: let
  KEY_PATH = "/persist/ssh_host_ed25519_key";
  KEY_TYPE = "ed25519";
in {
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
        path = KEY_PATH;
        type = KEY_TYPE;
      }
    ];
  };

  boot.postBootCommands = ''
    if [[ ! -f "${KEY_PATH}" ]]; then
      ${lib.getExe' config.services.openssh.package "ssh-keygen"} -t ${KEY_TYPE} -f "${KEY_PATH}" -N "" -C ""
    fi
    chmod 600 "$KEY_PATH"
    if [[ -f "${KEY_PATH}.pub" ]]; then
        chmod 644 "${KEY_PATH}.pub"
    fi
  '';
}
