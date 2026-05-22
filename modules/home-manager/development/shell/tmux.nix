{pkgs, ...}: let
  tmux-dev = pkgs.writeShellApplication {
    name = "tmux-dev";
    text = ''
      set -euo pipefail

      if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Usage: tmux-dev <session-name> [working-directory]" >&2
        exit 1
      fi

      session="$1"
      cwd="''${2:-$PWD}"

      if [ ! -d "$cwd" ]; then
        echo "tmux-dev: directory not found: $cwd" >&2
        exit 1
      fi

      if ! tmux has-session -t="$session" 2>/dev/null; then
        tmux new-session -d -s "$session" -c "$cwd" -n editor
        tmux send-keys  -t "$session:editor" "$EDITOR ." Enter
        tmux new-window -t "$session:" -c "$cwd" -n cmd
        tmux new-window -t "$session:" -c "$cwd" -n agent
        tmux select-window -t "$session:editor"
      fi

      if [ -n "''${TMUX:-}" ]; then
        tmux switch-client -t "$session"
      else
        tmux attach-session -t "$session"
      fi
    '';
  };

  tmux-repo = pkgs.writeShellApplication {
    name = "tmux-repo";
    runtimeInputs = [tmux-dev];
    text = ''
      set -euo pipefail

      DIR="$HOME/repositories"

      path=$(fd -H -t d '^\.git$' "$DIR/" --max-depth 3 -x dirname {} \
        | sort \
        | fzf --tmux center,80%,60% --delimiter="$DIR/" --with-nth=2) || exit 0

      [ -z "''${path:-}" ] && exit 0

      rel="''${path#"$DIR/"}"
      tmux-dev "r/$rel" "$path"
    '';
  };

  tmux-recent = pkgs.writeShellApplication {
    name = "tmux-recent";
    text = ''
      set -euo pipefail

      session=$(tmux list-sessions -F "#{session_last_attached}|#{session_name}" \
        | sort -rn \
        | cut -d'|' -f2 \
        | grep -Ev '^[0-9]+$' \
        | fzf --tmux center,80%,60%) || exit 0

      [ -z "''${session:-}" ] && exit 0

      if [ -n "''${TMUX:-}" ]; then
        tmux switch-client -t "$session"
      else
        tmux attach-session -t "$session"
      fi
    '';
  };

  tmux-proj = pkgs.writeShellApplication {
    name = "tmux-proj";
    runtimeInputs = [tmux-dev];
    text = ''
      set -euo pipefail

      DIR="$HOME/projects"

      path=$(fd -t d . "$DIR/" --max-depth 1 \
        | sort \
        | fzf --tmux center,80%,60% --delimiter="$DIR/" --with-nth=2) || exit 0

      [ -z "''${path:-}" ] && exit 0

      rel="''${path#"$DIR/"}"
      rel="''${rel%/}"
      tmux-dev "p/$rel" "$path"
    '';
  };
in {
  home.packages = [tmux-dev tmux-repo tmux-proj tmux-recent];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      # Extended keys (CSI u) for disambiguated modifier+key sequences
      set -as terminal-features 'xterm*:extkeys'
      set -s extended-keys on
      set -g extended-keys-format csi-u

      # Status bar
      set -g status-left-length 35
      set -g status-left "[#{=/30/…:session_name}]  "
      set -g status-right ""
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W*"
      set -g renumber-windows on

      # Pane navigation (hjkl)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Pane resizing (capital HJKL)
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 3
      bind -n M-K resize-pane -U 3
      bind -n M-L resize-pane -R 5

      # Pane splitting (s = split, v = vsplit)
      bind -n M-s split-window -v -c "#{pane_current_path}"
      bind -n M-v split-window -h -c "#{pane_current_path}"

      # Pane management
      bind -n M-z resize-pane -Z
      bind -n M-x confirm-before -p "kill-pane #P? (y/n)" kill-pane

      # Window management
      bind -n M-t new-window -c "#{pane_current_path}"
      bind -n M-w kill-window
      bind -n M-n next-window
      bind -n M-p previous-window
      bind -n M-u command-prompt -I "#W" "rename-window '%%'"

      # Jump directly to windows 1-10
      bind -n M-1 select-window -t :=1
      bind -n M-2 select-window -t :=2
      bind -n M-3 select-window -t :=3
      bind -n M-4 select-window -t :=4
      bind -n M-5 select-window -t :=5
      bind -n M-6 select-window -t :=6
      bind -n M-7 select-window -t :=7
      bind -n M-8 select-window -t :=8
      bind -n M-9 select-window -t :=9
      bind -n M-0 select-window -t :=10

      # Session / misc
      bind -n M-i run-shell tmux-proj
      bind -n M-o run-shell tmux-repo
      bind -n M-r run-shell tmux-recent
      bind -n M-d detach-client
      bind -n M-c source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"
    '';
  };
}
