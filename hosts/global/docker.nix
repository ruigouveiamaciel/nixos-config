{pkgs, ...}: {
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  environment.persistence = {
    "/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/docker";
          user = "root";
          group = "root";
          mode = "0751";
        }
      ];
    };
  };
}
