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
			dash.button("n",  "      Neotree",   "<C-z>"),
			dash.button("p",   "     󰷎 Projects",  "<M-p> "),
			dash.button("f",         "      New file",  ":e "),
			dash.button("t",  "      Telescope", "<C-w>"),
			dash.button("s","      Speedtyper",":Speedtyper"),
			dash.button("c",  "      Open config",":e ~/.config/nvim<CR><C-z>"),
			dash.button("q",         "      Quit",      ":q<CR>"),
	        	
    }

		alpha.setup(dash.opts)
	end,
}
