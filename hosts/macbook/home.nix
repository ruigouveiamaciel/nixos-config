{
  lib,
  pkgs,
  myModulesPath,
  config,
  ...
}: {
  imports = [
    "${myModulesPath}/desktop/apps/kitty.nix"
  ];

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
      shellAbbrs = {
        "rebuild" = "cd ~/repositories/nixos-config && sudo darwin-rebuild switch --print-build-logs --flake .#work-macbook";
        "build" = "cd ~/repositories/nixos-config && darwin-rebuild build --print-build-logs --flake .#work-macbook &| nom";
        "reviews" = "cd ~/projects/frontend-monorepo && glab mr list --reviewer=@me --output=json --not-draft | jq -r \".[] | \\\"\\(.iid) - \\(.title)\\n\\(.web_url)\\n\\\"\";";
      };
    };
  };

  home = {
    packages = with pkgs; [glab];
    sessionVariables = {
      GOPRIVATE = "go.axofinance.io";
    };
    sessionPath = [
      "/Users/ruimaciel/projects/ax/out"
    ];
    file = {
      # Ghostty config
      "/Users/ruimaciel/.config/ghostty/config".text = ''
        theme = catppuccin-macchiato
        command = ${config.programs.fish.package}/bin/fish --login --interactive
        shell-integration = none
        font-family = Iosevka Kitty Extended
        font-size = 16
        font-thicken = true
        font-thicken-strength = 32
      '';
    };
  };
}
