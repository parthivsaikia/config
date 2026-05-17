-- 1. Setup shared capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Safely try to load blink.cmp's capabilities
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
	capabilities = blink.get_lsp_capabilities(capabilities)
end

-- 2. Helper to register and enable an LSP server
-- ... (rest of your code stays exactly the same)
local function lsp(name, config)
	vim.lsp.config(
		name,
		vim.tbl_extend("force", {
			capabilities = capabilities,
		}, config)
	)
	vim.lsp.enable(name)
end

-- 3. LSP Server Configs
local servers = {
	gopls = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork" },
		root_markers = { "go.mod", "go.work", ".git" },
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = true,
				analyses = { unusedparams = true },
				semanticTokens = true,
			},
		},
	},
	zls = {
		cmd = { "zls" },
		filetypes = { "zig" },
		root_markers = { "build.zig", ".git" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".git" },
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = {
					checkThirdParty = false,
					library = { vim.env.VIMRUNTIME },
				},
				telemetry = { enable = false },
			},
		},
	},
	ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "typescript", "javascript" },
		root_markers = { "package.json", ".git" },
	},
	astro_ls = {
		cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/astro-ls"), "--stdio" },
		filetypes = { "astro" },
		root_markers = { "package.json", "tsconfig.json", ".git" },
		init_options = {
			typescript = {
				tsdk = (function()
					-- 1. Try project-local typescript first
					local local_ts = vim.fn.getcwd() .. "/node_modules/typescript/lib"
					if vim.fn.isdirectory(local_ts) == 1 then
						return local_ts
					end
					-- 2. Try Mason's typescript-language-server bundled typescript
					local mason_ts = vim.fn.stdpath("data")
						.. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
					if vim.fn.isdirectory(mason_ts) == 1 then
						return mason_ts
					end
					-- 3. Fallback to global npm
					local global_ts = vim.fn.system("npm root -g"):gsub("\n", "") .. "/typescript/lib"
					return global_ts
				end)(),
			},
		},
	},
	tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"astro",
			"svelte",
			"vue",
		},
		root_markers = {
			"tailwind.config.js",
			"tailwind.config.ts",
			"tailwind.config.cjs",
			"postcss.config.js",
			"postcss.config.cjs",
			"package.json",
			".git",
		},
		settings = {
			tailwindCSS = {
				validate = true,
				lint = {
					cssConflict = "warning",
					invalidApply = "error",
					invalidScreen = "error",
					invalidVariant = "error",
					invalidConfigPath = "error",
					invalidTailwindDirective = "error",
					recommendedVariantOrder = "warning",
				},
				experimental = {
					-- Enables completions inside string literals, template literals,
					-- and other non-class-attribute contexts
					classRegex = {
						{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
						{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
						{ "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					},
				},
			},
		},
	},
}

for name, config in pairs(servers) do
	lsp(name, config)
end

-- 4. On Attach: keymaps, completion, highlights, hints
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Document Highlights
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
			local hi_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = hi_group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = hi_group,
				callback = vim.lsp.buf.clear_references,
			})
		end

		-- Inlay Hints
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
	callback = function(event)
		vim.lsp.buf.clear_references()
		vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event.buf })
	end,
})

-- 5. Auto-import on completion (applies additionalTextEdits e.g. gopls imports)
vim.api.nvim_create_autocmd("CompleteDone", {
	callback = function()
		local item = vim.v.completed_item
		if not item or not item.user_data then
			return
		end
		local lsp_item = vim.tbl_get(item, "user_data", "nvim", "lsp", "completion_item")
		if not lsp_item then
			return
		end
		local edits = lsp_item.additionalTextEdits
		if edits and #edits > 0 then
			vim.lsp.util.apply_text_edits(edits, vim.api.nvim_get_current_buf(), "utf-8")
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params(0, "utf-16")
		params.context = { only = { "source.organizeImports" } }

		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)

		for _, res in pairs(result or {}) do
			for _, action in pairs(res.result or {}) do
				if action.edit then
					vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
				elseif type(action.command) == "table" then
					vim.lsp.buf.execute_command(action.command)
				end
			end
		end

		vim.lsp.buf.format({ async = false })
	end,
})

-- 6. Diagnostics UI
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = { spacing = 4, prefix = "●" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
})
-- Auto reload files changed outside current buffer
vim.o.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	pattern = "*",
	command = "if mode() != 'c' | checktime | endif",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	pattern = "*",
	callback = function()
		vim.cmd('echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None')

		local bufnr = vim.api.nvim_get_current_buf()
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		if #clients == 0 then
			return
		end

		for _, client in ipairs(clients) do
			vim.lsp.buf_detach_client(bufnr, client.id)
			vim.lsp.buf_attach_client(bufnr, client.id)
		end
	end,
})
