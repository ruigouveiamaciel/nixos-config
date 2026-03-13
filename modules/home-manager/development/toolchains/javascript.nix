{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs_22
    pnpm_10
  ];
}
