{
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    userEmail = lib.mkForce "rum@axogroup.com";
    userName = lib.mkForce "Rui Maciel";
  };

  home.sessionVariables = {
    SHELL = "${pkgs.fish}/bin/fish";
  };

  # Ghostty config
  home.file = {
    "Users/ruimaciel/.config/ghostty/themes" = let
      catppucin-ghostty = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "ghostty";
        rev = "9e38fc2b4e76d4ed5ff9edc5ac9e4081c7ce6ba6";
        hash = "sha256-RlgTeBkjEvZpkZbhIss3KxQcvt0goy4WU+w9d2XCOnw=";
      };
    in {
      source = "${catppucin-ghostty}/themes";
      target = "Users/ruimaciel/.config/ghostty/themes";
    };

    "/Users/ruimaciel/.config/ghostty/config".text = ''
      theme = catppuccin-macchiato.conf
      command = ${pkgs.fish}/bin/fish --login --interactive
    '';
  };
}
