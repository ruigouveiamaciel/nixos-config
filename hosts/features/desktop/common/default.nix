{
  imports = [
    ./plymouth.nix
    ./quietboot.nix
    ./pipewire.nix
    ./pentablet.nix
  ];

  environment.persistence = {
    "/nix/persist" = {
      hideMounts = true;
      directories = [
        "/sys/class/backlight"
      ];
    };
  };
}
