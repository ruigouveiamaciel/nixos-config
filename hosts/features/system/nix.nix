{
  inputs,
  lib,
  ...
}: {
  nix = {
    settings = {
      trusted-users = ["root" "@wheel"];
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than +7";
    };
  };
}
