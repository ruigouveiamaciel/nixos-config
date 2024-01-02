{
  imports = [
    ../global
    ../optional/desktop/gnome
    ../optional/desktop/wireless
    ../optional/desktop/gaming
  ];

  home.packages = with pkgs; [
    unstable.citrix_workspace
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
