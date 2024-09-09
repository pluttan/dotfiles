return {
    'spywhere/detect-language.nvim',
    config = function ()
      require('detect-language').setup({
            disable = {
                new = true,
                no_extension = true
            }
        })
    end
}
