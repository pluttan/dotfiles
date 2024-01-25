local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugin_path = "~/.config/nvim/"
vim.cmd(string.format([[autocmd BufRead,BufNewFile %s/**/*.lua source <afile>]], plugin_path))

require("lazy").setup({
    ui = {
		size = { width = 0.9, height = 0.4 },
		border = "rounded",
	},
    { import = "plugins" },
	{ import = "plugins.ui" },
	{ import = "plugins.code" },
	{ import = "plugins.proj" },
	{ import = "plugins.themes" },
	{ import = "plugins.training" },
    change_detection = {
        enabled = true,
        notify = false
    },
})
