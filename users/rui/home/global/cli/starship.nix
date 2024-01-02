{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        $all$fill$time$line_break$jobs$battery$status$os$container$shell$character
      '';

      fill = {
        disabled = false;
        symbol = " ";
      };

      character = {
        error_symbol = "[↪](bold red)";
        success_symbol = "[↪](bold green)";
        vimcmd_symbol = "[:](bold yellow)";
        vimcmd_visual_symbol = "[:](bold cyan)";
        vimcmd_replace_symbol = "[:](bold purple)";
        vimcmd_replace_one_symbol = "[:](bold purple)";
      };

      time = {
        disabled = true;
        format = "\\\[[$time]($style)\\\]";
      };
    };
  };
}
