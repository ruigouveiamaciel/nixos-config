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
      lsof
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
    };

    keymaps = [
      {
        key = "<Esc>";
        mode = "n";
        action = "<cmd>nohlsearch<CR>";
        desc = "Clear highlight on search";
      }
      {
        key = "<leader>fk";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.keymaps()<CR>";
        desc = "Search keymaps";
      }
      {
        key = "gd";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
        desc = "Goto definition";
      }
      {
        key = "gr";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
        desc = "Goto references";
      }
      {
        key = "gi";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.lsp_implementations()<CR>";
        desc = "Goto implementations";
      }
      {
        key = "gt";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>";
        desc = "Goto type definitions";
      }
      {
        key = "<C-h>";
        mode = "n";
        action = "<C-w><C-h>";
        desc = "Move focus to the left window";
      }
      {
        key = "<C-l>";
        mode = "n";
        action = "<C-w><C-l>";
        desc = "Move focus to the right window";
      }
      {
        key = "<C-k>";
        mode = "n";
        action = "<C-w><C-k>";
        desc = "Move focus to the upper window";
      }
      {
        key = "<C-j>";
        mode = "n";
        action = "<C-w><C-j>";
        desc = "Move focus to the lower window";
      }
      {
        key = "<F1>";
        mode = "n";
        action = "<nop>";
      }
      {
        key = "<leader>ft";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.todo_comments()<CR>";
        desc = "Find todo comments";
      }
      {
        key = "<leader>ff";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.files()<CR>";
        desc = "Find files";
      }
      {
        key = "<leader>fg";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.grep()<CR>";
        desc = "Grep files";
      }
      {
        key = "<leader>f.";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.recent()<CR>";
        desc = "Find recent files";
      }
      {
        key = "<leader>fr";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.resume()<CR>";
        desc = "Resume find";
      }
      {
        key = "<leader>fc";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.git_log()<CR>";
        desc = "Find git commits";
      }
      {
        key = "<leader>fb";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.git_branches()<CR>";
        desc = "Find git branches";
      }
      {
        key = "<leader>fs";
        mode = "n";
        unique = true;
        action = "<cmd>lua Snacks.picker.git_stash()<CR>";
        desc = "Find git stashes";
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
        key = "<leader>tu";
        mode = "n";
        action = "<CMD>UndotreeToggle<CR>";
        desc = "Toggle undo tree";
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
      {
        key = "<leader>tb";
        mode = "n";
        lua = true;
        action =
          /*
          lua
          */
          ''
            function()
              local closed = false
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "fugitiveblame" then
                  vim.api.nvim_win_close(win, true)
                  closed = true
                end
              end

              if not closed then
                vim.cmd("Git blame")
              end
            end
          '';
        desc = "Toggle git blame";
      }
      {
        key = "<leader>tg";
        mode = "n";
        lua = true;
        action =
          /*
          lua
          */
          ''
            function()
              local closed = false
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.bo[buf].filetype == "fugitive" then
                    vim.api.nvim_win_close(win, true)
                    closed = true
                  end
                end

                if not closed then
                  vim.cmd("Git")
                end
              end
          '';
        desc = "Toggle git fugitive";
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
        event = ["BufWritePost" "BufEnter" "TextChanged"];
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
        # Resize splits when window size changes. Super useful with tiling
        # window managers
        event = ["VimResized"];
        pattern = ["*"];
        command = "wincmd =";
      }
    ];

    binds.whichKey.enable = true;
    git.enable = true;
    notes.todo-comments.enable = true;

    ui = {
      noice.enable = true;
      colorizer.enable = true;
      breadcrumbs.enable = true;
    };

    utility = {
      undotree.enable = true;
      sleuth.enable = true;
      snacks-nvim = {
        enable = true;
        setupOpts = {
          bigfile.enable = true;
          scope.enable = true;
          quickfile.enable = true;
          image.enable = true;
          picker.enable = true;
          input.enable = true;
          terminal.enable = true;
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
        extraActiveSection.c = [
          /*
          lua
          */
          ''
            {
              function()
                local macro_reg = vim.fn.reg_recording()
                if macro_reg ~= "" then
                  return "Recording Macro: @" .. macro_reg
                else
                  return ""
                end
              end,
              cond = function() return vim.fn.reg_recording() ~= "" end,
            }
          ''
        ];
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
      setupOpts = {
        completion = {
          accept = {
            auto_brackets = {
              enabled = false;
            };
          };
        };
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
                  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
                  local eslint_config = vim.fs.find(
                    { ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml", "eslint.config.js" },
                    { upward = true, path = buf_dir }
                  )[1]

                  local lint_cwd = eslint_config and vim.fs.dirname(eslint_config) or client_root or vim.fn.getcwd()
                  require("lint").lint(linter, { cwd = lint_cwd })
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
      yaml.enable = true;
      rust.enable = true;
      python.enable = true;
      svelte.enable = true;
      tailwind.enable = true;
      sql.enable = true;
      java.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      opencode-nvim = {
        package = opencode-nvim;
        after = ["snacks-nvim"];
        setup =
          /*
          lua
          */
          ''
            vim.g.opencode_opts = {
              -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on `opencode_opts`.
            }

            -- Required for `vim.g.opencode_opts.auto_reload`.
            vim.o.autoread = true

            -- Recommended/example keymaps.
            vim.keymap.set({"n", "v"}, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask about this" })
            vim.keymap.set("n", "<leader>os", function() require("opencode").select() end, { desc = "Select prompt" })
            vim.keymap.set({"n", "v"}, "<leader>o+", function() require("opencode").prompt("@this") end, { desc = "Add this" })
            vim.keymap.set("n", "<leader>ot", function() require("opencode").toggle() end, { desc = "Toggle embedded" })
            vim.keymap.set("n", "<leader>oc", function() require("opencode").command() end, { desc = "Select command" })
            vim.keymap.set("n", "<leader>on", function() require("opencode").command("session_new") end, { desc = "New session" })
            vim.keymap.set("n", "<leader>oi", function() require("opencode").command("session_interrupt") end, { desc = "Interrupt session" })
            vim.keymap.set("n", "<leader>oA", function() require("opencode").command("agent_cycle") end, { desc = "Cycle selected agent" })
            vim.keymap.set("n", "<A-C-u>",    function() require("opencode").command("messages_half_page_up") end, { desc = "Messages half page up" })
            vim.keymap.set("n", "<A-C-d>",    function() require("opencode").command("messages_half_page_down") end, { desc = "Messages half page down" })
          '';
      };
    };
  };
}
