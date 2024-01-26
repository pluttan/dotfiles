return {
    {
        "akinsho/bufferline.nvim",
        requires = "nvim-tree/nvim-web-devicons",
        config = function()
            vim.opt.termguicolors = true
            require("bufferline").setup({
                options = {
                   mode = "buffers", -- set to "tabs" to only show tabpages instead
                    themable = true, 
                    close_command = "bdelete! %d", 
                    indicator = {
                        style = 'icon',
                    },
                    buffer_close_icon = '󰅖',
                    modified_icon = '●',
                    close_icon = '',
                    left_trunc_marker = '',
                    right_trunc_marker = '',
                    name_formatter = function(buf) -- buf contains:
                    end,
                    max_name_length = 18,
                    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
                    truncate_names = true, -- whether or not tab names should be truncated
                    tab_size = 18,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = false,
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "NeoTree",
                            text_align = "center",
                            separator = true
                        }
                    },
                    show_buffer_icons = true,
                    hover = {
                        enabled = true,
                        delay = 200,
                        reveal = { 'close' }
                    },

                }
            }
            )
        end,
    },
}
