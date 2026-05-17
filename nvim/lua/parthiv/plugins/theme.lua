return {
	{
		"mistyforest",
		dir = vim.fn.stdpath("config"),
		priority = 1000,
		lazy = false,
		config = function()
			local cache_file = vim.fn.stdpath("cache") .. "/mistyforest_compiled.lua"

			-- The heavy lifting is isolated here and ONLY runs when compiling.
			local function compile_and_load()
				local c = {
					bg = "#060606",
					ui_line = "#0f0f0f",
					ui_darkest = "#080808",
					ui_darker = "#191919",
					ui_dark = "#2a2a2a",
					ui_border = "#444444",
					fg = "#e2e0d4",
					fg_dim = "#a8a89a",
					fg_dimmer = "#6f6f64",
					luster = "#deeeed",
					black = "#000000",
					gray1 = "#080808",
					gray2 = "#191919",
					gray3 = "#2a2a2a",
					gray4 = "#444444",
					gray5 = "#555555",
					gray6 = "#7a7a7a",
					gray7 = "#aaaaaa",
					gray8 = "#cccccc",
					gray9 = "#DDDDDD",
					keyword = "#bdb9a8",
					string = "#8a9f75",
					type = "#95a68b",
					func = "#8e9f96",
					number = "#a8a377",
					comment = "#4f4f46",
					error = "#a36666",
					warn = "#b0a16f",
					info = "#7f9989",
					orange = "#b0a16f",
					yellow = "#a8a377",
					green = "#8a9f75",
					blue = "#7788AA",
					red = "#a36666",
					lack = "#708090",
					cyan = "#6e9ca0",
					violet = "#9a8ac2",
					rose = "#b07a7a",
				}

				local highlights = {
					-- Floating windows & borders
					FloatBorder = { fg = c.string, bg = c.ui_darkest },
					FloatTitle = { fg = c.keyword, bg = c.ui_darkest, bold = true },
					NormalFloat = { fg = c.fg, bg = c.ui_darkest },

					-- Non-text / structural
					NonText = { fg = c.ui_darker },
					Folded = { fg = c.comment, bg = c.ui_darkest },
					MatchParen = { fg = c.func, bg = c.ui_dark, bold = true },
					EndOfBuffer = { fg = c.bg },

					-- Editor core
					Normal = { fg = c.fg, bg = c.bg },
					NormalNC = { fg = c.fg_dim, bg = c.bg },
					Comment = { fg = c.comment, italic = true },
					LineNr = { fg = c.fg_dimmer },
					CursorLineNr = { fg = c.fg, bold = true },
					CursorLine = { bg = c.ui_line },
					CursorColumn = { bg = c.ui_line },
					ColorColumn = { bg = c.ui_darker },
					Visual = { bg = "#3a3f33" }, -- fg = "NONE" handled inherently in Lua by omission
					Search = { bg = c.ui_dark, fg = c.keyword, bold = true },
					IncSearch = { bg = c.gray2, fg = c.keyword, bold = true },
					WinSeparator = { fg = c.ui_border },
					VertSplit = { fg = c.ui_border },
					SignColumn = { bg = c.bg },
					WinBar = { fg = c.fg_dim, bg = c.ui_line },
					WinBarNC = { fg = c.fg_dimmer, bg = c.ui_line },
					Title = { fg = c.keyword, bold = true },
					Directory = { fg = c.func },

					-- Cursor & extra
					Cursor = { fg = c.bg, bg = c.fg_dim },
					lCursor = { fg = c.bg, bg = c.fg_dim },
					CursorIM = { fg = c.bg, bg = c.fg_dim },
					Conceal = { fg = c.fg_dimmer },
					FoldColumn = { fg = c.comment, bg = c.bg },
					QuickFixLine = { bg = c.ui_dark },
					Substitute = { bg = c.ui_dark, fg = c.error },
					Whitespace = { fg = c.fg_dimmer },
					SpecialKey = { fg = c.fg_dimmer },

					-- Tabs
					TabLine = { fg = c.fg_dimmer, bg = c.ui_dark },
					TabLineFill = { bg = c.ui_darker },
					TabLineSel = { fg = c.fg, bg = c.ui_line, bold = true },
					Todo = { fg = c.warn, italic = true, bold = true },

					-- Messages
					ModeMsg = { fg = c.keyword, bold = true },
					MoreMsg = { fg = c.string },
					Question = { fg = c.info },

					-- Spelling
					SpellBad = { undercurl = true, sp = c.error },
					SpellCap = { undercurl = true, sp = c.warn },
					SpellRare = { undercurl = true, sp = c.info },
					SpellLocal = { undercurl = true, sp = c.string },

					-- Diff
					DiffAdd = { fg = c.string, bg = c.ui_line },
					DiffChange = { fg = c.warn, bg = c.ui_line },
					DiffDelete = { fg = c.error, bg = c.ui_line },
					DiffText = { fg = c.string, bg = "#1a2a1a" },
					Added = { fg = c.string },
					Changed = { fg = c.warn },
					Removed = { fg = c.error },

					-- Syntax & LSP ...
					Constant = { fg = c.number },
					String = { fg = c.string },
					Character = { fg = c.string },
					Number = { fg = c.number },
					Boolean = { fg = c.number },
					Float = { fg = c.number },
					Identifier = { fg = c.fg },
					Function = { fg = c.func },
					Statement = { fg = c.keyword },
					Conditional = { fg = c.keyword },
					Repeat = { fg = c.keyword },
					Label = { fg = c.keyword },
					Operator = { fg = c.fg_dim },
					Keyword = { fg = c.keyword },
					Exception = { fg = c.keyword },
					PreProc = { fg = c.keyword },
					Include = { fg = c.keyword },
					Define = { fg = c.keyword },
					Macro = { fg = c.keyword },
					PreCondit = { fg = c.keyword },
					Type = { fg = c.type },
					StorageClass = { fg = c.keyword },
					Structure = { fg = c.type },
					Typedef = { fg = c.type },
					Special = { fg = c.func },
					SpecialChar = { fg = c.number },
					Tag = { fg = c.type },
					Delimiter = { fg = c.fg_dim },
					SpecialComment = { fg = c.comment, italic = true },
					Debug = { fg = c.error },
					Error = { fg = c.error },
					ErrorMsg = { fg = c.error, bold = true },
					WarningMsg = { fg = c.warn, bold = true },
					-- =============================================
					-- NATIVE STATUSLINE (SOLID BLOCKS + SEAMLESS MIDDLE)
					-- =============================================
					-- Base Fill (Blends into editor)
					StatusLine = { fg = c.fg_dim, bg = c.bg },
					StatusLineNC = { fg = c.ui_darker, bg = c.bg },
					StBg = { bg = c.bg },

					-- Left Side blocks
					StMode = { fg = c.bg, bg = c.string, bold = true },
					StModeSep = { fg = c.string, bg = c.fg },
					StFile = { fg = c.bg, bg = c.fg, bold = true },
					StFileSep = { fg = c.fg, bg = c.comment },
					StPath = { fg = c.fg, bg = c.comment },
					StPathSep = { fg = c.comment, bg = c.bg }, -- Slants into editor bg

					-- Diagnostics (Floating in the seamless middle)
					StErr = { fg = c.error, bg = c.bg, bold = true },
					StGit = { fg = c.orange, bg = c.bg, bold = true },
					StWarn = { fg = c.warn, bg = c.bg, bold = true },
					StInfo = { fg = c.info, bg = c.bg, bold = true },
					StHint = { fg = c.fg_dimmer, bg = c.bg, bold = true },

					-- Right Side blocks
					StLspSep = { fg = c.bg, bg = c.comment },
					StLsp = { fg = c.fg, bg = c.comment },
					StLspSep2 = { fg = c.comment, bg = c.fg },
					StBgToFg = { fg = c.bg, bg = c.fg }, -- Fallback if no LSP
					StType = { fg = c.bg, bg = c.fg, bold = true },

					-- The \\ Gap Effect components
					StTypeSep = { fg = c.fg, bg = c.bg }, -- First slash (White to BG)
					StLocSep = { fg = c.bg, bg = c.string }, -- Second slash (BG to Green)
					StLoc = { fg = c.bg, bg = c.string, bold = true },
					-- Statusline mode variants
					-- Insert (blue-ish)
					StModeInsert = { fg = c.bg, bg = c.blue, bold = true },
					StModeSepInsert = { fg = c.blue, bg = c.fg },
					StLocInsert = { fg = c.bg, bg = c.blue, bold = true },
					StLocSepInsert = { fg = c.bg, bg = c.blue },

					-- Visual (violet)
					StModeVisual = { fg = c.bg, bg = c.violet, bold = true },
					StModeSepVisual = { fg = c.violet, bg = c.fg },
					StLocVisual = { fg = c.bg, bg = c.violet, bold = true },
					StLocSepVisual = { fg = c.bg, bg = c.violet },

					-- Command (orange/yellow)
					StModeCmd = { fg = c.bg, bg = c.orange, bold = true },
					StModeSepCmd = { fg = c.orange, bg = c.fg },
					StLocCmd = { fg = c.bg, bg = c.orange, bold = true },
					StLocSepCmd = { fg = c.bg, bg = c.orange },

					-- Replace (red/rose)
					StModeReplace = { fg = c.bg, bg = c.rose, bold = true },
					StModeSepReplace = { fg = c.rose, bg = c.fg },
					StLocReplace = { fg = c.bg, bg = c.rose, bold = true },
					StLocSepReplace = { fg = c.bg, bg = c.rose },

					-- Treesitter
					["@variable"] = { fg = c.fg },
					["@variable.builtin"] = { fg = c.keyword },
					["@function"] = { fg = c.func },
					["@function.builtin"] = { fg = c.func },
					["@function.call"] = { fg = c.func },
					["@method"] = { fg = c.func },
					["@method.call"] = { fg = c.func },
					["@keyword"] = { fg = c.keyword },
					["@keyword.function"] = { fg = c.keyword },
					["@keyword.return"] = { fg = c.keyword },
					["@string"] = { fg = c.string },
					["@string.escape"] = { fg = c.fg_dimmer },
					["@number"] = { fg = c.number },
					["@boolean"] = { fg = c.number },
					["@type"] = { fg = c.type },
					["@type.builtin"] = { fg = c.type },
					["@constant"] = { fg = c.number },
					["@constant.builtin"] = { fg = c.number },
					["@operator"] = { fg = c.fg_dim },
					["@punctuation.bracket"] = { fg = c.fg_dimmer },
					["@punctuation.delimiter"] = { fg = c.fg_dim },
					["@comment"] = { fg = c.comment, italic = true },
					["@parameter"] = { fg = c.fg_dim },
					["@field"] = { fg = c.fg_dim },
					["@property"] = { fg = c.fg_dim },
					["@namespace"] = { fg = c.type },
					["@constructor"] = { fg = c.type },
					["@tag"] = { fg = c.keyword },
					["@tag.attribute"] = { fg = c.fg_dim },
					["@tag.delimiter"] = { fg = c.fg_dimmer },

					["@markup.heading"] = { link = "Title" },
					["@markup.strong"] = { bold = true },
					["@markup.italic"] = { italic = true },
					["@markup.list"] = { fg = c.string },
					["@markup.link"] = { fg = c.func, underline = true },
					["@markup.link.label"] = { fg = c.func },
					["@comment.todo"] = { fg = c.warn, bold = true },
					["@comment.note"] = { fg = c.info },
					["@comment.warning"] = { fg = c.warn },
					["@diff.plus"] = { fg = c.string },
					["@diff.minus"] = { fg = c.error },
					["@diff.delta"] = { fg = c.warn },

					-- LSP
					DiagnosticError = { fg = c.error },
					DiagnosticWarn = { fg = c.warn },
					DiagnosticInfo = { fg = c.info },
					DiagnosticHint = { fg = c.fg_dimmer },
					DiagnosticUnderlineError = { undercurl = true, sp = c.error },
					DiagnosticUnderlineWarn = { undercurl = true, sp = c.warn },
					DiagnosticUnderlineInfo = { undercurl = true, sp = c.info },
					DiagnosticUnderlineHint = { undercurl = true, sp = c.fg_dimmer },
					LspReferenceText = { bg = c.ui_dark },
					LspReferenceRead = { bg = c.ui_dark },
					LspReferenceWrite = { bg = c.ui_dark },
					LspInlayHint = { fg = c.fg_dimmer, bg = c.ui_darker, italic = true },
					LspCodeLens = { fg = c.comment, italic = true },
					LspSignatureActiveParameter = { fg = c.keyword, bold = true },

					-- Telescope
					TelescopeBorder = { fg = c.ui_border, bg = c.ui_darkest },
					TelescopePromptBorder = { fg = c.ui_border, bg = c.ui_darkest },
					TelescopeResultsBorder = { fg = c.ui_border, bg = c.ui_darkest },
					TelescopePreviewBorder = { fg = c.ui_border, bg = c.ui_darkest },
					TelescopeSelection = { bg = c.ui_dark, bold = true },
					TelescopeMatching = { fg = c.string, bold = true },

					-- Git & UI plugins
					GitSignsAdd = { fg = c.string },
					GitSignsChange = { fg = c.warn },
					GitSignsDelete = { fg = c.error },
					Pmenu = { fg = c.fg, bg = c.ui_darkest },
					PmenuSel = { fg = c.fg, bg = c.ui_dark, bold = true },
					PmenuSbar = { bg = c.ui_darkest },
					PmenuThumb = { bg = c.gray5 },
					PmenuBorder = { fg = c.ui_border, bg = c.ui_darkest },
					PmenuKind = { fg = c.type, bg = c.ui_darkest },
					PmenuKindSel = { fg = c.func, bg = c.ui_dark, bold = true },
					PmenuExtra = { fg = c.fg_dimmer, bg = c.ui_darkest },
					PmenuExtraSel = { fg = c.fg_dim, bg = c.ui_dark },
					CmpItemAbbr = { fg = c.fg },
					CmpItemAbbrDeprecated = { fg = c.fg_dimmer, strikethrough = true },
					CmpItemAbbrMatch = { fg = c.string, bold = true },
					CmpItemAbbrMatchFuzzy = { fg = c.string, bold = true },
					CmpItemKind = { fg = c.type },
					CmpItemKindDefault = { fg = c.type },
					CmpItemMenu = { fg = c.fg_dim },

					-- File explorers & Bufferline
					NvimTreeNormal = { fg = c.fg, bg = c.ui_darkest },
					NvimTreeNormalNC = { fg = c.fg_dim, bg = c.ui_darkest },
					NvimTreeFolderName = { fg = c.func },
					NvimTreeOpenedFolderName = { fg = c.string, bold = true },
					NvimTreeRootFolder = { fg = c.keyword },
					NvimTreeExecFile = { fg = c.string },
					NvimTreeSymlink = { fg = c.func },
					NvimTreeGitNew = { fg = c.string },
					NvimTreeGitDirty = { fg = c.warn },
					NvimTreeGitDeleted = { fg = c.error },
					NeoTreeNormal = { fg = c.fg, bg = c.ui_darkest },
					NeoTreeNormalNC = { fg = c.fg_dim, bg = c.ui_darkest },
					NeoTreeDirectoryName = { fg = c.func },
					NeoTreeDirectoryIcon = { fg = c.type },
					NeoTreeFileName = { fg = c.fg },
					NeoTreeFileNameOpened = { fg = c.string },
					NeoTreeGitAdded = { fg = c.string },
					NeoTreeGitDeleted = { fg = c.error },
					NeoTreeGitModified = { fg = c.warn },
					NeoTreeIndentMarker = { fg = c.ui_border },
					IblIndent = { fg = c.ui_border },
					IblScope = { fg = c.string },
					IblWhitespace = { fg = c.ui_darker },
					BufferLineFill = { bg = c.ui_darkest },
					BufferLineBuffer = { fg = c.fg_dim, bg = c.ui_dark },
					BufferLineBufferSelected = { fg = c.fg, bg = c.ui_line, bold = true },
					BufferLineBufferVisible = { fg = c.fg_dim, bg = c.ui_dark },
					BufferLineSeparator = { fg = c.ui_border, bg = c.ui_dark },
					BufferLineIndicatorSelected = { fg = c.string, bg = c.ui_line },
					WhichKey = { fg = c.keyword },
					WhichKeyGroup = { fg = c.type },
					WhichKeyDesc = { fg = c.fg },
					WhichKeySeparator = { fg = c.comment },
					WhichKeyBorder = { fg = c.ui_border, bg = c.ui_darkest },
					LazyNormal = { bg = c.ui_darkest },
					LazyBorder = { fg = c.ui_border, bg = c.ui_darkest },
					MasonNormal = { bg = c.ui_darkest },
					MasonHeader = { fg = c.bg, bg = c.keyword, bold = true },
					MasonHighlight = { fg = c.string },
					MasonMuted = { fg = c.fg_dimmer },

					-- Snacks Picker (Flattened directly into highlights)
					SnacksPickerList = { bg = c.gray1 },
					SnacksPickerInput = { fg = c.fg, bg = c.gray2 },
					SnacksPickerFile = { fg = c.fg },
					SnacksPickerDir = { fg = c.fg_dim },
					SnacksPickerPathHidden = { fg = c.fg_dimmer },
					SnacksPickerPathIgnored = { fg = c.comment },
					SnacksPickerListCursorLine = { bg = c.gray3 },
					SnacksPickerMatch = { fg = c.string, bold = true },
					SnacksPickerGitStatusAdded = { fg = c.string },
					SnacksPickerGitStatusModified = { fg = c.warn },
					SnacksPickerGitStatusDeleted = { fg = c.error },
					SnacksPickerGitStatusRenamed = { fg = c.func },
					SnacksPickerGitStatusUntracked = { fg = c.fg_dimmer },
					SnacksPickerPrompt = { fg = c.fg, bg = c.gray2 },
					SnacksPickerTitle = { fg = c.keyword, bg = c.ui_dark, bold = true },
					SnacksPickerBorder = { fg = c.ui_border, bg = c.gray1 },
					SnacksPickerPreview = { bg = c.ui_darkest },
					-- Markdown Treesitter overrides (fix code block bg being overridden)
					["@markup.raw.block.markdown"] = { bg = "#111111" },
					["@markup.raw.markdown_inline"] = { fg = "#8abab6", bg = "#1a2020", italic = true },
				}

				-- Build the raw Lua execution string
				local lines = {
					"vim.cmd('highlight clear')",
					"if vim.fn.exists('syntax_on') == 1 then vim.cmd('syntax reset') end",
					"vim.o.termguicolors = true",
					"vim.g.colors_name = 'mistyforest'",
					"local hl = vim.api.nvim_set_hl",
					string.format("vim.g.terminal_color_0 = '%s'", c.bg),
					string.format("vim.g.terminal_color_1 = '%s'", c.error),
					string.format("vim.g.terminal_color_2 = '%s'", c.string),
					string.format("vim.g.terminal_color_3 = '%s'", c.warn),
					string.format("vim.g.terminal_color_4 = '%s'", c.info),
					string.format("vim.g.terminal_color_5 = '%s'", c.func),
					string.format("vim.g.terminal_color_6 = '%s'", c.type),
					string.format("vim.g.terminal_color_7 = '%s'", c.fg_dim),
					string.format("vim.g.terminal_color_8 = '%s'", c.ui_darker),
					string.format("vim.g.terminal_color_9 = '%s'", c.error),
					string.format("vim.g.terminal_color_10 = '%s'", c.string),
					string.format("vim.g.terminal_color_11 = '%s'", c.warn),
					string.format("vim.g.terminal_color_12 = '%s'", c.info),
					string.format("vim.g.terminal_color_13 = '%s'", c.func),
					string.format("vim.g.terminal_color_14 = '%s'", c.type),
					string.format("vim.g.terminal_color_15 = '%s'", c.fg),
				}

				-- Compile highlight tables into raw API calls
				for group, opts in pairs(highlights) do
					local opts_str = "{"
					for k, v in pairs(opts) do
						if type(v) == "string" then
							opts_str = string.format("%s%s='%s',", opts_str, k, v)
						elseif type(v) == "boolean" then
							opts_str = string.format("%s%s=%s,", opts_str, k, tostring(v))
						end
					end
					opts_str = opts_str .. "}"
					table.insert(lines, string.format("hl(0, '%s', %s)", group, opts_str))
				end

				-- Write to cache file
				local file = io.open(cache_file, "w")
				if file then
					file:write(table.concat(lines, "\n"))
					file:close()
				end

				-- Load it immediately after compiling
				dofile(cache_file)
			end

			-- =====================================
			-- STARTUP EXECUTION LOGIC
			-- =====================================
			local f = loadfile(cache_file)
			if f then
				f() -- Cache hit: Instant load
			else
				compile_and_load() -- Cache miss: Build and load
			end

			-- User command to regenerate the theme after making edits
			vim.api.nvim_create_user_command("MistyCompile", function()
				compile_and_load()
				vim.notify("Mistyforest successfully compiled!", vim.log.levels.INFO)
			end, {})
			-- =====================================
			-- AUTO-COMPILE ON SAVE
			-- =====================================
			local misty_group = vim.api.nvim_create_augroup("MistyforestCompile", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = misty_group,
				pattern = "theme.lua",
				callback = function()
					compile_and_load()
					vim.notify("Mistyforest re-compiled on save!", vim.log.levels.INFO)
				end,
			})
		end,
	},
}
