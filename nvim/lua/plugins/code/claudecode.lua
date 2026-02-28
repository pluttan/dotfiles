return {
	"coder/claudecode.nvim",
	lazy = false,
	dependencies = {
		"folke/snacks.nvim",
	},
	opts = {
		terminal = {
			split_side = "bottom",
			split_height_percentage = 0.30,
			snacks_win_opts = {
				wo = {
					winblend = 0,
					winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal",
				},
			},
		},
		diff_opts = {
			auto_close_on_accept = true,
			vertical_split = false,
			show_diff = false,
		},
	},
	keys = {
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	},
}
