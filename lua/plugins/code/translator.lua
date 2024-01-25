return {
	"niuiic/translate.nvim",
	dependencies = {
		"niuiic/core.nvim",
	},
	config = function()
		require("translate").setup({
			output = {
				float = {
					max_width = 40,
					max_height = 5,
					close_on_cursor_move = true,
					enter_key = "T",
				},
			},
			translate = {
				{
					cmd = "TransToRu",
					command = "trans",
					args = function(trans_source)
						return {
							"-b",
							"-e",
							"google",
							"-t",
							"ru",
							trans_source,
						}
					end,
					input = "selection",
					output = { "float_win" },
				},
				{
					cmd = "TransToEN",
					command = "trans",
					args = function(trans_source)
						return {
							"-b",
							"-e",
							"google",
							"-t",
							"en",
							trans_source,
						}
					end,
					input = "input",
					output = { "float_win" },
				},
			},
		})
		vim.keymap.set("v", "<leader>tr", ":TransToRu")
		vim.keymap.set("v", "<leader>te", ":TransToEN")
	end,
}
