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
vim.g.maplocalleader = " "

-- Отключить встроенный treesitter highlighting
vim.treesitter.stop()

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

-- \y copies to system clipboard
vim.keymap.set('n', '\\y', function()
    local content = vim.fn.getreg('"')
    vim.fn.setreg('+', content)
    vim.schedule(function()
        vim.notify(content, vim.log.levels.INFO, { title = "Copied to system clipboard", timeout = 1000 })
    end)
end, { noremap = true, silent = true, desc = "Copy internal buffer to system clipboard" })

vim.keymap.set('v', '\\y', function()
    vim.cmd('normal! "+y')
end, { noremap = true, silent = true, desc = "Copy selection to system clipboard" })

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

-- Open terminal at bottom (full width)
vim.keymap.set('n', '\\t', function()
    vim.cmd('new')
    vim.cmd('terminal')
    vim.cmd('wincmd J')
    vim.cmd('resize 10')
    vim.cmd('startinsert')
end, { noremap = true, silent = true, desc = "Open terminal" })

-- Выход из терминала по Esc Esc или <leader>q
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })
vim.keymap.set('t', '<leader>q', '<C-\\><C-n>', { desc = "Exit terminal mode" })
vim.wo.number = true

vim.cmd("set scrolloff=999")
vim.opt.termguicolors = true

-- Quick exit with ` key
local function quick_exit()
    local modified = vim.bo.modified
    if not modified then
        local ok = pcall(vim.cmd, 'q')
        if not ok then
            local ok2 = pcall(vim.cmd, 'qall')
            if not ok2 then
                vim.cmd('qall!')
            end
        end
    else
        local ok = pcall(vim.cmd, 'wq')
        if not ok then
            local ok2 = pcall(vim.cmd, 'wqall')
            if not ok2 then
                vim.cmd('qall!')
            end
        end
    end
end

vim.keymap.set('n', '`', quick_exit, { desc = "Quick exit", silent = true })

  vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  vim.api.nvim_exec([[
    let &t_SI = "\e[5 q"  " Вертикальная линия для режима вставки
    let &t_EI = "\e[1 q"  " Блочный курсор для нормального режима
    let &t_SR = "\e[3 q"  " Подчеркивание для режима замены
    let &t_VE = "\e[1 q"  " Блочный курсор для визуального режима
  ]], false)
