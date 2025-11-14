{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    nodejs_20
    pnpm_10
  ];
}
