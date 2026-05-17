return {
	"stevearc/oil.nvim",

	-- 1. Remove 'lazy = false'.
	-- 2. Add triggers. Oil will now load ONLY when you press '-' or type :Oil.
	cmd = "Oil",
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open Parent Directory" },
	},

	-- 3. Optimization for Icons
	-- 'mini.icons' is lighter than nvim-web-devicons
	dependencies = {
		{ "echasnovski/mini.icons", opts = {}, lazy = true },
	},

	opts = {
		-- Your standard options
		default_file_explorer = true,
	},
}
