{myModulesPath, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/desktop/gaming"
    "${myModulesPath}/desktop/plasma6.nix"

    "${myModulesPath}/users/rui"

    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/networking/remote-disk-unlock.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"
  ];

  home-manager.users.rui.imports = [./home.nix];

  networking = {
    hostName = "jupiter";
    hostId = "397d7c75";
    useDHCP = true;
  };

  boot = {
    plymouth.enable = true;
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
    };
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Xerox_B225";
        location = "Home";
        deviceUri = "http://10.0.150.42:631";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Xerox_B225";
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
