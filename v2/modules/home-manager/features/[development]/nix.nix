{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [deploy-rs nixos-anywhere];
  };
}
