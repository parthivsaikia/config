return {
	"mason-org/mason.nvim",
	lazy = true,
	build = ":MasonUpdate",
	cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
	opts = {},
	config = function()
		require("mason").setup()

		local registry = require("mason-registry")
		local ensure_installed =
			{ "gopls", "lua-language-server", "typescript-language-server", "zls", "astro-language-server" }

		registry.refresh(function()
			for _, name in ipairs(ensure_installed) do
				local pkg = registry.get_package(name)
				if not pkg:is_installed() then
					pkg:install()
				end
			end
		end)
	end,
}
