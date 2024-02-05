return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local colors = {
			color3 = "#2c304300",
			color6 = "#a1aab8",
			color7 = "#82aaff",
			color8 = "#ae81ff",
			color0 = "#092236",
			color1 = "#ff5874",
			color2 = "#c3ccdc",
		}

		local custom_nightfly = {
			replace = {
				a = { fg = colors.color0, bg = colors.color1, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
			inactive = {
				a = { fg = colors.color6, bg = colors.color3, gui = "bold" },
				b = { fg = colors.color6, bg = colors.color3 },
				c = { fg = colors.color6, bg = colors.color3 },
			},
			normal = {
				a = { fg = colors.color0, bg = colors.color7, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
				c = { fg = colors.color2, bg = colors.color3 },
			},
			visual = {
				a = { fg = colors.color0, bg = colors.color8, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
			insert = {
				a = { fg = colors.color0, bg = colors.color2, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
		}
		-- custom_nightfly.normal.c.bg = "#11223300"
		-- custom_nightfly.inactive.a.bg = "#11223300"
		-- custom_nightfly.inactive.b.bg = "#11223300"
		-- custom_nightfly.inactive.c.bg = "#11223300"

		local function get_short_cwd()
			return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
		end
		local M = {}
		M.sections = { lualine_a = { get_short_cwd } }
		M.filetypes = { "neo-tree" }
		require("lualine").setup({
			extensions = { M },
			options = {
				theme = custom_nightfly,
				component_separators = "|",
				section_separators = { left = "", right = "" },
			},
		})
	end,
}
