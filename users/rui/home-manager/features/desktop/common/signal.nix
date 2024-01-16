{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      signal-desktop
    ];
    persistence."/nix/persist${config.home.homeDirectory}" = {
      allowOther = true;
      directories = [
        ".config/Signal"
      ];
    };
  };
}
