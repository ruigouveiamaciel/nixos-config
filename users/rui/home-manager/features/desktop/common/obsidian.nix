{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      obsidian
    ];
    persistence."/nix/persist${config.home.homeDirectory}" = {
      directories = [".config/obsidian"];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
