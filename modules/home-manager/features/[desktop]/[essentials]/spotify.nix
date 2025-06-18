{pkgs, ...}: {
  config = {
    home = {
      packages = with pkgs; [
        spotify
      ];

      persistence."/persist" = {
        directories = [
          ".config/spotify"
        ];
      };
    };
  };
}
