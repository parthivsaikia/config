return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.icons",
	},
	-- Load on both markdown AND telekasten filetypes
	ft = { "markdown", "telekasten" },

	-- Ensures Treesitter is ready for 'telekasten' files before the plugin loads

	opts = {
		-- Core settings
		latex = { enabled = false },
		file_types = { "markdown", "telekasten" },
		render_modes = { "n", "c" }, -- Render in Normal and Command mode

		code = {
			enabled = true,
			style = "full",
			language_pad = 0,
			language_info = true,
			width = "block",
		},

		-- Your Links setup
		link = {
			enabled = true,
			footnote = { enabled = true },
			image = "󰥶 ",
			email = "󰀓 ",
			hyperlink = "󰌹 ",
			wiki = { icon = "󱗖 " },
			custom = {
				web = { pattern = "^http", icon = "󰖟 " },
				github = { pattern = "github%.com", icon = "󰊤 " },
				youtube = { pattern = "youtube%.com", icon = "󰗃 " },
			},
		},

		-- Callouts (Obsidian style [!INFO])
		callout = {
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
			tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
			warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
			caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
			todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
		},

		-- Checkboxes
		checkbox = {
			enabled = true,
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
			custom = {
				todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
			},
		},

		-- Bullets and Heading styles
		bullet = {
			enabled = true,
			icons = { "●", "○", "◆", "◇" },
		},
		heading = {
			border = true, -- Draws a line under headers (very nice feature)
			width = "full",
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},
	},
}
