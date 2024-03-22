{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    prismlauncher
    config.nur.repos."7mind".graalvm-legacy-packages.graalvm17-ce-full
  ];
}
