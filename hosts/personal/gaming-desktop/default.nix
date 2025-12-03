{
  myModulesPath,
  pkgs,
  ...
}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"

    "${myModulesPath}/users/rui"
    "${myModulesPath}/desktop/gaming"
    "${myModulesPath}/desktop/pipewire.nix"

    "${myModulesPath}/networking/openssh.nix"
  ];

  home-manager.users.rui.imports = [./home.nix];

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    spectacle
    konsole
    kwallet
    kmenuedit
    elisa
    khelpcenter
  ];

  environment.systemPackages = with pkgs; [wl-clipboard];

  networking = {
    hostName = "gaming-desktop";
    hostId = "397d7c75";
    useDHCP = true;
  };

  boot = {
    plymouth.enable = true;
    loader.systemd-boot.enable = true;
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
