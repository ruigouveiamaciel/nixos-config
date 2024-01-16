{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    bitwarden
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/Bitwarden"
    ];
  };
}
