-- plugins/which-key.lua
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 200,
		icons = {
			mappings = true,
			keys = {},
		},
		spec = {
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			{ "<leader>a", group = "[A]I / Notes" },
		},
	},
}
