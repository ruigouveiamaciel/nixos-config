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
      allowOther = true;
      directories = [".config/obsidian"];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
