return {
	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		config = function()
			require("todo-comments").setup()

			vim.keymap.set("n", "]t", function()
				require("todo-comments").jump_next()
			end, { desc = "Next todo comment" })

			vim.keymap.set("n", "[t", function()
				require("todo-comments").jump_prev()
			end, { desc = "Previous todo comment" })

			vim.keymap.set("n", "<leader>td", ":TodoQuickFix<CR>", {})
			vim.keymap.set("n", "<leader>tdl", ":TodoLocList<CR>", {})
			vim.keymap.set("n", "<leader>tdt", ":TodoTelescope<CR>", {})
		end,
		-- FIX, TODO, HACK, WARN, PERF, NOTE, TEST
	},
}
