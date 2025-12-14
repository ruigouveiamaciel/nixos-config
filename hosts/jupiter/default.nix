{
  myModulesPath,
  config,
  ...
}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/desktop/gaming"
    "${myModulesPath}/desktop/plasma6.nix"

    "${myModulesPath}/users/rui"

    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"
  ];

  home-manager.users.rui.imports = [./home.nix];

  networking = {
    hostName = "gaming-desktop";
    hostId = "397d7c75";
    useDHCP = true;
  };

  boot = {
    plymouth.enable = true;
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
    };
    initrd = {
      systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = config.myConstants.users.rui.authorized-keys;
          hostKeys = ["/persist/initrd_ssh_host_ed25519_key"];
        };
      };
    };
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
