{
  lib,
  myModulesPath,
  modulesPath,
  config,
  ...
}: let
  KEY_PATH = "/etc/ssh/ssh_host_ed25519_key";
  KEY_TYPE = "ed25519";
in {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/locales/pt-pt.nix"
    "${myModulesPath}/users/sandbox"
  ];
  users = {
    mutableUsers = false;
    allowNoPasswordLogin = true;
    users.sandbox.password = lib.mkForce "sandbox";
  };
  home-manager.users.sandbox.imports = [./home.nix];
  services.getty.autologinUser = "sandbox";

  virtualisation = {
    cores = 4;
    memorySize = 4 * 1024;
    diskSize = 32 * 1024;
    writableStoreUseTmpfs = true;
    graphics = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkForce true;
      PermitRootLogin = lib.mkForce "no";
      GatewayPorts = "clientspecified";
      StreamLocalBindUnlink = "yes";
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "yes";
      PerSourceMaxStartups = "none";
      MaxStartups = "10000:100:10000";
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
    chmod 600 "${KEY_PATH}"
    chown root:root "${KEY_PATH}"
    if [[ -f "${KEY_PATH}.pub" ]]; then
      chmod 644 "${KEY_PATH}.pub"
      chown root:root "${KEY_PATH}.pub"
    fi
  '';

  networking.hostName = "sandbox";
  networking.firewall.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.05";
}
