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

  users.allowNoPasswordLogin = true;

  services.getty.autologinUser = "smokewow";

  virtualisation = {
    cores = 4;
    memorySize = 8 * 1024;
    diskSize = 64 * 1024;
    writableStoreUseTmpfs = false;
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
  home-manager.users.smokewow.home.stateVersion = "26.05";
}
