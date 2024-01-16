{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      unstable.zoom-us
    ];
    persistence."/nix/persist${config.home.homeDirectory}" = {
      allowOther = true;
      directories = [
        ".zoom"
      ];
      files = [
        ".config/zoom.conf"
        ".config/zoomus.conf"
        ".config/Unknown Organization/zoom.conf"
      ];
    };
  };
}
