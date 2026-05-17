return {
	"NMAC427/guess-indent.nvim",
	event = "BufReadPre",
	opts = {
		auto_cmd = true, -- Set to false to disable automatic execution
		override_editorconfig = false, -- Set to true to override settings set by .editorconfig
		filetype_exclude = { -- A list of filetypes for which the auto command gets disabled
			"netrw",
			"tutor",
		},
		buftype_exclude = { -- A list of buffer types for which the auto command gets disabled
			"help",
			"nofile",
			"terminal",
			"prompt",
		},
		-- Set your preferred defaults when detection fails
		fallback_to_default = true,
		default_tab_width = 4,
	},
}
