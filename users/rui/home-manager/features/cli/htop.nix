{
  pkgs,
  config,
  secrets,
  ...
}: {
  home.packages = with pkgs; [
    htop
  ];
}
