-- ~/.config/nvim/init.lua
-- Compatibility shim for vim.tbl_flatten (deprecated in Nvim 0.10+, removed in 0.13)
if vim.fn.has("nvim-0.10") == 1 then
	vim.tbl_flatten = function(t)
		return vim.iter(t):flatten():totable()
	end
end
vim.loader.enable()

-- Set Leader Key FIRST
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Enable ui2 EARLY (before anything can print messages)
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = "cmd",
		cmd = { height = 0.5 },
		msg = { height = 0.5, timeout = 4000 },
		pager = { height = 0.5 },
	},
})

-- Load Core Modules
require("parthiv.core.options")
require("parthiv.core.keymaps")
require("parthiv.core.autocmds")
require("parthiv.core.ui")
require("parthiv.core.lsp")
require("parthiv.core.snippets").setup()

require("parthiv.lazy")
vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})
vim.diagnostic.config({
	float = { border = "rounded" },
})
