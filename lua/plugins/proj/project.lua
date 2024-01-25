return {
    'charludo/projectmgr.nvim',
    lazy = false,
    config = function()
        vim.api.nvim_set_keymap("n", "<M-p>", ":ProjectMgr<CR>", {});
    end
}
