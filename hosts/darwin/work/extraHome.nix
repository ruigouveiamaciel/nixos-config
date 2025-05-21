{
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    userEmail = lib.mkForce "rum@axogroup.com";
    userName = lib.mkForce "Rui Maciel";
  };

  home = {
    sessionPath = [
      "/Users/ruimaciel/repos/ax/out"
    ];
    sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };
  };

  programs = {
    fish = {
      shellInit = ''
        if test -n "$GHOSTTY_RESOURCES_DIR"
          . "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
          end
      '';
      shellAliases = {
        "rebuild" = "cd ~/repos/nixos-config && sudo darwin-rebuild switch --flake .#darwin-work";
        "ad" = "cd ~/repos/frontend/apps/ace && pnpm dev";
        "fo" = "cd ~/repos/frontend && nvim .";
        "no" = "cd ~/repos/nixos-config && nvim .";
      };
    };
  };

  # Ghostty config
  home.file = {
    "/Users/ruimaciel/.config/ghostty/config".text = ''
      theme = catppuccin-macchiato
      command = ${pkgs.fish}/bin/fish --login --interactive
      shell-integration = none
      font-size = 16
      font-thicken = true
      font-thicken-strength = 32
    '';
  };
}
