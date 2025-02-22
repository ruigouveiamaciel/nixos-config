{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [myNeovim];
  };
}
