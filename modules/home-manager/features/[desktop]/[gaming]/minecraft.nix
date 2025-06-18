{pkgs, ...}: {
  config = {
    home = {
      packages = [
        (pkgs.prismlauncher.override
          {
            jdks = [
              pkgs.temurin-jre-bin-8
              pkgs.temurin-jre-bin-17
            ];
          })
      ];

      persistence."/persist" = {
        directories = [
          ".local/share/PrismLauncher"
        ];
      };
    };
  };
}
