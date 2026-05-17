return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = true,
	build = function()
		require("nvim-treesitter").update()
	end,
	config = function()
		-- Install parsers (main branch uses explicit install calls)
		require("nvim-treesitter").install({
			"bash",
			"c",
			"diff",
			"lua",
			"luadoc",
			"query",
			"vim",
			"vimdoc",
			"html",
			"css",
			"javascript",
			"typescript",
			"tsx",
			"go",
			"gomod",
			"gowork",
			"gosum",
			"dockerfile",
			"yaml",
			"json",
			"toml",
			"terraform",
			"markdown",
			"markdown_inline",
		})

		-- Enable highlighting via Neovim's core API (not the plugin)
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(ev)
				local ok = pcall(vim.treesitter.start, ev.buf)
				if not ok then
					-- parser not available for this filetype, silently skip
				end
			end,
		})

		-- Enable indentation
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
