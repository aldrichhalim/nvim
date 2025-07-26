-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- configs
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes:2'
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions:remove { 'c', 'r', 'o' }
  end,
})
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Setup lazy.nvim
require('lazy').setup {
  spec = {
    {
      'neovim/nvim-lspconfig',
      config = function()
        local lspconfig = require 'lspconfig'
        -- Enhanced on_attach function with key bindings
        local on_attach = function(_, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
          -- Key mappings
          local opts = { noremap = true, silent = true, buffer = bufnr }
          -- Navigation
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
          -- Documentation
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          -- Code actions
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
          -- Diagnostics
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
        end
        -- Enhanced capabilities
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        -- Diagnostic configuration
        vim.diagnostic.config {
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        }
        -- Language servers setup
        lspconfig.lua_ls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        }
        lspconfig.pyright.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
        lspconfig.ts_ls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
        lspconfig.jdtls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end,
    },

    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
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
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
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
          }, {
            { name = 'buffer' },
            { name = 'path' },
          }),
        }
      end,
    },

    {
      'mason-org/mason-lspconfig.nvim',
      opts = {},
      dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'neovim/nvim-lspconfig',
      },
    },

    {
      'nvim-treesitter/nvim-treesitter',
      branch = 'master',
      lazy = false,
      build = ':TSUpdate',
    },

    {
      'sainnhe/sonokai',
      lazy = false,
      priority = 1000,
      config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.sonokai_style = 'atlantis'
        vim.g.sonokai_better_performance = 1
        vim.g.sonokai_enable_italic = true
        vim.cmd.colorscheme 'sonokai'
      end,
    },

    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        theme = 'sonokai',
      },
    },

    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      end,
    },

    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = true,
      -- use opts = {} for passing setup options
      -- this is equivalent to setup({}) function
    },

    {
      'folke/todo-comments.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },

    {
      'kevinhwang91/nvim-ufo',
      dependencies = {
        'kevinhwang91/promise-async',
      },
      config = function()
        -- fold
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

        require('ufo').setup {
          provider_selector = function()
            return { 'treesitter', 'indent' }
          end,
        }
      end,
    },

    {
      'lewis6991/gitsigns.nvim',
      opts = {},
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'habamax' } },
  -- automatically check for plugin updates
  checker = { enabled = false },
}
