return {
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = true,
		build = ":TSUpdate",
		config = function()
			vim.filetype.add({
				extension = {
					typ = "typst",
				},
			})
		end,
	},
	{
		"folke/twilight.nvim",
		enabled = true,
		opts = {},
	},
}
