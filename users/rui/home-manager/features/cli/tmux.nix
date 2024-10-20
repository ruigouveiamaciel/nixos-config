{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    customPaneNavigationAndResize = true;
    keyMode = "vi";
    prefix = "C-f";
    baseIndex = 1;
    mouse = true;
    escapeTime = 0;
    disableConfirmationPrompt = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      gruvbox
    ];
    extraConfig = ''
      set -g @tmux-gruvbox 'dark'
      bind-key -T prefix q display-panes -d 2000
    '';
  };
}
