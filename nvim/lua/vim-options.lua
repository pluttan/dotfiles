vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set cmdheight=0")
vim.cmd("set breakindent")
vim.cmd('set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20')
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

-- Spell check
vim.opt.spell = true
vim.opt.spelllang = "ru"

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')
vim.api.nvim_set_keymap('v', '<D-c>', '"+y', { noremap = true, silent = true })

function SWITCH_LANGUAGE()
    local current_map = vim.o.keymap
    if current_map == "russian-jcukenwin" then
        vim.cmd("set keymap=")
    else
        vim.cmd("set keymap=russian-jcukenwin")
    end
end

-- Создаем горячую клавишу для переключения языка
vim.api.nvim_set_keymap('n', '<C-Space>', ':lua SWITCH_LANGUAGE()<CR>', {noremap = true, silent = true})

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true

vim.cmd("set scrolloff=999")
vim.opt.termguicolors = true
  vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  vim.api.nvim_exec([[
    let &t_SI = "\e[5 q"  " Вертикальная линия для режима вставки
    let &t_EI = "\e[1 q"  " Блочный курсор для нормального режима
    let &t_SR = "\e[3 q"  " Подчеркивание для режима замены
    let &t_VE = "\e[1 q"  " Блочный курсор для визуального режима
  ]], false)
