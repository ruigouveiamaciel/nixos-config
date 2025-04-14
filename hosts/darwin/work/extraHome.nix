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

  programs.fish.shellInit = ''
    if test -n "$GHOSTTY_RESOURCES_DIR"
      . "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
    end
  '';

  # Ghostty config
  home.file = {
    "/Users/ruimaciel/.config/ghostty/config".text = ''
      theme = catppuccin-macchiato
      command = ${pkgs.fish}/bin/fish --login --interactive
      shell-integration = none
      font-size = 14
      font-thicken = true
      font-thicken-strength = 32
    '';
  };
}
