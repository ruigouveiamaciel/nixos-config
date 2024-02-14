{
  environment.persistence = {
    "/nix/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections" # Network Manager Connections
      ];
    };
  };
}
