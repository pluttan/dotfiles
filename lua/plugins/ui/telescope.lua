return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            vim.keymap.set("n", "<C-w>", require("telescope.builtin").find_files, {})
        end,
    },
    {
        "jonarrien/telescope-cmdline.nvim",
        config = function()
            require("telescope").load_extension("cmdline")
            vim.keymap.set("n", ":", "<cmd>Telescope cmdline<cr>", {})
        end,
    },
    {
        "debugloop/telescope-undo.nvim",
        config = function()
            require("telescope").setup({
                opts = {
                    extensions = {
                        undo = {
                            use_delta = true,
                        },
                    },
                },
            })
            require("telescope").load_extension("undo")
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
                defaults = {
                    mappings = {
                        n = {
                            [":q<cr>"] = require("telescope.actions").close,
                        },
                    },
                },
            })
            require("telescope").load_extension("ui-select")
        end,
    },
}
