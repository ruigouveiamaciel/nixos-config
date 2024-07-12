{pkgs, ...}: let
  harpoon-nvim-github = pkgs.vimUtils.buildVimPlugin {
    name = "harpoon-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "ThePrimeagen";
      repo = "harpoon";
      rev = "0378a6c428a0bed6a2781d459d7943843f374bce";
      hash = "sha256-FZQH38E02HuRPIPAog/nWM55FuBxKp8AyrEldFkoLYk=";
    };
  };
in {
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
        --  NOTE: This must be set before plugins are loaded (otherwise wrong
        --  leader will be used)
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        -- [[ Setting options ]]
        -- See `:help vim.opt`

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
        vim.opt.scrolloff = 15

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

        -- Disable keybinds that are redudant or useless
        vim.keymap.set('n', '-', '<nop>')
        vim.keymap.set('n', '+', '<nop>')

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

      # Automatically adjust shiftwidth and expandtab based on the current file
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

      # Git utilities
      vim-fugitive

      # Telescope and its dependencies
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
            vim.keymap.set('n', '<leader>sc', function()
              builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                -- winblend = 10,
                previewer = false,
              })
            end, { desc = '[/] Fuzzily search in current buffer' })
            vim.keymap.set('n', '<leader>so', function()
              builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
              }
            end, { desc = '[S]earch [/] in Open Files' })
          '';
      }

      # Provides LSP features and a code completion source for code embedded in
      # other documents, such as the lua configs in this nix file.
      otter-nvim

      # Automatically install LSPs and related tools
      mason-nvim
      mason-lspconfig-nvim
      mason-tool-installer-nvim

      # LSP configuration
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
              callback = function(event)
                local map = function(keys, func, desc)
                  vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                -- Find references for the word under your cursor.
                map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map('gt', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

                -- Rename the variable under your cursor.
                --  Most Language Servers support renaming across files, etc.
                map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map('<Ctrl>.', vim.lsp.buf.code_action, '[C]ode [A]ction')

                -- Opens a popup that displays documentation about the word under your cursor
                --  See `:help K` for why this keymap.
                map('K', vim.lsp.buf.hover, 'Hover Documentation')

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                -- The following autocommand is used to enable inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                  map('<leader>th', function()
                    vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
                  end, '[T]oggle Inlay [H]ints')
                end
              end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local servers = {
              clangd = {},
              pyright = {},
              rust_analyzer = {},
              tsserver = {},
              svelte = {},
              eslint = {},
              html = {},
              omnisharp = {},
              nil_ls = {
                settings = {
                  ['nil'] = {
                    formatting = { command = { "alejandra" }}
                  }
                }
              },
              lua_ls = {
                settings = {
                  Lua = {
                    completion = {
                      callSnippet = 'Replace',
                    }
                  }
                }
              }
            }

            -- Ensure the servers and tools above are installed
            --  To check the current status of installed tools and/or manually install
            --  other tools, you can run
            --    :Mason
            --
            --  You can press `g?` for help in this menu.
            require('mason').setup({
              keymaps = {
                -- Keymap to expand a package
                toggle_package_expand = "<CR>",
                -- Keymap to install the package under the current cursor position
                install_package = "i",
                -- Keymap to reinstall/update the package under the current cursor position
                update_package = "u",
                -- Keymap to check for new version for the package under the current cursor position
                check_package_version = "c",
                -- Keymap to update all installed packages
                update_all_packages = "U",
                -- Keymap to check which installed packages are outdated
                check_outdated_packages = "C",
                -- Keymap to uninstall a package
                uninstall_package = "X",
                -- Keymap to cancel a package installation
                cancel_installation = "<C-c>",
                -- Keymap to apply language filter
                apply_language_filter = "<C-f>",
                -- Keymap to toggle viewing package installation log
                toggle_package_install_log = "<CR>",
                -- Keymap to toggle the help view
                toggle_help = "gh",
              }
            })

            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
              'stylua', -- Used to format Lua code
              'csharpier', -- Used to format C# code
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            require('mason-lspconfig').setup {
              handlers = {
                function(server_name)
                  local server = servers[server_name] or {}
                  -- This handles overriding only values explicitly passed
                  -- by the server configuration above. Useful when disabling
                  -- certain features of an LSP (for example, turning off formatting for tsserver)
                  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                  require('lspconfig')[server_name].setup(server)
                end,
              },
            }
          '';
      }

      # nvim-comp sources
      cmp-nvim-lsp
      cmp-path
      cmp-git
      cmp-nvim-lsp-signature-help

      # Auto complete
      {
        plugin = nvim-cmp;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            -- See `:help cmp`
            local cmp = require 'cmp'

            cmp.setup {
              completion = { completeopt = 'menu,menuone,noinsert' },
              -- For an understanding of why these mappings were
              -- chosen, you will need to read `:help ins-completion`
              mapping = cmp.mapping.preset.insert {
                -- Select the [n]ext item
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<Down>'] = cmp.mapping.select_next_item(),
                -- Select the [p]revious item
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<Up>'] = cmp.mapping.select_prev_item(),
                -- Scroll the documentation window [b]ack / [f]orward
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                -- Accept ([y]es) the completion.
                --  This will auto-import if your LSP supports it.
                --  This will expand snippets if the LSP sent a snippet.
                ['<C-y>'] = cmp.mapping.confirm { select = true },
                ['<CR>'] = cmp.mapping.confirm { select = true },
                -- Manually trigger a completion from nvim-cmp.
                --  Generally you don't need this, because nvim-cmp will display
                --  completions whenever it has completion options available.
                ['<C-Space>'] = cmp.mapping.complete {},
              },
              sources = {
                { name = 'otter' },
                { name = 'nvim_lsp' },
                { name = 'path' },
                { name = 'git' },
                { name = 'nvim_lsp_signature_help' },
              },
            }
          '';
      }

      # Auto-formatting
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
                cs = { "csharpier" },
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

            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                        -- FormatDisable! will disable formatting just for this buffer
                        vim.b.disable_autoformat = true
                else
                        vim.g.disable_autoformat = true
                end
            end, {
                desc = "Disable autoformat-on-save",
                bang = true,
            })

            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, {
                desc = "Re-enable autoformat-on-save",
            })
          '';
      }

      # Highlight todo, notes, etc in comments
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("todo-comments").setup({
              signs = false
            })
          '';
      }

      # Collection of various small independent plugins/modules
      {
        plugin = mini-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
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

            -- Comment blocks of code
            local comment = require 'mini.comment'
            comment.setup {}

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

      # Hide enviroment variables
      {
        plugin = cloak-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require('cloak').setup({
              enabled = true,
              cloak_character = '*',
              highlight_group = 'Comment',
              try_all_patterns = true,
              cloak_telescope = true,
              patterns = {
                {
                  file_pattern = '.env*',
                  cloak_pattern = '=.+',
                },
              },
            })
          '';
      }

      # Edit the file system as if it was a buffer
      {
        plugin = oil-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("oil").setup({
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
              }
            })

            vim.keymap.set('n', '-', '<CMD>Oil<CR>', {desc= 'Open parent directory'})
          '';
      }

      # Harpoon
      {
        plugin = harpoon-nvim-github;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            local harpoon = require('harpoon')
            harpoon:setup({})

            -- basic telescope configuration
            local conf = require("telescope.config").values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(file_paths, item.value)
                end

                require("telescope.pickers").new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({
                        results = file_paths,
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                }):find()
            end

            --vim.keymap.set("n", "<C-E>", function() toggle_telescope(harpoon:list()) end,
            --    { desc = "Open harpoon window" })
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
          '';
      }

      {
        plugin = trouble-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end)
            vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end)
            vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end)
            vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end)
            vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end)
            vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end)
          '';
      }

      {
        plugin = undotree;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
          '';
      }

      # Allow direnv support
      direnv-vim
    ];
  };
}
