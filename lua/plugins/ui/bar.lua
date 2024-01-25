return {
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		config = function()
			local map = vim.keymap.set
			local opts = {}
			-- Move to previous/next
			map("n", "<M-,>", "<Cmd>BufferPrevious<CR>", opts)
			map("n", "<M-.>", "<Cmd>BufferNext<CR>", opts)
			-- Re-order to previous/nex--t
			map("n", "<M-<>", "<Cmd>BufferMovePrevious<CR>", opts)
			map("n", "<M->>", "<Cmd>BufferMoveNext<CR>", opts)
			-- Goto buffer in position...
			map("n", "<M-1>", "<Cmd>BufferGoto 1<CR>", opts)
			map("n", "<M-2>", "<Cmd>BufferGoto 2<CR>", opts)
			map("n", "<M-3>", "<Cmd>BufferGoto 3<CR>", opts)
			map("n", "<M-4>", "<Cmd>BufferGoto 4<CR>", opts)
			map("n", "<M-5>", "<Cmd>BufferGoto 5<CR>", opts)
			map("n", "<M-6>", "<Cmd>BufferGoto 6<CR>", opts)
			map("n", "<M-7>", "<Cmd>BufferGoto 7<CR>", opts)
			map("n", "<M-8>", "<Cmd>BufferGoto 8<CR>", opts)
			map("n", "<M-9>", "<Cmd>BufferGoto 9<CR>", opts)
			map("n", "<M-0>", "<Cmd>BufferLast<CR>", opts)
			-- Pin/unpin buffer
			map("n", "<M-P>", "<Cmd>BufferPin<CR>", opts)
			-- Close buffer
			map("n", "<M-c>", "<Cmd>BufferClose<CR>", opts)
			-- Magic buffer-picking mode
			map("n", "<M-i>", "<Cmd>BufferPick<CR>", opts)
			-- Sort automatically by...
			map("n", "<M-b>", "<Cmd>BufferOrderByBufferNumber<CR>", opts)
			map("n", "<M-d>", "<Cmd>BufferOrderByDirectory<CR>", opts)
			map("n", "<M-l>", "<Cmd>BufferOrderByLanguage<CR>", opts)
			map("n", "<M-w>", "<Cmd>BufferOrderByWindowNumber<CR>", opts)
			vim.g.barbar_auto_setup = false -- disable auto-setup
			vim.g.lightline = {
				enable = {
					statusline = 1,
					tabline = 0,
				},
			}
			require("barbar").setup({})
		end,
	},
}
