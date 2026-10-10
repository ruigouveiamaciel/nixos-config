{
  programs.fish.shellAbbrs = {
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank | nvim";
  };

  home.stateVersion = "24.11";
}
