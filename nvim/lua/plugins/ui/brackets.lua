return {
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = false,
		opts = {},
		main = "ibl",
		dependencies = {
			"HiPhish/rainbow-delimiters.nvim",
		},
		config = function()
			local highlight = {
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			vim.g.rainbow_delimiters = { highlight = highlight }
			require("ibl").setup({
				scope = { highlight = highlight },
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

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},
}
