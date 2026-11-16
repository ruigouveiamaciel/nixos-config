{pkgs, ...}: let
  notify = pkgs.writeShellApplication {
    name = "notify";
    runtimeInputs = [pkgs.kitty];
    text = ''
      if [[ -n "''${TMUX:-}" ]]; then
        esc=$(kitten notify --only-print-escape-code "$@" | sed $'s/\x1b/\x1b\x1b/g')
        printf '%sPtmux;%s%s' $'\033' "$esc" $'\033\\'
      else
        exec kitten notify "$@"
      fi
    '';
  };
in {
  imports = [
    ./sandbox
    ./pi
  ];

  home.packages = [notify];
}
