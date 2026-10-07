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
    "${myModulesPath}/networking/openssh.nix"
    # TODO: probably need a different script for unlocking
    "${myModulesPath}/networking/remote-disk-unlock.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"
    # TODO: Might want to use password instead so I don't get locked out
    # "${myModulesPath}/security/pam-u2f-auth.nix"

    "${myModulesPath}/boot/plymouth.nix"
    "${myModulesPath}/boot/systemd-boot.nix"
  ];

  home-manager.users.smokewow.imports = [./home.nix];

  networking = {
    hostName = "neptuno";
    hostId = "9f5194e4";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "26.05";
}
