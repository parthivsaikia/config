return {
	"renerocksai/telekasten.nvim",
	dependencies = {
		{ "nvim-telescope/telescope.nvim", lazy = true }, -- ← add lazy = true
		{ "nvim-lua/plenary.nvim", lazy = true },
		"renerocksai/calendar-vim",
		{ "nvim-telescope/telescope-media-files.nvim", lazy = true },
	},
	-- === MOVED KEYS HERE ===
	keys = {
		{ "<leader>z", desc = "+Telekasten" }, -- Defines the group name

		{
			"<leader>zf",
			function()
				require("telekasten").find_notes()
			end,
			desc = "Find Note",
		},
		{
			"<leader>zg",
			function()
				require("telekasten").search_notes()
			end,
			desc = "Grep Notes",
		},
		{
			"<leader>zb",
			function()
				require("telekasten").show_backlinks()
			end,
			desc = "Show Backlinks",
		},
		{
			"<leader>z#",
			function()
				require("telekasten").show_tags()
			end,
			desc = "Show Tags",
		},
		{
			"<leader>zd",
			function()
				require("telekasten").goto_today()
			end,
			desc = "Daily Note",
		},
		{
			"<leader>zz",
			function()
				require("telekasten").follow_link()
			end,
			desc = "Follow/Create Link",
		},
		{
			"<leader>zt",
			function()
				require("telekasten").toggle_todo()
			end,
			desc = "Toggle To-Do",
		},
		{
			"<leader>zl",
			function()
				require("telekasten").insert_link()
			end,
			desc = "Insert Link",
		},
		{
			"<leader>zi",
			function()
				require("telekasten").paste_img_and_link()
			end,
			desc = "Paste Image",
		},
		{
			"<leader>zp",
			function()
				require("telekasten").preview_img()
			end,
			desc = "Preview Image",
		},
		{
			"<leader>zr",
			function()
				require("telekasten").rename_note()
			end,
			desc = "Rename Note",
		},
		{
			"<leader>zc",
			function()
				require("telekasten").show_calendar()
			end,
			desc = "Calendar",
		},

		-- Custom Workflow Mappings (Pointing to functions we attach in config below)
		{
			"<leader>zn",
			function()
				require("telekasten").create_and_log_note()
			end,
			desc = "New Note & Log",
		},
		{
			"<leader>zw",
			function()
				require("telekasten").goto_thisweek()
			end,
			desc = "This Week (Review)",
		},
		{
			"<leader>zwn",
			function()
				require("telekasten").goto_nextweek()
			end,
			desc = "Next Week (Plan)",
		},
		{
			"<leader>zdg",
			function()
				require("telekasten").goto_daily_goals()
			end,
			desc = "Daily Goals",
		},
	},

	config = function()
		local home = vim.fn.expand("~/Documents/MyVault")
		local tel = require("telekasten")

		-- Safety check for telescope extension
		pcall(require("telescope").load_extension, "media_files")

		tel.setup({
			home = home,
			dailies = home .. "/Daily Notes",
			weeklies = home .. "/Weekly Notes",
			templates = home .. "/templates",

			image_subdir = "attachments",
			image_link_style = "markdown",

			-- Force wl-paste to only accept PNG images (Fixes text-paste issue)
			clipboard_program = "wl-paste --type image/png",

			template_new_note = home .. "/templates/Default.md",
			template_new_daily = home .. "/templates/Daily_journal.md",
			template_new_weekly = home .. "/templates/Weekly.md",

			journal_auto_open = true,
			auto_set_filetype = true,
			auto_set_syntax = true,
			take_over_my_home = true,

			plug_into_calendar = true,
			calendar_opts = {
				weeknm = 4,
				calendar_monday = 1,
				calendar_mark = "left-fit",
			},

			media_previewer = "telescope-media-files",
		})

		-- === ABBREVIATIONS ===
		local cmd_abbreviations = {
			con = "Concepts/",
			src = "Sources/",
			bi = "Blog Ideas/",
			dg = "Daily Goals/",
			dj = "Journal/",
			pi = "Project Ideas/",
			pp = "Projects Progress/",
			ti = "Twitter Ideas/",
			ri = "Inbox/",
		}

		vim.keymap.set("c", "<Space>", function()
			local line = vim.fn.getcmdline()
			local pos = vim.fn.getcmdpos()
			if pos ~= #line + 1 then
				return "<Space>"
			end

			local last_word_start = line:match("^.*()%s") or 0
			local last_word = line:sub(last_word_start + 1)
			local replacement = cmd_abbreviations[last_word]

			if replacement then
				return "<C-U>" .. line:sub(1, last_word_start) .. replacement
			else
				return "<Space>"
			end
		end, { expr = true })

		-- === CUSTOM WORKFLOW FUNCTIONS ===

		-- Helper: Append text to a file
		local function append_to_file(filepath, text)
			local file = io.open(filepath, "a")
			if file then
				file:write("\n" .. text)
				file:close()
			end
		end

		-- Helper: Ensure the CURRENT week's note exists
		local function ensure_current_week_exists()
			local year = vim.fn.strftime("%Y")
			local week = vim.fn.strftime("%V")
			local filename = year .. "-W" .. week .. ".md"
			local weekly_dir = home .. "/Weekly Notes"
			local filepath = weekly_dir .. "/" .. filename

			if vim.fn.isdirectory(weekly_dir) == 0 then
				vim.fn.mkdir(weekly_dir, "p")
			end

			if vim.fn.filereadable(filepath) == 0 then
				local tpl_path = home .. "/templates/Weekly.md"
				if vim.fn.filereadable(tpl_path) == 1 then
					local content = vim.fn.readfile(tpl_path)
					local date_iso = vim.fn.strftime("%Y-%m-%d")
					for i, line in ipairs(content) do
						content[i] = line:gsub("{{year}}", year)
						content[i] = content[i]:gsub("{{week}}", week)
						content[i] = content[i]:gsub("{{date}}", date_iso)
					end
					vim.fn.writefile(content, filepath)
				else
					vim.fn.writefile({ "# Week " .. week .. " " .. year }, filepath)
				end
				print("Created new weekly note: " .. filename)
			end
			return filepath
		end

		-- === ATTACH CUSTOM FUNCTIONS TO MODULE ===
		-- We attach these to 'tel' so the 'keys' table above can call them via require('telekasten').xyz

		-- 1. Daily Goals (Restored)
		tel.goto_daily_goals = function()
			local date_iso = vim.fn.strftime("%Y-%m-%d")
			local goals_dir = home .. "/Daily Goals"
			local note_path = goals_dir .. "/daily_goal_" .. date_iso .. ".md"

			vim.fn.mkdir(goals_dir, "p")

			if vim.fn.filereadable(note_path) == 0 then
				local tpl = home .. "/templates/Daily_goals.md"
				if vim.fn.filereadable(tpl) == 1 then
					local content = vim.fn.readfile(tpl)
					for i, line in ipairs(content) do
						content[i] = line:gsub("{{date}}", date_iso)
					end
					vim.fn.writefile(content, note_path)
				else
					vim.fn.writefile({ "# Daily Goals: " .. date_iso }, note_path)
				end
			end
			vim.cmd("edit " .. note_path)
		end

		-- 2. Plan Next Week
		tel.goto_nextweek = function()
			local next_week_sec = os.time() + (7 * 24 * 60 * 60)
			local year = vim.fn.strftime("%Y", next_week_sec)
			local week = vim.fn.strftime("%V", next_week_sec)

			local filename = year .. "-W" .. week .. ".md"
			local weekly_dir = home .. "/Weekly Notes"
			local filepath = weekly_dir .. "/" .. filename

			vim.fn.mkdir(weekly_dir, "p")

			if vim.fn.filereadable(filepath) == 0 then
				local tpl_path = home .. "/templates/Weekly.md"
				if vim.fn.filereadable(tpl_path) == 1 then
					local content = vim.fn.readfile(tpl_path)
					for i, line in ipairs(content) do
						content[i] = line:gsub("{{year}}", year)
						content[i] = content[i]:gsub("{{week}}", week)
						content[i] = content[i]:gsub("{{date}}", vim.fn.strftime("%Y-%m-%d", next_week_sec))
					end
					vim.fn.writefile(content, filepath)
				else
					vim.fn.writefile({ "# Week " .. week .. " " .. year }, filepath)
				end
			end
			vim.cmd("edit " .. filepath)
		end

		-- 3. Smart Logger
		tel.create_and_log_note = function()
			local weekly_note_path = ensure_current_week_exists()

			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "*.md",
				once = true,
				callback = function(ev)
					local new_note_path = vim.fn.expand("%:p")

					-- Safety checks
					if not new_note_path:find(home, 1, true) then
						return
					end
					if new_note_path == weekly_note_path then
						return
					end

					-- Calculate path relative to home
					local relative_path = new_note_path:sub(#home + 1)

					-- Strip leading slash
					if relative_path:match("^/") or relative_path:match("^\\") then
						relative_path = relative_path:sub(2)
					end

					-- Remove extension
					local new_note_title = relative_path:gsub("%.md$", "")

					local log_entry = "- [ ] Created: [[" .. new_note_title .. "]]"
					append_to_file(weekly_note_path, log_entry)
					print("Logged " .. new_note_title .. " to this week's note.")
				end,
			})
			tel.new_note()
		end
	end,
}
