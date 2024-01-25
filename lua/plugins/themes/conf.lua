return {
	"zaldih/themery.nvim",
	config = function()
		require("themery").setup({
			themes = {
				{
					name = "󰄛 Catppuccin",
					colorscheme = "catppuccin",
					before = [[
                        require("catppuccin").setup({
                            transparent_background = true,
                        })  
                    ]],
				},
				{
					name = "󰖔 Tokyo night",
					colorscheme = "tokyonight",
					before = [[
                        require("tokyonight").setup({
                            style = "night",
                            transparent = true,
                            styles = {
                                sidebars = "transparent", -- style for sidebars, see below
                                floats = "transparent", -- style for floating windows
                            }
                        })
                        require('lualine').setup {
                            options = {
                                theme = 'tokyonight'
                            }
                        }
                    ]]
				},
                {
					name = "󰖔󰼸 Tokyo night -- Storm",
					colorscheme = "tokyonight",
					before = [[
                        require("tokyonight").setup({
                            style = "storm",
                            transparent = true,
                            styles = {
                                sidebars = "transparent", -- style for sidebars, see below
                                floats = "transparent", -- style for floating windows
                            }
                        })
                        require('lualine').setup {
                            options = {
                                theme = 'tokyonight'
                            }
                        }
                    ]]
				},
                {
				    name = "󰖔 Tokyo night -- Moon",
					colorscheme = "tokyonight",
					before = [[
                        require("tokyonight").setup({
                            style = "moon",
                            transparent = true,
                            styles = {
                                sidebars = "transparent", -- style for sidebars, see below
                                floats = "transparent", -- style for floating windows
                            }
                        })
                        require('lualine').setup {
                            options = {
                                theme = 'tokyonight'
                            }
                        }
                    ]]
				},
                -- DAY Themes
                {
					name = "󰖔 Tokyo night -- Day",
					colorscheme = "tokyonight",
					before = [[
                        require("tokyonight").setup({
                            style = "day",
                            transparent = true,
                            styles = {
                                sidebars = "transparent", -- style for sidebars, see below
                                floats = "transparent", -- style for floating windows
                            }
                        })
                        require('lualine').setup {
                            options = {
                                theme = 'tokyonight'
                            }
                        }
                    ]]
				},
			}, -- Your list of installed colorschemes
			themeConfigFile = "~/.config/nvim/lua/plugins/themes/conf.lua", -- Described below
		})

        vim.keymap.set("n", '<M-t>', ':Themery<cr>', {})

-- Themery block
-- This block will be replaced by Themery.
require("catppuccin").setup({
transparent_background = true,
})


vim.cmd("colorscheme catppuccin")
vim.g.theme_id = 1
-- end themery block
	end,
}
