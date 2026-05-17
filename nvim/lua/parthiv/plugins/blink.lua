return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	version = "1.*",
	config = function(_, opts)
		require("parthiv.core.snippets").setup()
		require("blink.cmp").setup(opts)
	end,
	opts = {
		keymap = {
			preset = "super-tab",
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		sources = {
			-- 1. Add "custom_snippets" to your default sources array
			default = { "custom_snippets", "lsp", "path", "snippets", "buffer" },
			providers = {
				-- 2. Define the provider and point it to the bridge file we made
				custom_snippets = {
					name = "MySnips",
					module = "parthiv.core.blink_source",
					score_offset = -25, -- High score so your custom snips appear at the top
				},
				buffer = {
					score_offset = -50,
				},
			},
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},

		signature = {
			enabled = true,
		},

		completion = {
			menu = {
				border = "rounded",
			},
		},
	},

	opts_extend = { "sources.default" },
}
