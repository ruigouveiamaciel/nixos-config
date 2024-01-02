{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    synergy
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/Synergy"
    ];
  };
}
