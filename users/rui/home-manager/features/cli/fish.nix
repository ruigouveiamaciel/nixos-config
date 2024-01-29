{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasEza = hasPackage "eza";
  hasTaskwarrior = hasPackage "taskwarrior";
  hasXClip = hasPackage "xclip";
in {
  programs.fish = {
    enable = true;
    shellAbbrs = rec {
      ls = mkIf hasEza "eza";
      tt = mkIf hasTaskwarrior "task next due.before:tomorrow";
      clip = mkIf hasXClip "xclip -selection clipboard";
      
      rebuild-sputnik = "NIX_SSHOPTS=\"-o RequestTTY=force\" nixos-rebuild switch --target-host rui@sputnik.maciel.sh --use-remote-sudo --flake .#sputnik";
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

      # Use terminal colors
      set -U fish_color_autosuggestion      brblack
      set -U fish_color_cancel              -r
      set -U fish_color_command             brgreen
      set -U fish_color_comment             brmagenta
      set -U fish_color_cwd                 green
      set -U fish_color_cwd_root            red
      set -U fish_color_end                 brmagenta
      set -U fish_color_error               brred
      set -U fish_color_escape              brcyan
      set -U fish_color_history_current     --bold
      set -U fish_color_host                normal
      set -U fish_color_match               --background=brblue
      set -U fish_color_normal              normal
      set -U fish_color_operator            cyan
      set -U fish_color_param               brblue
      set -U fish_color_quote               yellow
      set -U fish_color_redirection         bryellow
      set -U fish_color_search_match        'bryellow' '--background=brblack'
      set -U fish_color_selection           'white' '--bold' '--background=brblack'
      set -U fish_color_status              red
      set -U fish_color_user                brgreen
      set -U fish_color_valid_path          --underline
      set -U fish_pager_color_completion    normal
      set -U fish_pager_color_description   yellow
      set -U fish_pager_color_prefix        'white' '--bold' '--underline'
      set -U fish_pager_color_progress      'brwhite' '--background=cyan'
    '';
  };

  home.persistence."/nix/persist${config.home.homeDirectory}" = {
    directories = [".local/share/fish"];
  };
}
