{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      qalculate-gtk
    ];
  };
}
