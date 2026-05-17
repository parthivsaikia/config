return {
	"windwp/nvim-autopairs",

	-- ⚡ OPTIMIZED: Only loads when you start typing.
	event = "InsertEnter",

	opts = {
		check_ts = true, -- Use Treesitter to check for pairs (smarter)
		ts_config = {
			lua = { "string" }, -- Don't add pairs inside string nodes
			javascript = { "template_string" },
			java = false,
		},
	},
}
