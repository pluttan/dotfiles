---@diagnostic disable: trailing-space
return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dash = require("alpha.themes.dashboard")

		dash.section.header.val = {
			[[                          powered by pluttan                   ]],
			[[                   vk.com/pluttan    github.com/pluttan        ]],
			[[                                                               ]],
			[[       ███▄    █  ▓█████   ▒█████    ██▒   █▓  ██▓  ███▄ ▄███▓ ]],
			[[       ██ ▀█   █  ▓█   ▀  ▒██▒  ██▒ ▓██░   █▒ ▓██▒ ▓██▒▀█▀ ██▒ ]],
			[[      ▓██  ▀█ ██▒ ▒███    ▒██░  ██▒  ▓██  █▒░ ▒██▒ ▓██    ▓██░ ]],
			[[      ▓██▒  ▐▌██▒ ▒▓█  ▄  ▒██   ██░   ▒██ █░░ ░██░ ▒██    ▒██  ]],
			[[      ▒██░   ▓██░ ░▒████▒ ░ ████▓▒░    ▒▀█░   ░██░ ▒██▒   ░██▒ ]],
			[[      ░ ▒░   ▒ ▒  ░░ ▒░ ░ ░ ▒░▒░▒░     ░ ▐░   ░▓   ░ ▒░   ░  ░ ]],
			[[      ░ ░░   ░ ▒░  ░ ░  ░   ░ ▒ ▒░     ░ ░░    ▒ ░ ░  ░      ░ ]],
			[[         ░   ░ ░     ░    ░ ░ ░ ▒        ░░    ▒ ░ ░      ░    ]],
			[[               ░     ░  ░     ░ ░         ░    ░          ░    ]],
			[[                                            ░                  ]],
		}

		dash.section.buttons.val = {
			dash.button("n", "      Neotree", ":Neotree reveal left <CR>"),
			dash.button("p", "     󰷎 Projects", ":ProjectMgr<CR>"),
			dash.button("f", "      New file", ":Telescope cmdline<CR>e "),
			dash.button("u", "      Themery", ":Themery<CR>"),
			dash.button("t", "      Telescope", ":lua require('telescope.builtin').find_files()<CR>"),
			dash.button("s", "      Speedtyper", ":Speedtyper<CR>"),
			dash.button("c", "      Open config", ":Neotree /Volumes/pr/.dotfiles/<CR>"),
			dash.button("q", "      Quit", ":qall<CR>"),
		}

		alpha.setup(dash.opts)
	end,
}
