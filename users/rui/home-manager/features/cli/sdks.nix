{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    rustc
    clippy
    rustfmt
    rust-analyzer
    gcc
    alejandra
    dotnet-sdk_8
    lua
    stylua
    nodejs_20
    python311Full
    python311Packages.pip
    python311Packages.pipx
  ];

  home.sessionVariables = {
    # Required in order for csharp_ls to work
    DOTNET_ROOT = "${pkgs.dotnet-sdk_8}";
  };
}
