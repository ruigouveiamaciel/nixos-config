{
  pkgs,
  lib,
  config,
  ...
}: {
  # Required for custom fonts to be detected
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    myPackages.iosevka-kitty
  ];

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = lib.getExe config.programs.fish.package;
    };
    extraConfig = ''
      # Clear all default shortcuts
      clear_all_shortcuts yes

      # Left Option = tmux bindings
      # Right Option = special characters (@, #, etc.)
      macos_option_as_alt left

      # Clipboard
      map --allow-fallback=shifted,ascii ctrl+shift+c copy_to_clipboard
      map --allow-fallback=shifted,ascii cmd+c copy_or_noop
      map --allow-fallback=shifted,ascii ctrl+c copy_or_interrupt

      map --allow-fallback=shifted,ascii ctrl+shift+v paste_from_clipboard
      map --allow-fallback=shifted,ascii cmd+v paste_from_clipboard
      map --allow-fallback=shifted,ascii ctrl+v paste_from_clipboard

      # Font size
      map ctrl+shift+plus change_font_size all +2.0
      map ctrl+shift+kp_add change_font_size all +2.0
      map ctrl+shift+minus change_font_size all -2.0
      map ctrl+shift+kp_subtract change_font_size all -2.0
      map ctrl+shift+0 change_font_size all 0

      # Fonts
      font_family Iosevka Kitty
      bold_font Iosevka Kitty Bold
      italic_font Iosevka Kitty Italic
      bold_italic_font Iosevka Kitty Bold Italic
      font_size 14.0

      ## name:     Catppuccin Kitty Macchiato
      ## author:   Catppuccin Org
      ## license:  MIT
      ## upstream: https://github.com/catppuccin/kitty/blob/main/themes/macchiato.conf
      ## blurb:    Soothing pastel theme for the high-spirited!

      # The basic colors
      foreground              #cad3f5
      background              #24273a
      selection_foreground    #24273a
      selection_background    #f4dbd6

      # Cursor colors
      cursor                  #f4dbd6
      cursor_text_color       #24273a

      # Scrollbar colors
      scrollbar_handle_color  #939ab7
      scrollbar_track_color   #494d64

      # URL color when hovering with mouse
      url_color               #f4dbd6

      # Kitty window border colors
      active_border_color     #b7bdf8
      inactive_border_color   #6e738d
      bell_border_color       #eed49f

      # OS Window titlebar colors
      wayland_titlebar_color system
      macos_titlebar_color system

      # Tab bar colors
      active_tab_foreground   #181926
      active_tab_background   #c6a0f6
      inactive_tab_foreground #cad3f5
      inactive_tab_background #1e2030
      tab_bar_background      #181926

      # Colors for marks (marked text in the terminal)
      mark1_foreground #24273a
      mark1_background #b7bdf8
      mark2_foreground #24273a
      mark2_background #c6a0f6
      mark3_foreground #24273a
      mark3_background #7dc4e4

      # The 16 terminal colors

      # black
      color0 #494d64
      color8 #5b6078

      # red
      color1 #ed8796
      color9 #ed8796

      # green
      color2  #a6da95
      color10 #a6da95

      # yellow
      color3  #eed49f
      color11 #eed49f

      # blue
      color4  #8aadf4
      color12 #8aadf4

      # magenta
      color5  #f5bde6
      color13 #f5bde6

      # cyan
      color6  #8bd5ca
      color14 #8bd5ca

      # white
      color7  #b8c0e0
      color15 #a5adcb
    '';
  };
}
