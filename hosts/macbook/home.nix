{
  lib,
  pkgs,
  myModulesPath,
  ...
}: {
  imports = [
    "${myModulesPath}/desktop/apps/kitty.nix"
  ];

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
      shellAbbrs = {
        "rebuild" = "cd ~/projects/nixos-config && sudo darwin-rebuild switch --print-build-logs --flake .#work-macbook";
        "build" = "cd ~/projects/nixos-config && darwin-rebuild build --print-build-logs --flake .#work-macbook &| nom";
        "ad" = "cd ~/projects/frontend-monorepo/apps/ace && pnpm dev";
        "sod" = "cd ~/projects/frontend-monorepo/apps/site-one && pnpm dev";
        "fo" = "cd ~/projects/frontend-monorepo && nvim .";
        "no" = "cd ~/projects/nixos-config && nvim .";
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
        command = ${pkgs.fish}/bin/fish --login --interactive
        shell-integration = none
        font-family = Iosevka Kitty Extended
        font-size = 16
        font-thicken = true
        font-thicken-strength = 32
      '';
    };
  };
}
