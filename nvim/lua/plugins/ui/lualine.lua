return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local custom_nightfly = require'lualine.themes.nightfly'
    custom_nightfly.normal.c.bg = '#11223300'

    local function get_short_cwd() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end
    local M = {}
    M.sections = {lualine_a = {get_short_cwd}}
    M.filetypes = {'neo-tree'}
    require('lualine').setup(
      {
        extensions = {M},
        options = {
          theme = custom_nightfly
        }
      }
    )
  end
}
