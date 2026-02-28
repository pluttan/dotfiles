return {
	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = true,
		lazy = false,
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
				},
				exclude = {
					filetypes = { "help", "alpha", "dashboard", "Trouble", "lazy", "neo-tree" },
				},
				whitespace = {
					remove_blankline_trail = true,
				},
			})
		end,
	},
}
