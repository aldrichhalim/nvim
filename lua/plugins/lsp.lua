local border = {
    { '┌', 'FloatBorder' }, -- Top-left corner
    { '─', 'FloatBorder' }, -- Top edge
    { '┐', 'FloatBorder' }, -- Top-right corner
    { '│', 'FloatBorder' }, -- Right edge
    { '┘', 'FloatBorder' }, -- Bottom-right corner
    { '─', 'FloatBorder' }, -- Bottom edge
    { '└', 'FloatBorder' }, -- Bottom-left corner
    { '│', 'FloatBorder' }, -- Left edge
}

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip',
            'onsails/lspkind.nvim',
        },
        lazy = false,
        config = function()
            -- override border
            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or border
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- LSP setup
            local lspconfig = require 'lspconfig'
            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        -- prevent undefined global vim
                        diagnostics = { globals = { 'vim' } },
                    },
                },
                capabilities = capabilities,
            }
            lspconfig.ts_ls.setup {
                capabilities = capabilities,
            }
            lspconfig.clangd.setup {
                capabilities = capabilities,
            }
            lspconfig.pylsp.setup {
                capabilities = capabilities,
            }
            lspconfig.jdtls.setup {
                capabilities = capabilities,
            }
            -- NOTE: add more LSP setup here

            -- luasnip setup
            local luasnip = require 'luasnip'
            local lspkind = require 'lspkind'

            -- nvim-cmp setup
            local cmp = require 'cmp'
            cmp.setup {
                formatting = {
                    format = lspkind.cmp_format {
                        mode = 'text_symbol',
                        maxwidth = {
                            menu = 50, -- leading text (labelDetails)
                            abbr = 50, -- actual suggestion item
                        },
                        ellipsis_char = '...',
                        show_labelDetails = true,
                    },
                },
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
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
                    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
                    -- C-b (back) C-f (forward) for snippet placeholder navigation.
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
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
                sources = cmp.config.sources {
                    { name = 'buffer' },
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                },
            }
        end,
    },

    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
            'williamboman/mason.nvim',
        },
        config = function()
            require('mason').setup()
            require('mason-lspconfig').setup {
                ensure_installed = { 'clangd', 'lua_ls', 'jdtls', 'pylsp', 'ts_ls' },
            }
        end,
    },

    {
        'nvimtools/none-ls.nvim',
        config = function()
            local null_ls = require 'null-ls'

            null_ls.setup {
                sources = {
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.clang_format,
                },
            }

            vim.keymap.set('n', '<space>f', vim.lsp.buf.format, { desc = 'Format file' })
        end,
    },

    {
        'kevinhwang91/nvim-ufo',
        dependencies = {
            'kevinhwang91/promise-async',
        },
        init = function()
            vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
            vim.o.foldlevelstart = 99
            vim.o.foldnestmax = 1 -- Maximum nesting for fold
            vim.o.foldenable = true

            -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

            require('ufo').setup {
                provider_selector = function(bufnr, filetype, buftype)
                    return { 'treesitter', 'indent' }
                end,
            }
        end,
    },
}
