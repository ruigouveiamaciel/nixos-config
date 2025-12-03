{
  lib,
  config,
  ...
}: let
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
in {
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ls = lib.mkIf (hasPackage "eza") "eza";
      ll = lib.mkIf (hasPackage "eza") "eza -lh";
    };
    functions = {
      fish_greeting = "";
    };
    interactiveShellInit = ''
      # Use vim bindings and cursors
      fish_vi_key_bindings
      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block

      # Source: https://www.robert-sokolewicz.nl/posts/18_auto_activate_conda/
      # Fish syntax highlighting
      set -g fish_color_autosuggestion '555'  'brblack'
      set -g fish_color_cancel -r
      set -g fish_color_command --bold
      set -g fish_color_comment red
      set -g fish_color_cwd green
      set -g fish_color_cwd_root red
      set -g fish_color_end brmagenta
      set -g fish_color_error brred
      set -g fish_color_escape 'bryellow'  '--bold'
      set -g fish_color_history_current --bold
      set -g fish_color_host normal
      set -g fish_color_match --background=brblue
      set -g fish_color_normal normal
      set -g fish_color_operator bryellow
      set -g fish_color_param cyan
      set -g fish_color_quote yellow
      set -g fish_color_redirection brblue
      set -g fish_color_search_match 'bryellow'  '--background=brblack'
      set -g fish_color_selection 'white'  '--bold'  '--background=brblack'
      set -g fish_color_user brgreen
      set -g fish_color_valid_path --underline
    '';
  };
}
