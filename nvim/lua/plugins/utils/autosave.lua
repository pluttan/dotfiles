return {
	"pluttan/autosave.nvim",
	config = function()
		require("autosave").setup({
			enabled = true,
			events = { "InsertLeave", "FocusLost", "TextChanged" },
			silent = true,
			debounce_delay = 150,
		})
	end,
}
