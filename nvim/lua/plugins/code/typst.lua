return {
    {
        "chomosuke/typst-preview.nvim",
        config = function ()
            require 'typst-preview'.setup {
                invert_colors = 'auto',
            }
        end
    },
    {
        'kaarmu/typst.vim',
        ft = 'typ',
        lazy=false,
    }
}
