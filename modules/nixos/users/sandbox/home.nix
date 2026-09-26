{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/shell/starship.nix"
    "${myModulesPath}/development/shell/git.nix"
    "${myModulesPath}/development/toolchains"
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
