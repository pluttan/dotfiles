vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set cmdheight=0")
vim.cmd("set breakindent")
--
-- vim.cmd("nnoremap <Left>  :echoe 'Use h'<CR>")
-- vim.cmd("nnoremap <Right> :echoe 'Use l'<CR>")
-- vim.cmd("nnoremap <Up>    :echoe 'Use k'<CR>")
-- vim.cmd("nnoremap <Down>  :echoe 'Use j'<CR>")
-- -- vim.cmd("inoremap <Left>  <ESC>:echoe 'Use h'<CR>")
-- vim.cmd("inoremap <Right> <ESC>:echoe 'Use l'<CR>")
-- vim.cmd("inoremap <Up>    <ESC>:echoe 'Use k'<CR>")
-- vim.cmd("inoremap <Down>  <ESC>:echoe 'Use j'<CR>")
--
vim.g.mapleader = " "

-- Opt settings
vim.opt.mouse = 'a'
vim.opt.encoding = 'utf-8'
vim.opt.swapfile = false
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.o.ttimeoutlen = 100

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')
vim.keymap.set('n', '<d-c>', '"+y')

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true
