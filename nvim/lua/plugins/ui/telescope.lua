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
                    winblend = 0,
                    mappings = {
                        n = {
                            [":q<cr>"] = require("telescope.actions").close,
                        },
                    },
                },
            })
            require("telescope").load_extension("ui-select")

            -- Transparent background for telescope
            vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "NONE" })
        end,
    },
}
