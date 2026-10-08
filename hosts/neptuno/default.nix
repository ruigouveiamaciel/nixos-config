{myModulesPath, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"

    "${myModulesPath}/desktop/plasma6.nix"
    "${myModulesPath}/desktop/gaming"

    "${myModulesPath}/locales/pt-pt.nix"
    "${myModulesPath}/users/smokewow"

    "${myModulesPath}/networking/networkmanager.nix"
    "${myModulesPath}/networking/wireguard.nix"
    # "${myModulesPath}/security/pam-ssh-agent-auth.nix"
    # TODO: Use Yubikey 5 Nano as MFA
    # "${myModulesPath}/security/pam-u2f-auth.nix"

    "${myModulesPath}/boot/plymouth.nix"
    "${myModulesPath}/boot/systemd-boot.nix"
  ];

  home-manager.users.smokewow.imports = [./home.nix];
  users.users.smokewow.hashedPasswordFile = "/persist/smokewow-hashed-password-file";

  services.displayManager.autoLogin = {
    enable = true;
    user = "smokewow";
  };

  networking = {
    hostName = "neptuno";
    hostId = "9f5194e4";
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "26.05";
}
