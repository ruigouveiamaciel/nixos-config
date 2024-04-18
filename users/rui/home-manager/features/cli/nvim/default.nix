{pkgs, ...}: {
  imports = [
    ./theme.nix
    ./lsp.nix
    ./cmp.nix
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    extraLuaConfig =
      /*
      lua
      */
      ''
        -- Set <space> as the leader key
        -- See `:help mapleader`
        --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        -- [[ Setting options ]]
        -- See `:help vim.opt`
        -- NOTE: You can change these options as you wish!
        --  For more options, you can see `:help option-list`

        -- Set to true if you have a Nerd Font installed and selected in the terminal
        vim.g.have_nerd_font = true

        -- Make line numbers default
        vim.opt.number = true
        -- You can also add relative line numbers, to help with jumping.
        vim.opt.relativenumber = true

        -- Don't show the mode, since it's already in the status line
        vim.opt.showmode = false

        -- Sync clipboard between OS and Neovim.
        --  Remove this option if you want your OS clipboard to remain independent.
        --  See `:help 'clipboard'`
        vim.opt.clipboard = 'unnamedplus'

        -- Enable break indent
        vim.opt.breakindent = true

        -- Save undo history
        vim.opt.undofile = true

        -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
        vim.opt.ignorecase = true
        vim.opt.smartcase = true

        -- Keep signcolumn on by default
        vim.opt.signcolumn = 'yes'

        -- Decrease update time
        vim.opt.updatetime = 250

        -- Decrease mapped sequence wait time
        -- Displays which-key popup sooner
        vim.opt.timeoutlen = 300

        -- Configure how new splits should be opened
        vim.opt.splitright = true
        vim.opt.splitbelow = true

        -- Sets how neovim will display certain whitespace characters in the editor.
        --  See `:help 'list'`
        --  and `:help 'listchars'`
        vim.opt.list = true
        vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

        -- Preview substitutions live, as you type!
        vim.opt.inccommand = 'split'

        -- Enable ruler
        vim.opt.colorcolumn = '80'

        -- Disable line wrap
        vim.opt.wrap = false


        -- Minimal number of screen lines to keep above and below the cursor.
        vim.opt.scrolloff = 10

        -- [[ Basic Keymaps ]]
        --  See `:help vim.keymap.set()`

        -- Set highlight on search, but clear on pressing <Esc> in normal mode
        vim.opt.hlsearch = true
        vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

        -- Diagnostic keymaps
        -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
        -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desh
        -- is not what someone will guess without a bit more experience.

        -- Disable arrow keys in normal mode and scrolling using the mouse.
        -- This is to remember myself to use HJKL.
        vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move left!"<CR>')
        vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move right!"<CR>')
        vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move up!"<CR>')
        vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move down!"<CR>')
        vim.keymap.set('n', '<ScrollWheelUp>', '<cmd>echo "Use k to move up!"<CR>')
        vim.keymap.set('n', '<S-ScrollWheelUp>', '<cmd>echo "Use k to move up!"<CR>')
        vim.keymap.set('n', '<C-ScrollWheelUp>', '<cmd>echo "Use k to move up!"<CR>')
        vim.keymap.set('n', '<ScrollWheelDown>', '<cmd>echo "Use j to move down!"<CR>')
        vim.keymap.set('n', '<S-ScrollWheelDown>', '<cmd>echo "Use j to move down!"<CR>')
        vim.keymap.set('n', '<C-ScrollWheelDown>', '<cmd>echo "Use j to move down!"<CR>')
        vim.keymap.set('n', '<ScrollWheelLeft>', '<cmd>echo "Use h to move left!"<CR>')
        vim.keymap.set('n', '<S-ScrollWheelLeft>', '<cmd>echo "Use h to move left!"<CR>')
        vim.keymap.set('n', '<C-ScrollWheelLeft>', '<cmd>echo "Use h to move left!"<CR>')
        vim.keymap.set('n', '<ScrollWheelRight>', '<cmd>echo "Use l to move right!"<CR>')
        vim.keymap.set('n', '<S-ScrollWheelRight>', '<cmd>echo "Use l to move right!"<CR>')
        vim.keymap.set('n', '<C-ScrollWheelRight>', '<cmd>echo "Use l to move right!"<CR>')

        -- Keybinds to make split navigation easier.
        --  Use CTRL+<hjkl> to switch between windows
        --
        --  See `:help wincmd` for a list of all window commands
        vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
        vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
        vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
        vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

        -- [[ Basic Autocommands ]]
        --  See `:help lua-guide-autocommands`

        -- Highlight when yanking (copying) text
        --  Try it with `yap` in normal mode
        --  See `:help vim.highlight.on_yank()`
        vim.api.nvim_create_autocmd('TextYankPost', {
          desc = 'Highlight when yanking (copying) text',
          group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
          callback = function()
            vim.highlight.on_yank()
          end,
        })
      '';

    plugins = with pkgs.vimPlugins; [
      # Comment selected lines/blocks of code
      vim-sleuth

      # Adds git related signs to the gutter, as well as utilities for managing
      # changes
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("gitsigns").setup {
              signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' }
              }
            }
          '';
      }

      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      nvim-web-devicons
      {
        plugin = telescope-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require('telescope').setup {
              extensions = {
                ['ui-select'] = {
                  require('telescope.themes').get_dropdown(),
                },
              },
            }

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            --vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            -- Slightly advanced example of overriding default behavior and theme
            vim.keymap.set('n', '<leader>/', function()
              -- You can pass additional configuration to Telescope to change the theme, layout, etc.
              builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
              })
            end, { desc = '[/] Fuzzily search in current buffer' })

            -- It's also possible to pass additional configuration options.
            --  See `:help telescope.builtin.live_grep()` for information about particular keys
            vim.keymap.set('n', '<leader>s/', function()
              builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
              }
            end, { desc = '[S]earch [/] in Open Files' })

            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>sn', function()
              builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end, { desc = '[S]earch [N]eovim files' })
          '';
      }

      # autoformating
      {
        plugin = conform-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("conform").setup({
              notify_on_error = false,
              format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true }
                return {
                  timeout_ms = 500,
                  lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
                }
              end,
              formatters_by_ft = {
                lua = { 'stylua' },
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                --
                -- You can use a sub-list to tell conform to run *until* a formatter
                -- is found.
                -- javascript = { { "prettierd", "prettier" } },
              },
            })

            vim.keymap.set('n', '<leader>f', function()
              require("conform").format { async = true, lsp_fallback = true }
            end, { desc = '[F]ormat buffer' })
          '';
      }

      # Highlight todo, notes, etc in comments
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = ''
          require("todo-comments").setup({
            signs = false
          })
        '';
      }

      # Collection of various small independent plugins/modules
      {
        plugin = mini-nvim;
        type = "lua";
        config = ''
          -- Better Around/Inside textobjects
          --
          -- Examples:
          --  - va)  - [V]isually select [A]round [)]paren
          --  - yinq - [Y]ank [I]nside [N]ext [']quote
          --  - ci'  - [C]hange [I]nside [']quote
          require('mini.ai').setup { n_lines = 500 }

          -- Add/delete/replace surroundings (brackets, quotes, etc.)
          --
          -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
          -- - sd'   - [S]urround [D]elete [']quotes
          -- - sr)'  - [S]urround [R]eplace [)] [']
          require('mini.surround').setup()

          -- Simple and easy statusline.
          --  You could remove this setup call if you don't like it,
          --  and try some other statusline plugin
          local statusline = require 'mini.statusline'
          -- set use_icons to true if you have a Nerd Font
          statusline.setup { use_icons = vim.g.have_nerd_font }

          -- You can configure sections in the statusline by overriding their
          -- default behavior. For example, here we set the section for
          -- cursor location to LINE:COLUMN
          ---@diagnostic disable-next-line: duplicate-set-field
          statusline.section_location = function()
            return '%2l:%-2v'
          end

          -- ... and there is more!
          --  Check out: https://github.com/echasnovski/mini.nvim
        '';
      }

      # Highlight, edit, and navigate code
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require('nvim-treesitter.configs').setup{
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
            }
          '';
      }

      # Other stuff
      pkgs.unstable.vimPlugins.cloak-nvim
      vim-fugitive
    ];
  };
}
