return {
    {
        'Mofiqul/vscode.nvim',
        config = function()
            require('vscode').setup {}
            vim.cmd.colorscheme 'vscode'
        end,
    },

    { 'nvim-tree/nvim-web-devicons', opts = {} },
}
