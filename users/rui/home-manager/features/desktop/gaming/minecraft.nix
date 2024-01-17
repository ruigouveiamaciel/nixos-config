{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    prismlauncher
  ];

  home.persistence."/nix/backup${config.home.homeDirectory}" = {
    directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
