{pkgs, lib, options, ...}: {
  config = lib.mkMerge ([
    {
      programs.direnv = {
        enable = true;
        package = pkgs.direnv;
        nix-direnv.enable = true;
      };
    }
  ] ++ (lib.optional (options.home ? "persistence") {
    home.persistence."/persist".directories = map (p: {
      directory = p;
      mode = "0700";
    }) [
      ".cache/direnv"
      ".local/share/direnv"
      ".config/direnv"
    ];
  }));
}
