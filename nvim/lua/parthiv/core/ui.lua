local border = "rounded"

vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
	config = config or {}
	config.border = border
	return vim.lsp.handlers.hover(_, result, ctx, config)
end

vim.lsp.handlers["textDocument/signatureHelp"] = function(_, result, ctx, config)
	config = config or {}
	config.border = border
	return vim.lsp.handlers.signature_help(_, result, ctx, config)
end
-- Border on native completion popup
vim.o.pumborder = "rounded"
-- ==========================================
-- STATUSLINE CORE HELPERS
-- ==========================================
local function get_mode_str()
	local mode_map = { n = "N", i = "I", v = "V", V = "V", ["\22"] = "V", c = "C", R = "R", t = "T" }
	local m = vim.api.nvim_get_mode().mode
	return mode_map[m] or mode_map[m:sub(1, 1)] or "N"
end

local function get_diags()
	local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local str = ""
	if err > 0 then
		str = str .. "%#StErr#  " .. err
	end
	if warn > 0 then
		str = str .. "%#StWarn#  " .. warn
	end
	return str .. " "
end

local function get_git()
	local branch = vim.b.gitsigns_head or ""
	if branch == "" then
		return ""
	end
	return string.format("%%#StGit#  %s ", branch)
end

local function get_file()
	local file = vim.fn.expand("%:t")
	return file == "" and "[No Name]" or file
end
-- Inside your MistyStatusline function in ui.lua
local function get_git_info()
	-- Pull the branch name from gitsigns buffer variable
	local branch = vim.b.gitsigns_head or ""
	if branch == "" then
		return ""
	end

	-- Pull diff stats from gitsigns
	local dict = vim.b.gitsigns_status_dict
	local added = dict and dict.added or 0
	local changed = dict and dict.changed or 0
	local removed = dict and dict.removed or 0

	local git_str = string.format(" %%#StGit# %s", branch)

	-- Only show stats if they are greater than 0 to keep it Noir
	if added > 0 then
		git_str = git_str .. " +" .. added
	end
	if changed > 0 then
		git_str = git_str .. " ~" .. changed
	end
	if removed > 0 then
		git_str = git_str .. " -" .. removed
	end

	return git_str .. " "
end

-- Then include it in your return string:
-- return left .. get_git_info() .. "%#StBg#%=" .. diag_str .. right
local mode_colors = {
	N = { mode = "StMode", sep = "StModeSep", loc = "StLoc", locsep = "StLocSep" },
	I = { mode = "StModeInsert", sep = "StModeSepInsert", loc = "StLocInsert", locsep = "StLocSepInsert" },
	V = { mode = "StModeVisual", sep = "StModeSepVisual", loc = "StLocVisual", locsep = "StLocSepVisual" },
	C = { mode = "StModeCmd", sep = "StModeSepCmd", loc = "StLocCmd", locsep = "StLocSepCmd" },
	R = { mode = "StModeReplace", sep = "StModeSepReplace", loc = "StLocReplace", locsep = "StLocSepReplace" },
}

function _G.MistyStatusline()
	-- Expanded map slightly to handle Terminal ('t')
	local mode_map = {
		n = "N",
		i = "I",
		v = "V",
		V = "V",
		["\22"] = "V",
		c = "C",
		R = "R",
		t = "I",
	}

	local current_mode = vim.api.nvim_get_mode().mode
	-- Fallback chain: Exact mode -> First letter of mode -> Default "N"
	-- This ensures "ic" (Insert Completion) safely falls back to "i" -> "I"
	local mode = mode_map[current_mode] or mode_map[current_mode:sub(1, 1)] or "N"
	local colors = mode_colors[mode] or mode_colors["N"]

	local file = vim.fn.expand("%:t")
	if file == "" then
		file = "[No Name]"
	end
	local path = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":~:."))

	local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	local hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

	local diag_str = ""
	if err > 0 then
		diag_str = diag_str .. "%#StErr#  " .. err
	end
	if warn > 0 then
		diag_str = diag_str .. "%#StWarn#  " .. warn
	end
	if info > 0 then
		diag_str = diag_str .. "%#StInfo#  " .. info
	end
	if hint > 0 then
		diag_str = diag_str .. "%#StHint# 󰌵 " .. hint
	end
	if diag_str ~= "" then
		diag_str = diag_str .. " "
	end

	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local lsp = next(clients) and clients[1].name or ""
	local ft = vim.bo.filetype

	local icon = ""
	local has_icons, mini_icons = pcall(require, "mini.icons")
	if has_icons then
		icon = mini_icons.get("filetype", ft) or ""
	end

	local sep = ""

	local left = string.format(
		"%%#%s# %s %%#%s#%s%%#StFile# %s %%#StFileSep#%s%%#StPath# %s %%#StPathSep#%s",
		colors.mode,
		mode,
		colors.sep,
		sep,
		file,
		sep,
		path,
		sep
	)

	local right = ""
	if lsp ~= "" then
		right = right .. string.format("%%#StLspSep#%s%%#StLsp# %s %%#StLspSep2#%s", sep, lsp, sep)
	else
		right = right .. string.format("%%#StBgToFg#%s", sep)
	end
	if ft ~= "" then
		right = right .. string.format("%%#StType# %s %s ", icon, ft)
	end

	local gap = string.format("%%#StTypeSep#%s %%#%s#%s", sep, colors.locsep, sep)
	local loc = string.format("%%#%s# ≡ %%p%%%% / %%L ", colors.loc)

	return left .. get_git_info() .. "%#StBg#%=" .. diag_str .. right .. gap .. loc
end

vim.opt.statusline = "%!v:lua.MistyStatusline()"
vim.opt.ruler = false

-- Add this to instantly redraw the statusline when mode changes
vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*:*",
	callback = function()
		vim.cmd("redrawstatus")
	end,
})

vim.opt.statusline = "%!v:lua.MistyStatusline()"
vim.opt.ruler = false

-- Define highlight groups (you can customize these links to match your colorscheme)
vim.api.nvim_set_hl(0, "DashHeader", { link = "Keyword", default = true })
vim.api.nvim_set_hl(0, "DashKey", { link = "Statement", default = true })
vim.api.nvim_set_hl(0, "DashIcon", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "DashDesc", { link = "String", default = true })
vim.api.nvim_set_hl(0, "DashFooter", { link = "Comment", default = true })

local function open_dashboard(event)
	-- Don't open if we are opening a specific file or in insert mode
	if vim.fn.argc() ~= 0 or vim.o.insertmode then
		return
	end

	local current_buf = vim.api.nvim_get_current_buf()

	-- On resize, ONLY re-render if we are already looking at the dashboard
	if event == "VimResized" and not vim.b[current_buf].is_dashboard then
		return
	end

	local function dwidth(s)
		return vim.fn.strdisplaywidth(s)
	end

	-- Create new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.b[buf].is_dashboard = true

	local win = vim.api.nvim_get_current_win()
	local win_width = vim.api.nvim_win_get_width(win)
	local win_height = vim.api.nvim_win_get_height(win)

	-- Content definitions
	-- local header = {
	-- 	"        __",
	-- 	"     __/o \\_",
	-- 	"     \\____  \\",
	-- 	"         /   \\",
	-- 	"   __   //\\   \\",
	-- 	"__/o \\-//--\\   \\_/",
	-- 	"\\____  ___  \\  |",
	-- 	"     ||   \\ |\\ |",
	-- 	"    _||   _||_||",
	-- }

	local header = {
		"  =^..^=   ",
		"  ／l、    ",
		"（ﾟ､ 。 ７  ",
		"  l  ~ヽ   ",
		"  じしf_,)ノ",
	}

	local menu = {
		{ icon = " ", desc = "Find File", key = "f", action = "<cmd>lua Snacks.picker.files()<cr>" },
		{ icon = " ", desc = "Recent Files", key = "r", action = "<cmd>lua Snacks.picker.recent()<cr>" },
		{ icon = " ", desc = "Search Text", key = "s", action = "<cmd>lua Snacks.picker.grep()<cr>" },
		{ icon = "󰢱 ", desc = "Open Nvim Config", key = "c", action = "<cmd>edit $MYVIMRC<cr>" },
		{ icon = " ", desc = "Scratch Buffer", key = "b", action = "<cmd>enew<cr>" },
		{ icon = " ", desc = "Open Terminal", key = "t", action = "<cmd>terminal<cr>" },
		{ icon = " ", desc = "Help", key = "h", action = "<cmd>help<cr>" },
		{ icon = " ", desc = "Quit", key = "q", action = "<cmd>qa<cr>" },
	}

	local quote = {
		"One step at a time.",
	}

	-- Calculate layout
	local total_height = #header + 2 + 1 + #menu + 2 + #quote
	local top_padding = math.max(0, math.floor((win_height - total_height) / 2))

	local lines = {}
	local highlights = {}

	-- Top padding
	for _ = 1, top_padding do
		table.insert(lines, "")
	end

	-- Header
	for _, line in ipairs(header) do
		local shift = math.max(0, math.floor((win_width - dwidth(line)) / 2))
		table.insert(lines, string.rep(" ", shift) .. line)
		table.insert(highlights, { "DashHeader", #lines - 1, 0, -1 })
	end

	table.insert(lines, "")
	table.insert(lines, "")

	table.insert(lines, "")

	-- Menu
	local menu_width = 0
	for _, item in ipairs(menu) do
		local line_text = string.format("[%s] %s %s", item.key, item.icon, item.desc)
		menu_width = math.max(menu_width, dwidth(line_text))
	end

	local menu_shift = math.max(0, math.floor((win_width - menu_width) / 2))

	for _, item in ipairs(menu) do
		local key_text = string.format("[%s] ", item.key)
		local line_text = string.rep(" ", menu_shift) .. key_text .. item.icon .. " " .. item.desc
		table.insert(lines, line_text)

		local line_idx = #lines - 1
		local key_end = menu_shift + dwidth(key_text)
		local icon_end = key_end + dwidth(item.icon .. " ")

		table.insert(highlights, { "DashKey", line_idx, menu_shift, key_end })
		table.insert(highlights, { "DashIcon", line_idx, key_end, icon_end })
		table.insert(highlights, { "DashDesc", line_idx, icon_end, -1 })
	end

	table.insert(lines, "")
	table.insert(lines, "")

	-- Quote
	for _, line in ipairs(quote) do
		local shift = math.max(0, math.floor((win_width - dwidth(line)) / 2))
		table.insert(lines, string.rep(" ", shift) .. line)
		table.insert(highlights, { "DashFooter", #lines - 1, 0, -1 })
	end

	-- Apply lines to buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Apply highlights
	for _, hl in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(buf, -1, hl[1], hl[2], hl[3], hl[4])
	end

	-- Cleanup old buffer if resizing
	if vim.b[current_buf].is_dashboard then
		vim.api.nvim_buf_delete(current_buf, { force = true })
	end

	-- Set buffer options
	vim.api.nvim_set_current_buf(buf)
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.wrap = false
	vim.opt_local.signcolumn = "no"
	vim.opt_local.statuscolumn = ""
	vim.opt_local.cursorline = false
	vim.opt_local.filetype = "dashboard"

	-- Keymaps
	local opts = { buffer = buf, nowait = true, silent = true }
	for _, item in ipairs(menu) do
		vim.keymap.set("n", item.key, item.action, opts)
	end

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

vim.api.nvim_create_autocmd({ "VimEnter", "VimResized" }, {
	callback = function(args)
		vim.schedule(function()
			open_dashboard(args.event)
		end)
	end,
})

vim.opt.statusline = "%!v:lua.MistyStatusline()" -- Your original
