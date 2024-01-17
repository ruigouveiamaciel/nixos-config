{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    audacity
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [
      ".config/audacity"
      ".local/share/audacity"
    ];
  };
}
