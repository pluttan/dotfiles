return {
	"Pocco81/auto-save.nvim",
	config = function()
		 require("auto-save").setup {
			condition = function(buf)
			    return (vim.fn.getbufvar(buf, "&modifiable") == 1)
			end,
        }
	end,
    write_all_buffers = true,
    debounce_delay = 1
}
