return {
	"niuiic/translate.nvim",
	dependencies = {
		"niuiic/core.nvim",
	},
	config = function()
		local translate = require("translate")

		local function trans_to_ru()
			translate.translate({
				get_command = function(input)
					return { "trans", "-b", "-e", "google", "-t", "ru", input }
				end,
				input = "selection",
				output = { "open_float" },
			})
		end

		local function trans_to_en()
			translate.translate({
				get_command = function(input)
					return { "trans", "-b", "-e", "google", "-t", "en", input }
				end,
				input = "input",
				output = { "open_float" },
			})
		end

		vim.keymap.set("v", "<leader>tr", trans_to_ru, { desc = "Translate to Russian" })
		vim.keymap.set("v", "<leader>te", trans_to_en, { desc = "Translate to English" })
	end,
}
