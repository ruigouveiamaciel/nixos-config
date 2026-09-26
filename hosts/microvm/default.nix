{
  lib,
  myModulesPath,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/locales/pt-pt.nix"
    "${myModulesPath}/users/sandbox"
  ];

  users.mutableUsers = false;
  users.allowNoPasswordLogin = true;
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
      AllowTcpForwarding = "no";
      AllowAgentForwarding = "no";
    };
  };

  networking.hostName = "sandbox";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.05";
}
