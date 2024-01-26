return {
  {
    "rcarriga/nvim-notify",
    config = function()
	  vim.cmd("set termguicolors")
	  require("notify").setup({
             background_colour = "#000000",
      })
      vim.notify = require("notify")
      vim.keymap.set("n", "<C-n>", require("telescope").extensions.notify.notify, {})
    end,
  },
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
}
