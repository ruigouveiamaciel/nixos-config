{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    audacity
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/audacity"
      ".local/share/audacity"
    ];
  };
}
