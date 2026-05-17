return {
	"lewis6991/gitsigns.nvim",
	-- Lazy load when opening a file
	event = { "BufReadPost", "BufNewFile" },

	init = function()
		-- skip the plugin/ autoload
		vim.g.gitsigns_loaded = true
	end,
	opts = {
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		-- Platform Eng tweak:
		-- Disable the "current line blame" virtual text by default (distracting).
		-- You can toggle it with <leader>tb (see keymaps below).
		current_line_blame = false,

		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")
			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- Navigation
			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, "Next Hunk")

			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, "Prev Hunk")

			-- Actions
			map("n", "<leader>hs", gitsigns.stage_hunk, "[H]unk [S]tage")
			map("n", "<leader>hr", gitsigns.reset_hunk, "[H]unk [R]eset")
			map("n", "<leader>hS", gitsigns.stage_buffer, "[H]unk [S]tage Buffer")
			map("n", "<leader>hu", gitsigns.undo_stage_hunk, "[H]unk [U]ndo Stage")
			map("n", "<leader>hR", gitsigns.reset_buffer, "[H]unk [R]eset Buffer")
			map("n", "<leader>hp", gitsigns.preview_hunk, "[H]unk [P]review")
			map("n", "<leader>hb", gitsigns.blame_line, "[H]unk [B]lame Line")
			map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "[T]oggle [B]lame Line")
			map("n", "<leader>hd", gitsigns.diffthis, "[H]unk [D]iff")
		end,
	},
}
