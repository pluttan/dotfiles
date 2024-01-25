return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jonarrien/telescope-cmdline.nvim"
    },
    config = function()
      require("telescope").load_extension('cmdline')
      local telescopeBuiltin = require("telescope.builtin")
      vim.keymap.set("n", "<C-w>", telescopeBuiltin.find_files, {})
      vim.keymap.set("n", ':', '<cmd>Telescope cmdline<cr>', {})
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
        defaults = {
          mappings = {
            n = {
              [":q<cr>"] = require("telescope.actions").close,
            },
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
