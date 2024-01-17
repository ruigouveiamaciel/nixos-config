{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    xournalpp
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/xournalpp"
    ];
  };
}
