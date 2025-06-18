{pkgs, ...}: {
  config = {
    home = {
      packages = with pkgs; [
        vesktop
      ];

      persistence."/persist" = {
        directories = [
          ".config/vesktop"
        ];
      };
    };
  };
}
