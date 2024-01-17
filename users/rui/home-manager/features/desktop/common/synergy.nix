{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    synergy
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/Synergy"
    ];
  };
}
