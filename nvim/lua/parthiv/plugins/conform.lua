return {
	"stevearc/conform.nvim",

	-- 1. LAZY TRIGGER:
	-- Only loads when you save a file or explicitly press <leader>f.
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},

	opts = {
		notify_on_error = false,

		-- 2. FORMAT ON SAVE
		format_on_save = function(bufnr)
			-- Disable for C/C++ (Personal preference maintained)
			local disable_filetypes = { c = true, cpp = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			end

			return { timeout_ms = 2500, lsp_format = "fallback" }
		end,

		-- 3. FORMATTERS
		formatters_by_ft = {
			-- Lua
			lua = { "stylua" },

			-- Go: CRITICAL UPDATE
			-- Run 'goimports' (fix imports) -> THEN 'gofumpt' (strict format)
			go = { "goimports", "gofumpt" },

			-- Web / JS (Prettier/Biome Fallback)
			-- We group these for cleaner reading
			javascript = { "biome", "prettier", stop_after_first = true },
			javascriptreact = { "biome", "prettier", stop_after_first = true },
			typescript = { "biome", "prettier", stop_after_first = true },
			typescriptreact = { "biome", "prettier", stop_after_first = true },
			json = { "biome", "prettier", stop_after_first = true },

			css = { "prettier" },
			html = { "prettier" },
			markdown = { "prettier" },
			yaml = { "prettier" }, -- Useful for Kubernetes/DevOps
			astro = { "prettier" },
		},
	},
}
