return {
    {
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            vim.keymap.set("n", '<M-g>', ':LazyGit<CR>', {})
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function ()
            require('gitsigns').setup()
            vim.cmd(":Gitsigns toggle_current_line_blame")
        end
    },
}
