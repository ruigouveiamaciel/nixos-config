{
  pkgs,
  lib,
  ...
}: {
  config.vim = {
    package = pkgs.neovim-unwrapped;
    extraPackages = with pkgs; [
      ripgrep
      fd
      fzf
      imagemagick
      lazygit
    ];

    viAlias = true;
    vimAlias = true;
    debugMode = {
      enable = false;
      level = 16;
      logFile = "/tmp/nvim.log";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      editorconfig = true;
    };

    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };

    undoFile.enable = true;
    searchCase = "smart";

    options = {
      wrap = false; # Disabled line wrapping
      mouse = ""; # Disable mouse support
      mousescroll = "ver:0,hor:0"; # Disable mouse scroll
      updatetime = 250; # Number of milliseconds before "Cursor hold" event is fired
      scrolloff = 15;
      colorcolumn = "80";
      timeoutlen = 400;
      hlsearch = true;
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    keymaps = [
      {
        key = "<Esc>";
        mode = "n";
        desc = "Clear highlight on search";
        action = "<cmd>nohlsearch<CR>";
      }
      {
        key = "<leader>fk";
        mode = "n";
        action = "<cmd>lua Snacks.picker.keymaps()<CR>";
      }
      {
        key = "gd";
        mode = "n";
        desc = "Goto definition";
        action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
      }
      {
        key = "gr";
        mode = "n";
        desc = "Goto references";
        action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
      }
      {
        key = "gi";
        mode = "n";
        desc = "Goto implementations";
        action = "<cmd>lua Snacks.picker.lsp_implementations()<CR>";
      }
      {
        key = "gt";
        mode = "n";
        desc = "Goto type definitions";
        action = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>";
      }
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
      {
        key = "<leader>tt";
        mode = "n";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        unique = true;
      }
      {
        key = "<leader>ft";
        mode = "n";
        action = "<cmd>lua Snacks.picker.todo_comments()<CR>";
        unique = true;
      }
      {
        key = "<leader>ff";
        mode = "n";
        action = "<cmd>lua Snacks.picker.files()<CR>";
        unique = true;
      }
      {
        key = "<leader>fg";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep()<CR>";
        unique = true;
      }
      {
        key = "<leader>f.";
        mode = "n";
        action = "<cmd>lua Snacks.picker.recent()<CR>";
        unique = true;
      }
      {
        key = "<leader>fr";
        mode = "n";
        action = "<cmd>lua Snacks.picker.resume()<CR>";
        unique = true;
      }
      {
        key = "<leader>fc";
        mode = "n";
        action = "<cmd>lua Snacks.picker.git_log()<CR>";
        unique = true;
      }
      {
        key = "<leader>fb";
        mode = "n";
        action = "<cmd>lua Snacks.picker.git_branches()<CR>";
        unique = true;
      }
      {
        key = "<leader>fs";
        mode = "n";
        action = "<cmd>lua Snacks.picker.git_stash()<CR>";
        unique = true;
      }
      {
        key = "<C-e>";
        mode = "n";
        action = "<cmd>lua Snacks.explorer.open()<CR>";
      }
      {
        key = "-";
        mode = "n";
        action = "<CMD>Oil<CR>";
        desc = "Open parent directiory";
      }
      {
        key = "<leader>gb";
        mode = "n";
        action = "<CMD>lua Snacks.gitbrowse()<CR>";
        desc = "Open this file in github/gitlab";
      }
      {
        key = "<leader>tl";
        mode = "n";
        lua = true;
        action =
          /*
          lua
          */
          ''
            function()
              if (vim.diagnostic.config().virtual_lines) then
                vim.diagnostic.config({ virtual_lines = false })
              else
                vim.diagnostic.config({ virtual_lines = true })
              end
            end
          '';
        desc = "Toggle diagnostic virtual lines";
      }
    ];

    theme = {
      enable = true;
      name = "catppuccin";
      style = "macchiato";
      transparent = true;
    };

    visuals = {
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
          excluded_filetypes = [
            "dropbar_menu"
            "dropbar_menu_fzf"
            "DressingInput"
            "cmp_docs"
            "cmp_menu"
            "noice"
            "prompt"
            "TelescopePrompt"
            "snacks_picker_list"
            "snacks_picker_input"
          ];
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

    augroups = [
      {
        name = "highlight-yank";
        clear = true;
      }
      {
        name = "nvf_nvim_lint";
      }
    ];

    autocmds = [
      {
        event = ["TextYankPost"];
        group = "highlight-yank";
        callback =
          lib.mkLuaInline
          /*
          lua
          */
          ''
            function(args)
              vim.hl.on_yank()
             end
          '';
      }
      {
        event = ["BufWritePost" "BufEnter" "TextChanged" "InsertLeave"];
        group = "nvf_nvim_lint";
        callback =
          lib.mkLuaInline
          /*
          lua
          */
          ''
            function(args)
               nvf_lint(args.buf)
             end
          '';
      }
      {
        # Resize splits when window size changes. Super useful with aerospace
        event = ["VimResized"];
        pattern = ["*"];
        command = "wincmd =";
      }
    ];

    binds = {
      whichKey.enable = true;
      hardtime-nvim.enable = false;
    };

    git = {
      enable = true;
      gitsigns.enable = true;
      git-conflict.enable = true;
      vim-fugitive.enable = true;
    };

    notes = {
      todo-comments.enable = true;
    };

    ui = {
      noice.enable = true;
      colorizer.enable = true;
      breadcrumbs.enable = true;
      nvim-ufo.enable = true;
    };

    utility = {
      sleuth.enable = true;
      snacks-nvim = {
        enable = true;
        setupOpts = {
          bigfile.enable = true;
          scope.enable = true;
          quickfile.enable = true;
          image.enable = true;
          terminal.enable = true;
          picker.enable = true;
          explorer.enable = true;
          git.enable = true;
          gitbrowse.enable = true;
          notify.enable = true;
          notifier.enable = true;
        };
      };
      oil-nvim = {
        enable = true;
        setupOpts = {
          default_file_explorer = true;
          use_default_keymaps = false;
          keymaps = {
            "gh" = "actions.show_help";
            "<CR>" = "actions.select";
            "<C-p>" = "actions.preview";
            "<Esc>" = "actions.close";
            "-" = "actions.parent";
            "_" = "actions.open_cwd";
            "gs" = "actions.change_sort";
            "g." = "actions.toggle_hidden";
          };
          view_options = {
            show_hidden = false;
          };
        };
      };
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "auto";
      };
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      otter-nvim.enable = true;
    };

    autocomplete.blink-cmp = {
      enable = true;
      mappings = {
        complete = "<C-.>";
        close = "<C-e>";
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
      nvim-lint = {
        enable = true;
        lint_after_save = false; # We do this in our custom autocmd
        lint_function =
          lib.mkLuaInline
          /*
          lua
          */
          ''
            function(buf)
              local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
              local linters = require("lint").linters
              local linters_from_ft = require("lint").linters_by_ft[ft]

              -- if no linter is configured for this filetype, stops linting
              if linters_from_ft == nil then return end

              local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
              local client = get_clients({ buf = buf })[1] or { root_dir = vim.fn.getcwd() }
              local client_root = client.root_dir

              for _, name in ipairs(linters_from_ft) do
                local linter = linters[name]
                assert(linter, 'Linter with name `' .. name .. '` not available')

                if type(linter) == "function" then
                  linter = linter()
                end
                -- for require("lint").lint() to work, linter.name must be set
                linter.name = linter.name or name
                local cwd = linter.required_files

                if (name == "eslint_d") then
                  if (client_root) then
                    require("lint").lint(linter, { cwd = client_root })
                  end
                else
                  -- if no configuration files are configured, lint
                  if cwd == nil then
                    require("lint").lint(linter)
                  else
                    -- if configuration files are configured and present in the project, lint
                    for _, fn in ipairs(cwd) do
                      local path = vim.fs.joinpath(linter.cwd or vim.fn.getcwd(), fn);
                      if vim.uv.fs_stat(path) then
                        require("lint").lint(linter)
                        break
                      end
                    end
                  end
                end
              end
            end
          '';
      };
    };

    formatter = {
      conform-nvim = {
        enable = true;
        setupOpts = {
          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 500;
          };
        };
      };
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true;
      markdown = {
        enable = true;
        extensions.render-markdown-nvim.enable = true;
      };
      bash.enable = true;
      css.enable = true;
      html.enable = true;
      ts.enable = true;
      go.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      zen-mode = {
        package = zen-mode-nvim;
        setup =
          /*
          lua
          */
          ''
            require("zen-mode").setup {
                window = {
                  backdrop = 0.8,
                  width = 140,
                  height = 1,
                },
              }
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
    };
  };
}
