return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Define linters by filetype
		lint.linters_by_ft = {
			dockerfile = { "hadolint" },
			go = { "golangcilint" },
			-- json = { 'jsonlint' },
		}

		-- Create autocommand to trigger linting
		-- Unlike LSP, linting usually happens on save or InsertLeave
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
