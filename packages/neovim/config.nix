{
  pkgs,
  lib,
  ...
}: {
  config.vim = {
    package = pkgs.unstable.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    debugMode = {
      enable = false;
      level = 16;
      logFile = "/tmp/nvim.log";
    };

    extraPackages = with pkgs; [eslint_d];

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      editorconfig = true;
    };

    useSystemClipboard = true;
    undoFile.enable = true;
    searchCase = "smart";

    luaConfigPost =
      /*
      lua
      */
      ''
        -- Minimal number of screen lines to keep above and below the cursor.
        vim.opt.scrolloff = 15

        -- Set highlight on search, but clear on pressing <Esc> in normal mode
        vim.opt.hlsearch = true
        vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

        -- Disable line wrap
        vim.opt.wrap = false

        -- Decrease update time
        vim.opt.updatetime = 250

        -- Decrease mapped sequence wait time
        -- Displays which-key popup sooner
        vim.opt.timeoutlen = 300

        vim.api.nvim_create_autocmd("TextYankPost", {
          desc = "Highlight when yanking (copying) text",
          group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
          callback = function()
            vim.highlight.on_yank()
          end,
        })

        -- Enable ruler
        vim.opt.colorcolumn = '80'

        -- Toggle LSP Lines
        -- TODO: Fix this toggle for nvim 0.11
        -- vim.keymap.set('n', '<leader>tl', require('lsp_lines').toggle, { desc = 'Toggle LSP Lines' })

        -- Keymaps
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps [Telescope]' })
        vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = 'Recent files [Telescope]' })

        vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'Goto definition' })
        vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = 'Goto references' })
        vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'Goto implementation' })
        vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, { desc = 'Goto type definition' })
        vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, { desc = 'Goto type definition' })

        --local lspconfig = require('lspconfig')
        --lspconfig.eslint.setup({
        --    cmd = { "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server", "--stdio" };
        --    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        --})
      '';

    keymaps = [
      # Disable moving with arrow keys and scroll
      {
        key = "<left>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use h to move left!'<CR>";
      }
      {
        key = "<right>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use l to move right!'<CR>";
      }
      {
        key = "<up>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use k to move up!'<CR>";
      }
      {
        key = "<down>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use j to move down!'<CR>";
      }
      {
        key = "<ScrollWheelLeft>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use h to move left!'<CR>";
      }
      {
        key = "<ScrollWheelRight>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use l to move right!'<CR>";
      }
      {
        key = "<ScrollWheelUp>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use k to move up!'<CR>";
      }
      {
        key = "<ScrollWheelDown>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use j to move down!'<CR>";
      }
      {
        key = "<S-ScrollWheelLeft>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use h to move left!'<CR>";
      }
      {
        key = "<S-ScrollWheelRight>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use l to move right!'<CR>";
      }
      {
        key = "<S-ScrollWheelUp>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use k to move up!'<CR>";
      }
      {
        key = "<S-ScrollWheelDown>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use j to move down!'<CR>";
      }
      {
        key = "<C-ScrollWheelLeft>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use h to move left!'<CR>";
      }
      {
        key = "<C-ScrollWheelRight>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use l to move right!'<CR>";
      }
      {
        key = "<C-ScrollWheelUp>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use k to move up!'<CR>";
      }
      {
        key = "<C-ScrollWheelDown>";
        mode = ["n" "v"];
        action = "<cmd>echo 'Use j to move down!'<CR>";
      }

      # Keybinds to make split navigation easier
      {
        key = "<C-h>";
        mode = "n";
        desc = "Move focus to the left window";
        action = "<C-w><C-h>";
      }
      {
        key = "<C-l>";
        mode = "n";
        desc = "Move focus to the right window";
        action = "<C-w><C-l>";
      }
      {
        key = "<C-k>";
        mode = "n";
        desc = "Move focus to the upper window";
        action = "<C-w><C-k>";
      }
      {
        key = "<C-j>";
        mode = "n";
        desc = "Move focus to the lower window";
        action = "<C-w><C-j>";
      }
      {
        key = "<F1>";
        mode = "n";
        action = "<nop>";
      }
    ];

    theme = {
      enable = true;
      name = "catppuccin";
      style = "macchiato";
      transparent = false;
    };

    spellcheck = {
      enable = false;
      languages = ["en"];
      programmingWordlist.enable = true;
    };

    visuals = {
      fidget-nvim = {
        enable = true;
        setupOpts.notification.view.stack_upwards = false;
      };
      nvim-web-devicons.enable = true;
      highlight-undo.enable = true;
      indent-blankline.enable = true;

      nvim-scrollbar = {
        enable = true;
        setupOpts = {
          hide_if_all_visible = true;
          handlers = {
            cursor = false;
            gitsigns = true;
          };
        };
      };

      nvim-cursorline = {
        enable = true;
        setupOpts = {
          cursorline = {
            enable = true;
            timeout = 0;
            number = false;
          };
        };
      };
    };

    autocmds = [
      {
        event = ["BufEnter" "InsertLeave" "TextChanged"];
        callback = lib.mkLuaInline ''
          function()
            require("lint").try_lint()
          end
        '';
      }
    ];

    binds = {
      whichKey.enable = true;
    };

    git = {
      enable = true;
      gitsigns = {
        enable = true;
      };
      git-conflict = {
        enable = true;
      };
      vim-fugitive.enable = true;
    };

    notes = {
      todo-comments.enable = true;
    };

    ui = {
      noice.enable = true;
      colorizer.enable = true;
      breadcrumbs.enable = true;
    };

    utility = {
      surround.enable = true;
    };

    terminal = {
      toggleterm = {
        enable = false;
        mappings.open = "<leader>tt";
      };
    };

    telescope = {
      enable = true;
      setupOpts.defaults.vimgrep_arguments = [
        "${pkgs.ripgrep}/bin/rg"
        "--color=never"
        "--with-filename"
        "--line-number"
        "--column"
        "--hidden"
        "--smart-case"
        "--glob"
        "!**/.git/*"
        "--glob"
        "!**/node_modules/*"
      ];
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "auto";
      };
    };

    lsp = {
      formatOnSave = true;
      otter-nvim.enable = true;
      null-ls = {
        enable = true;
        setupOpts = {
          sources = {
            eslint_d = lib.mkLuaInline ''
              require("none-ls.diagnostics.eslint_d"),
              require("none-ls.code_actions.eslint_d"),
            '';
          };
        };
      };
    };

    autocomplete.nvim-cmp = {
      enable = true;
      mappings = {
        complete = "<C-Space>";
        close = "<Esc>";
        confirm = "<CR>";
        next = "<C-n>";
        previous = "<C-p>";
      };
    };

    diagnostics = {
      enable = true;
      config = {
        underline = true;
        virtual_lines = true;
        virtual_text = false;
      };
    };

    languages = {
      enableLSP = true;
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true;
      markdown.enable = true;
      bash.enable = true;
      css.enable = true;
      html.enable = true;
      ts.enable = true;
      go.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      none-ls-extras = {
        package = pkgs.vimUtils.buildVimPlugin {
          name = "none-ls-extras";
          src = pkgs.fetchFromGitHub {
            owner = "nvimtools";
            repo = "none-ls-extras.nvim";
            rev = "1214d729e3408470a7b7a428415a395e5389c13c";
            hash = "sha256-5wQHdV2lmxMegN/BPg+qfGTNGv/T9u+hy4Yaj41PchI=";
          };
        };
      };

      vim-sleuth = {
        package = vim-sleuth;
      };

      # TODO: Use vim.utility.oil-nvim instead
      oil-nvim = {
        package = oil-nvim;
        setup =
          /*
          lua
          */
          ''
            require('oil').setup {
              default_file_explorer = true,
              use_default_keymaps = false,
              keymaps = {
                ["gh"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["<C-p>"] = "actions.preview",
                ["<Esc>"] = "actions.close",
                ["-"] = "actions.parent",
                ["_"] = "actions.open_cwd",
                ["gs"] = "actions.change_sort",
                ["g."] = "actions.toggle_hidden",
              },
              view_options = {
                show_hidden = false;
              }
            }

            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
          '';
      };

      undotree = {
        package = undotree;
        setup =
          /*
          lua
          */
          ''
            vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Undo tree" })
          '';
      };

      telescope-ui-select = {
        package = telescope-ui-select-nvim;
        setup =
          /*
          lua
          */
          ''
            local telescope = require("telescope")
            telescope.load_extension("ui-select")
          '';
      };

      git-blame = {
        package = pkgs.vimUtils.buildVimPlugin {
          name = "git-blame";
          src = pkgs.fetchFromGitHub {
            owner = "f-person";
            repo = "git-blame.nvim";
            rev = "2883a7460f611c2705b23f12d58d398d5ce6ec00";
            hash = "sha256-mFzm0hkO0iei3yekOXrQpeCJimwzBLgXLZtK1DjjoE4=";
          };
        };
        setup =
          /*
          lua
          */
          ''
            -- I only want the commands provided by the plugin
            require('gitblame').setup {
              enabled = false,
            }
          '';
      };
    };
  };
}
