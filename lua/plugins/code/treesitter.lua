return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local treesitterConfig = require("nvim-treesitter.configs")
			treesitterConfig.setup({
				auto_install = true,
				highlight = {
					enable = true,
					disable = { "latex" },
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
