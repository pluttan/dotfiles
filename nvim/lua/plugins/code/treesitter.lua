return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			-- typst

            -- local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()
            -- parser_configs.typst = {
            --     install_info = {
            --         url = "https://github.com/SeniorMars/tree-sitter-typst",
            --         files = { "src/parser.c", "src/scanner.c" },
            --         branch = "main"
            --     },
            --     filetype = "typst",
            -- }

            local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
            parser_config.typst = {
                install_info = {
                    url = "https://github.com/TheOnlyMrCat/tree-sitter-typst",
                    files = { "src/parser.c", "src/scanner.c" },
                    generate_requires_npm = false,
                    requires_generate_from_grammar = false,
                },
                filetype = "typst",
            }
            vim.filetype.add({
                extension = {
                    typ = "typst",
                },
            })

            local treesitterConfig = require("nvim-treesitter.configs")
			treesitterConfig.setup({
				auto_install = true,
				highlight = {
					enable = true,
					disable = { "latex", "typst" },
				},
				indent = { enable = true },
			})
		end,
	},
	{
		"folke/twilight.nvim",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
}
