{lib, ...}: {
  programs.starship = {
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    enable = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$git_branch"
        "("
        "at "
        "$directory"
        ")"
        "$cmd_duration"
        "("
        "via "
        "$nodejs"
        "$rust"
        "$golang"
        ")"
        "$line_break"
        "$character"
      ];

      character = {
        error_symbol = "[\\$](bold red)";
        success_symbol = "[\\$](bold green)";
        vimcmd_symbol = "[:](bold yellow)";
        vimcmd_visual_symbol = "[:](bold cyan)";
        vimcmd_replace_symbol = "[:](bold purple)";
        vimcmd_replace_one_symbol = "[:](bold purple)";
      };

      username = {
        disabled = false;
        show_always = true;
        format = "[$user]($style) ";
      };

      git_branch = {
        truncation_length = 32;
      };

      rust = {
        format = "[$symbol($version )]($style)";
      };

      nodejs = {
        format = "[$symbol($version )]($style)";
      };

      golang = {
        format = "[$symbol($version )]($style)";
      };
    };
  };
}
