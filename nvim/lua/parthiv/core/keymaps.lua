-- lua/config/keymaps.lua

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Keep cursor centered while scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")

-- Toggle diagnostics location list
vim.keymap.set("n", "<leader>q", function()
	local winnr = vim.fn.getloclist(0, { winid = 0 }).winid
	if winnr ~= 0 then
		vim.cmd("lclose")
	else
		vim.diagnostic.setloclist()
	end
end, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Escape shortcuts
vim.keymap.set({ "i", "v", "s", "o" }, "jk", "<esc>", { desc = "Escape to normal mode" })
vim.keymap.set("c", "jj", "<c-c>", { desc = "Escape command mode" })

-- File explorer (Oil)
vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
-- ── Smart Pane Switching (Neovim ↔ Tmux) ──────────────────────────────
local function tmux_move(direction)
	local win_before = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. direction)
	local win_after = vim.api.nvim_get_current_win()

	if win_before == win_after then
		local tmux_directions = { h = "-L", j = "-D", k = "-U", l = "-R" }
		-- Use vim.fn.system instead of os.execute (respects Neovim's environment)
		-- Guard: only run if we're actually inside tmux
		if vim.env.TMUX then
			vim.fn.system("tmux select-pane " .. tmux_directions[direction])
		end
	end
end

vim.keymap.set("n", "<C-h>", function()
	tmux_move("h")
end, { silent = true })
vim.keymap.set("n", "<C-j>", function()
	tmux_move("j")
end, { silent = true })
vim.keymap.set("n", "<C-k>", function()
	tmux_move("k")
end, { silent = true })
vim.keymap.set("n", "<C-l>", function()
	tmux_move("l")
end, { silent = true })
