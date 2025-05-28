_: {
  config = {
    programs.starship = {
      # TODO: Configure a nicer starship config
      enable = true;
      settings = {
        format = ''
          $all$fill$time$line_break$jobs$battery$status$os$shell$character
        '';

        fill = {
          disabled = false;
          symbol = " ";
        };

        container.disabled = true;
        time.disabled = true;

        character = {
          error_symbol = "[↪](bold red)";
          success_symbol = "[↪](bold green)";
          vimcmd_symbol = "[:](bold yellow)";
          vimcmd_visual_symbol = "[:](bold cyan)";
          vimcmd_replace_symbol = "[:](bold purple)";
          vimcmd_replace_one_symbol = "[:](bold purple)";
        };
      };
    };
  };
}
