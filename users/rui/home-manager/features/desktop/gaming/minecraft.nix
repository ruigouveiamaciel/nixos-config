{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    prismlauncher
  ];

  home.persistence."/nix/backup${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
