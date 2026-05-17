-- plugins/snacks.lua
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		icons = { enable = true },
		dashboard = { enabled = false },
		picker = {
			enabled = true,
			ui_select = true,
			border = "rounded",
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
					},
				},
			},
			-- Override the file previewer to skip image rendering for svg
			sources = {
				files = {
					preview = function(ctx)
						local file = ctx.item and (ctx.item.file or ctx.item.filename or ctx.item.path)
						if file and file:match("%.svg$") then
							return false -- fall back to text preview
						end
						return Snacks.picker.preview.file(ctx)
					end,
				},
			},
		},
		image = {
			enabled = true,
			doc = { inline = false, float = true },
			markdown = { enabled = true },
			formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif" },
			-- explicitly exclude svg from image handling
			filter = function(file)
				return not file:match("%.svg$")
			end,
		},
		bigfile = { enabled = true },
		quickfile = { enabled = true },
		scroll = { enabled = false },
	},
	keys = function()
		-- Captures the current window at keypress time and forces
		-- the picker to open the file there on confirm.
		local function pick(source, opts)
			local win = vim.api.nvim_get_current_win()
			Snacks.picker[source](vim.tbl_extend("force", opts or {}, {
				on_show = function(picker)
					picker.opts.confirm_win = win
				end,
				confirm = function(picker, item)
					local target_win = picker.opts.confirm_win
					-- Capture cwd BEFORE closing, since close() destroys picker state.
					-- This is what makes cross-directory picking work: item.file may be
					-- a relative path (relative to the picker's cwd, not Neovim's cwd).
					local picker_cwd = picker:cwd()
					picker:close()
					if item then
						vim.api.nvim_set_current_win(target_win)
						if item.file or item.filename or item.path then
							local file = item.file or item.filename or item.path
							-- vim.fs.joinpath is cwd-aware: if file is already absolute
							-- it is returned as-is; if relative it is anchored to the
							-- picker's cwd rather than Neovim's cwd. The :p modifier
							-- then normalises symlinks / ".." segments.
							file = vim.fn.fnamemodify(vim.fs.joinpath(picker_cwd, file), ":p")
							vim.cmd("edit " .. vim.fn.fnameescape(file))
						end
						if item.line or item.row then
							local line = item.line or item.row
							local col = item.col or 0
							vim.schedule(function()
								local ok, err = pcall(function()
									local max = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(target_win))
									line = math.max(1, math.min(line, max))
									vim.api.nvim_win_set_cursor(target_win, { line, col })
								end)
								if not ok then
									vim.notify("Cursor jump failed: " .. err, vim.log.levels.WARN)
								end
							end)
						end
					end
				end,
			}))
		end
		return {
			{
				"<leader>sf",
				function()
					pick("files")
				end,
				desc = "[S]earch [F]iles",
			},
			{
				"<leader>sg",
				function()
					pick("grep")
				end,
				desc = "[S]earch by [G]rep",
			},
			{
				"<leader><leader>",
				function()
					pick("buffers")
				end,
				desc = "Find buffers",
			},
			{
				"<leader>s.",
				function()
					pick("recent")
				end,
				desc = "Recent files",
			},
			{
				"<leader>sr",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume search",
			},
			{
				"<leader>sw",
				function()
					pick("grep_word")
				end,
				desc = "Search word",
			},
			{
				"<leader>sh",
				function()
					pick("help")
				end,
				desc = "Help",
			},
			{
				"<leader>sk",
				function()
					pick("keymaps")
				end,
				desc = "Keymaps",
			},
			{
				"<leader>ss",
				function()
					pick("pickers")
				end,
				desc = "Pickers",
			},
			{
				"<leader>sd",
				function()
					pick("diagnostics")
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>/",
				function()
					pick("lines", { layout = { preview = false } })
				end,
				desc = "Search in buffer",
			},
			{
				"<leader>sn",
				function()
					pick("files", { cwd = vim.fn.stdpath("config") })
				end,
				desc = "Search nvim config",
			},
			-- LSP (these navigate to the target, not the calling win)
			{
				"grd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Definition",
			},
			{
				"grr",
				function()
					Snacks.picker.lsp_references()
				end,
				desc = "References",
			},
			{
				"gri",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Implementation",
			},
			{
				"grt",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Type def",
			},
			{
				"<leader>sym",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "Symbols",
			},
		}
	end,
}
