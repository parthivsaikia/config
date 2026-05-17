-- lua/config/options.lua

vim.o.winbar = ""
vim.o.showtabline = 0

vim.o.number = true
vim.o.relativenumber = true

vim.o.mouse = "a"
vim.o.showmode = false

-- Clipboard
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

-- Invisible characters
vim.o.list = true
vim.opt.listchars = {
	tab = "  ",
	trail = " ",
	nbsp = "␣",
	extends = "›",
	precedes = "‹",
}

vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10

vim.o.confirm = true
vim.o.hlsearch = false

vim.o.termguicolors = true

vim.opt.cmdheight = 0
vim.opt.laststatus = 3

-- Completion UI
vim.o.pumblend = 10
vim.o.pumheight = 10
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- Disable built-in plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_gzip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1

-- Clean startup
vim.opt.shortmess:append("I")
