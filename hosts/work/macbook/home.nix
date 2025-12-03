{
  lib,
  pkgs,
  ...
}: {
  services.gpg-agent.enable = lib.mkForce false;

  programs = {
    git.settings.user = {
      email = lib.mkForce "rum@axogroup.com";
      name = lib.mkForce "Rui Maciel";
    };

    fish = {
      shellInit = ''
        if test -n "$GHOSTTY_RESOURCES_DIR"
          . "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
        end
      '';
      shellAliases = {
        "rebuild" = "cd ~/repos/nixos-config && sudo darwin-rebuild switch --flake .#work-macbook";
        "ad" = "cd ~/repos/frontend/apps/ace && pnpm dev";
        "fo" = "cd ~/repos/frontend && nvim .";
        "no" = "cd ~/repos/nixos-config && nvim .";
      };
    };
  };

  home = {
    sessionVariables = {
      GOPRIVATE = "go.axofinance.io";
    };
    sessionPath = [
      "/Users/ruimaciel/repos/ax/out"
    ];
    file = {
      # Ghostty config
      "/Users/ruimaciel/.config/ghostty/config".text = ''
        theme = catppuccin-macchiato
        command = ${pkgs.fish}/bin/fish --login --interactive
        shell-integration = none
        font-size = 16
        font-thicken = true
        font-thicken-strength = 32
      '';
    };
  };
}
