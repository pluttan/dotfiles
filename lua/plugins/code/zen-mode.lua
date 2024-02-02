return {
    "folke/zen-mode.nvim",
    config = function()
        vim.keymap.set("n", "<M-z>", function()
            require("zen-mode").toggle({
                window = {
                    width = 0.85, -- width will be 85% of the editor width
                },
            })
        end, {})
    end,
}
