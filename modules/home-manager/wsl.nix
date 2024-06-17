{lib, ...}: {
  options.wsl = {
    enable = lib.mkEnableOption "Whether this config belongs to a WSL instance or not";
  };
}
