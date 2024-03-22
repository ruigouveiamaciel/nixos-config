{pkgs, ...}: {
  imports = [
    ../global.nix
    ../../features/desktop/gnome
    ../../features/desktop/gaming
  ];

  home.packages = with pkgs; [
    unstable.citrix_workspace
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
