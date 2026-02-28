return {
	"pluttan/im-autoswitch.nvim",
	config = function()
		require("im-autoswitch").setup({
			im_select_command = "/usr/local/bin/im-select",
			default_im = "com.apple.keylayout.US",
			set_previous_im_on_enter = true,
			debug = false,
		})
	end,
}
