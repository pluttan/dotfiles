return {
   "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "3rd/image.nvim"
    },
    config = function()
      require("neo-tree").setup({
        popup_border_style = "rounded",
        window = {
          position = "left",
          width = 25
        },
        default_component_configs = {
          indent = {
            indent_size = 1,
          }
        }
      })
      vim.keymap.set('n','<M-x>', ':Neotree reveal left <CR>', {})
      vim.keymap.set('n','<M-c>', ':Neotree close <CR>', {})
    end
}
