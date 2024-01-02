{
  pkgs,
  config,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".vscode"
      ".config/Code"
    ];
  };
}
