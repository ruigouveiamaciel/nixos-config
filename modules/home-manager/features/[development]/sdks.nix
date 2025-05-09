{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      gcc
      alejandra
      lua
      stylua
      go
      jq
      jless
    ];
  };
}
