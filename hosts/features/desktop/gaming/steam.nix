{pkgs, ...}: {
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
    bottles
  ];

  environment.sessionVariables = {
    # TODO: Move this into home manager
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/rui/.steam/root/compatibilitytools.d";
  };

  programs.gamemode.enable = true;
}
