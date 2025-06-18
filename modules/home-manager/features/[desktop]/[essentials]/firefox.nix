{pkgs, ...}: {
  config = {
    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
    };

    home.persistence."/persist" = {
      directories = [
        ".librewolf"
      ];
    };
  };
}
