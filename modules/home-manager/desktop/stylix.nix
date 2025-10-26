{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  home.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.open-dyslexic
    iosevka
    open-dyslexic
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      sizes = {
        applications = 11;
        desktop = 11;
        popups = 11;
        terminal = 15;
      };

      serif = {
        package = pkgs.open-dyslexic;
        name = "OpenDyslexic";
      };

      sansSerif = {
        package = pkgs.open-dyslexic;
        name = "OpenDyslexic";
      };

      monospace = {
        package = pkgs.iosevka;
        name = "Iosevka Extended";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
