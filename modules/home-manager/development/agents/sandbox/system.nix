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

  users = {
    mutableUsers = false;
    allowNoPasswordLogin = true;
  };

  services.getty.autologinUser = "sandbox";

  virtualisation = {
    cores = 4;
    memorySize = 4 * 1024;
    diskSize = 32 * 1024;
    writableStoreUseTmpfs = true;
    graphics = false;
    sharedDirectories = {
      workspace = {
        target = "/workspace";
        source = ''"''${SHARED_WORKSPACE_DIR:-''$PWD}"'';
        securityModel = "none";
      };
    };
  };
  networking = {
    hostName = "sandbox";
    firewall.enable = false;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.05";
  home-manager.users.sandbox.home.stateVersion = "26.05";
}
