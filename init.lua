-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })
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

-- Optimizations
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1

-- Core settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes:2'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.conceallevel = 2

-- Disable auto comment continuation
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

-- Folding setup
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Enable LSP
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})
vim.lsp.enable({ 'jdtls', 'pyright', 'ts_ls', 'lua_ls' })

-- Setup lazy.nvim
require('lazy').setup({
  spec = {
    {
      'echasnovski/mini.snippets',
      version = '*',
      event = 'InsertEnter',
      opts = {},
    },

    {
      'echasnovski/mini.icons',
      version = '*',
      event = 'InsertEnter',
      opts = {},
    },

    {
      'echasnovski/mini.completion',
      version = '*',
      event = 'InsertEnter',
      opts = {},
    },

    {
      'mason-org/mason.nvim',
      cmd = 'Mason',
      build = ':MasonUpdate',
      opts = {
        ui = {
          border = 'rounded',
        },
      },
    },

    {
      'mason-org/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'mason-org/mason.nvim',
        'neovim/nvim-lspconfig',
      },
      opts = {
        ensure_installed = { 'lua_ls', 'pyright', 'ts_ls', 'jdtls' },
        automatic_installation = true,
      },
    },

    {
      'nvim-treesitter/nvim-treesitter',
      event = { 'BufReadPost', 'BufNewFile' },
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter.configs').setup({
          ensure_installed = {
            'lua',
            'python',
            'javascript',
            'typescript',
            'java',
            'markdown',
            'json',
          },
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        })

        -- For gotmpl, yaml, and helm files
        vim.filetype.add({
          extension = {
            gotmpl = 'gotmpl',
          },
          pattern = {
            ['.*/templates/.*%.tpl'] = 'helm',
            ['.*/templates/.*%.ya?ml'] = 'helm',
            ['helmfile.*%.ya?ml'] = 'helm',
          },
        })
      end,
    },

    {
      'lukas-reineke/indent-blankline.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      main = 'ibl',
      opts = {
        indent = {
          char = '│',
          tab_char = '│',
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
        },
        exclude = {
          filetypes = {
            'help',
            'alpha',
            'dashboard',
            'neo-tree',
            'Trouble',
            'trouble',
            'lazy',
            'mason',
            'notify',
            'toggleterm',
            'lazyterm',
          },
        },
      },
    },

    {
      'sainnhe/sonokai',
      lazy = false,
      priority = 1000,
      config = function()
        vim.g.sonokai_style = 'atlantis'
        vim.g.sonokai_better_performance = 1
        vim.g.sonokai_enable_italic = true
        vim.cmd.colorscheme('sonokai')
      end,
    },

    {
      'nvim-lualine/lualine.nvim',
      event = 'VeryLazy',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          theme = 'sonokai',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1, -- Show relative path
            },
          },
        },
      },
    },

    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      cmd = 'Telescope',
      keys = {
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live grep' },
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' },
        { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Recent files' },
        {
          '<leader>fc',
          '<cmd>Telescope grep_string<cr>',
          desc = 'Find word under cursor',
        },
      },
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
      },
      config = function()
        require('telescope').setup({
          defaults = {
            mappings = {
              i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
              },
            },
            file_ignore_patterns = { 'node_modules', '.git' },
          },
        })
      end,
    },

    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = true,
    },

    {
      'folke/todo-comments.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      dependencies = { 'nvim-lua/plenary.nvim' },
      keys = {
        {
          ']t',
          function()
            require('todo-comments').jump_next()
          end,
          desc = 'Next todo comment',
        },
        {
          '[t',
          function()
            require('todo-comments').jump_prev()
          end,
          desc = 'Previous todo comment',
        },
        { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'Find todos' },
      },
      opts = {},
    },

    {
      'kevinhwang91/nvim-ufo',
      event = { 'BufReadPost', 'BufNewFile' },
      dependencies = {
        'kevinhwang91/promise-async',
      },
      keys = {
        {
          'zR',
          function()
            require('ufo').openAllFolds()
          end,
          desc = 'Open all folds',
        },
        {
          'zM',
          function()
            require('ufo').closeAllFolds()
          end,
          desc = 'Close all folds',
        },
        {
          'zr',
          function()
            require('ufo').openFoldsExceptKinds()
          end,
          desc = 'Fold less',
        },
        {
          'zm',
          function()
            require('ufo').closeFoldsWith()
          end,
          desc = 'Fold more',
        },
      },
      config = function()
        require('ufo').setup({
          provider_selector = function()
            return { 'treesitter', 'indent' }
          end,
        })
      end,
    },

    {
      'lewis6991/gitsigns.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      opts = {
        signs = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        current_line_blame = false,
        preview_config = {
          border = 'rounded',
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']h', gs.next_hunk, { desc = 'Next git hunk' })
          map('n', '[h', gs.prev_hunk, { desc = 'Previous git hunk' })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
          map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
          map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
          map('n', '<leader>hb', function()
            gs.blame_line({ full = true })
          end, { desc = 'Blame line' })
          map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })

          -- Text object
          map(
            { 'o', 'x' },
            'ih',
            ':<C-U>Gitsigns select_hunk<CR>',
            { desc = 'Select git hunk' }
          )
        end,
      },
    },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  install = { colorscheme = { 'sonokai' } },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
