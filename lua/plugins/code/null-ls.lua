return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.code_actions.eslint
      },
    })

    vim.keymap.set("n", "<M-f>", vim.lsp.buf.format, {})
  end,
}
