return {
	"zaldih/themery.nvim",
	config = function()
		require("themery").setup({
			themes = {
				{
					name = "󰄛 Catppuccin -- Mocha",
					colorscheme = "catppuccin-mocha",
					before = [[
                        require("catppuccin").setup({
                            transparent_background = true,
                        })  
                    ]],
				},
                {
					name = "󰄛 Catppuccin -- Macchiato",
					colorscheme = "catppuccin-macchiato",
					before = [[
                        require("catppuccin").setup({
                            transparent_background = true,
                        })  
                    ]],
				},
                {
					name = "󰄛 Catppuccin -- Frappe",
					colorscheme = "catppuccin-frappe",
					before = [[
                        require("catppuccin").setup({
                            transparent_background = true,
                        })  
                    ]],
				},
                {
                	name = "󰭟 Dracula",
					colorscheme = "dracula",
					before = [[
                       require("dracula").setup({
                            transparent_bg = true,
                       })
                    ]],
                },
                {
                    name = " Aura -- Dark",
					colorscheme = "aura-dark",
                    before = [[
                        vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
                    ]],
                },
                {
                    name = " Aura -- Dark Soft Text",
					colorscheme = "aura-dark-soft-text",
					before = [[
                       require("aura").setup({
                            transparent_bg = true,
                       })
                    ]],
                },
                {
                    name = " Aura -- Soft Dark",
					colorscheme = "aura-soft-dark",
					before = [[
                       require("aura").setup({
                            transparent_bg = true,
                       })
                    ]],
                },
                {
                    name = " Aura -- Soft Dark Soft Text",
					colorscheme = "aura-soft-dark-soft-text",
					before = [[
                       require("aura").setup({
                            transparent_bg = true,
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
                    ]]
				},
                {
					name = "󰖔 Tokyo night -- Storm",
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
                    ]]
				},
                {
				    name = "󰖔 Tokyo night -- Moon",
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
                    ]]
				},
                -- DAY Themes
                {
					name = " 󰖔 Tokyo night -- Day",
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
                    ]]
				},
                {
					name = " 󰄛 Catppuccin -- Latte",
					colorscheme = "catppuccin-latte",
					before = [[
                        require("catppuccin").setup({
                            transparent_background = true,
                        })  
                    ]],
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


vim.cmd("colorscheme catppuccin-mocha")
vim.g.theme_id = 1
-- end themery block
	end,
}
