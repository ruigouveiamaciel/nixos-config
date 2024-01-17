{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    bitwarden
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/Bitwarden"
    ];
  };
}
