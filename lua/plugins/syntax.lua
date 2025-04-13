return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        local configs = require 'nvim-treesitter.configs'

        configs.setup {
            ensure_installed = {
                'c',
                'cpp',
                'css',
                'json',
                'lua',
                'python',
                'vim',
                'vimdoc',
                'javascript',
                'typescript',
                'html',
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        }
    end,
}
