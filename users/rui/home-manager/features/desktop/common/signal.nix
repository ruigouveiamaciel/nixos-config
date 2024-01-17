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
      directories = [
        ".config/Signal"
      ];
    };
  };
}
