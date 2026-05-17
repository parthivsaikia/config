return {
	"folke/todo-comments.nvim",

	-- 1. OPTIMIZATION: Load only when opening a file.
	-- "VimEnter" blocks the UI startup.
	-- "BufReadPost" happens AFTER the file is read, so it's non-blocking.
	event = { "BufReadPost", "BufNewFile" },

	dependencies = { "nvim-lua/plenary.nvim" },

	opts = {
		signs = false, -- You already had this (good for visual clutter reduction)

		-- 2. OPTIMIZATION: Merge keywords
		-- Merging similar keywords reduces the number of regex checks.
		merge_keywords = true,

		-- 3. HIGHLIGHTING:
		-- If you want it even faster, you can disable highlighting in comments
		-- and only use it for the search command (:TodoTelescope / :TodoQuickFix)
		-- highlight = {
		--   comments_only = true,
		-- },
	},
}
