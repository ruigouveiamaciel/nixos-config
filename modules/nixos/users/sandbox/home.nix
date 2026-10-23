{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/shell/starship.nix"
    "${myModulesPath}/development/shell/git.nix"
    "${myModulesPath}/development/toolchains"
    "${myModulesPath}/desktop/apps/3d-printing.nix"
  ];

  config = {
    programs.git = {
      settings = {
        user = {
          email = "5m0k3w0w+ai@proton.me";
          name = "SmOkEwOw";
        };
      };
    };
  };
}
