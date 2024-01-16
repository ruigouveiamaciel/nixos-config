{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    xournalpp
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/xournalpp"
    ];
  };
}
