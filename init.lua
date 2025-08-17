---@diagnostic disable: undefined-global
-- Streamlined Neovim Config for Go Development

-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = false

-- Basic Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Basic Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Install lazy.nvim plugin manager if not already installed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Configuration
require('lazy').setup({
  -- Theme
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- GitHub Copilot
  { 'github/copilot.vim', lazy = false },

  -- Copilot Chat (if available)
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      { 'github/copilot.vim' },
      { 'nvim-lua/plenary.nvim' },
    },
    opts = {
      debug = false,
      model = 'gpt-5',
      -- model = 'claude-sonnet-4',
    },
    keys = {
      { '<leader>cc', '<cmd>CopilotChatToggle<cr>', desc = 'Toggle Copilot Chat' },
      { '<leader>ce', '<cmd>CopilotChatExplain<cr>', desc = 'Explain code' },
      { '<leader>ct', '<cmd>CopilotChatTests<cr>', desc = 'Generate tests' },
      { '<leader>cr', '<cmd>CopilotChatReview<cr>', desc = 'Review code' },
      { '<leader>cf', '<cmd>CopilotChatFix<cr>', desc = 'Fix code' },
      { '<leader>co', '<cmd>CopilotChatOptimize<cr>', desc = 'Optimize code' },
      { '<leader>cd', '<cmd>CopilotChatDocs<cr>', desc = 'Document code' },
    },
  },

  -- File Explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        window = {
          position = 'left',
          width = 30,
        },
        filesystem = {
          follow_current_file = true,
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      }
      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer' })
    end,
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = vim.g.have_nerd_font,
        theme = 'tokyonight',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }

      pcall(telescope.load_extension, 'fzf')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find text' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Mason setup for installing language servers
      require('mason').setup()

      -- LSP servers to install
      local servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
              usePlaceholders = true,
              semanticTokens = true,
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
                url = 'https://www.schemastore.org/api/json/catalog.json',
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              check = {
                command = 'clippy',
              },
              diagnostics = {
                enable = true,
              },
            },
          },
        },
      }

      -- Tools to install
      local tools = {
        'gopls', -- Go language server
        'gofumpt', -- Go formatter
        'goimports', -- Go imports manager
        'golangci-lint', -- Go linter
        'delve', -- Go debugger
        'yaml-language-server',
        'rust-analyzer', -- Rust language server
      }

      require('mason-tool-installer').setup { ensure_installed = tools }

      -- Setup LSP keymaps when a language server attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- LSP actions
          map('gd', vim.lsp.buf.definition, 'Goto Definition')
          map('gr', vim.lsp.buf.references, 'Goto References')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('gI', vim.lsp.buf.implementation, 'Goto Implementation')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

          -- Toggle inlay hints if supported
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
          end
        end,
      })

      -- Configure LSP clients
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if has_cmp then
        capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
      end

      -- Setup language servers
      local lspconfig = require 'lspconfig'
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            lspconfig[server_name].setup {
              capabilities = capabilities,
              settings = servers[server_name] and servers[server_name].settings,
              filetypes = servers[server_name] and servers[server_name].filetypes,
            }
          end,
        },
      }
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }),
      }
    end,
  },

  -- Treesitter for syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'go', 'gomod', 'gosum', 'gowork', 'yaml', 'lua', 'vim', 'vimdoc', 'query', 'rust' },
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      }
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        go = { 'gofumpt', 'goimports' },
        yaml = { 'yamlfmt' },
        lua = { 'stylua' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
    },
  },

  -- Go specific plugins
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup {
        lsp_cfg = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        },
        lsp_inlay_hints = { enable = true },
        treesitter = false,
        dap_debug = true,
        gofmt = 'gofumpt',
        lsp_document_formatting = false, -- use conform.nvim instead
        lsp_keymaps = false, -- we defined our own above
      }

      -- Go-specific keymaps
      -- vim.keymap.set('n', '<leader>gt', '<cmd>GoTest<CR>', { desc = 'Go Test' })
      vim.keymap.set('n', '<leader>gt', '<cmd>UnifiedTest<CR>', { desc = 'Unified Test' })
      vim.keymap.set('n', '<leader>gi', '<cmd>GoImport<CR>', { desc = 'Go Import' })
      vim.keymap.set('n', '<leader>ga', '<cmd>GoAlt<CR>', { desc = 'Go to alternate file' })
    end,
    ft = { 'go', 'gomod' },
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, key, action, desc)
          vim.keymap.set(mode, key, action, { buffer = bufnr, desc = desc })
        end

        map('n', '<leader>gh', gs.preview_hunk, 'Preview Git hunk')
        map('n', '<leader>gb', function()
          gs.blame_line { full = true }
        end, 'Git blame line')
        map('n', '<leader>gd', gs.diffthis, 'Git diff')
      end,
    },

    -- Unified test/run/build interface
    {
      'axkirillov/unified.nvim',
      config = function()
        require('unified').setup {
          -- Go configuration
          go = {
            test = {
              command = 'go test',
              args = { '-v' },
              file_pattern = '_test.go',
            },
            run = {
              command = 'go run',
              args = { '.' },
            },
            build = {
              command = 'go build',
              args = { '.' },
            },
          },
          rust = {
            test = {
              command = 'cargo test',
              args = { '--' },
            },
            run = {
              command = 'cargo run',
              args = {},
            },
            build = {
              command = 'cargo build',
              args = {},
            },
          },
        }

        -- Add keymaps for unified commands
        vim.keymap.set('n', '<leader>ut', '<cmd>UnifiedTest<CR>', { desc = 'Unified Test' })
        vim.keymap.set('n', '<leader>ur', '<cmd>UnifiedRun<CR>', { desc = 'Unified Run' })
        vim.keymap.set('n', '<leader>ub', '<cmd>UnifiedBuild<CR>', { desc = 'Unified Build' })
        vim.keymap.set('n', '<leader>uc', '<cmd>UnifiedClean<CR>', { desc = 'Unified Clean' })
      end,
    },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤',
    },
  },
})

-- Additional keymaps
vim.keymap.set('n', '<leader>tt', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file tree' })

-- vim: ts=2 sts=2 sw=2 et
