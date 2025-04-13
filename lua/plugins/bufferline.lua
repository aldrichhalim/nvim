return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = 'vscode',
        },
        sections = {
            lualine_c = {
                {
                    'filename',
                    file_status = true,
                    path = 1,
                },
            },
        },
    },
}
