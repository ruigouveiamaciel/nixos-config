{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
      obsidian
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
