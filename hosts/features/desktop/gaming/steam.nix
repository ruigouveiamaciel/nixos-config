{
  pkgs,
  config,
  ...
}: let
  userHomeDirs =
    builtins.map (
      user: "/home/${user.name}/.steam/root/compatibilitytools.d"
    )
    (builtins.attrValues config.users.users);
in {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraEnv = {};
      extraLibraries = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = builtins.concatStringsSep ":" userHomeDirs;
  };

  programs.gamemode.enable = true;
}
