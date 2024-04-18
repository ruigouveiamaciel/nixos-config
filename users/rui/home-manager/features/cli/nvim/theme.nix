{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Neovim Gruvbox Theme
    {
      plugin = gruvbox-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          vim.cmd.colorscheme 'gruvbox'
          vim.cmd.hi 'Comment gui=none'
        '';
    }

    # Notifications
    {
      plugin = fidget-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("fidget").setup {}
        '';
    }
  ];
}
