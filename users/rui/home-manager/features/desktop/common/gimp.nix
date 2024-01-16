{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    gimp
  ];

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/GIMP"
    ];
  };
}
