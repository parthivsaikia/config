local CustomSnippets = {}

function CustomSnippets.new()
	return setmetatable({}, { __index = CustomSnippets })
end

function CustomSnippets:get_completions(context, callback)
	-- Grab the snippets we injected via your autocommand
	local snippets = vim.b[context.bufnr].snippets or {}
	local items = {}

	for _, snip in ipairs(snippets) do
		-- Evaluate the body if it's a function (time/date), otherwise use the string
		local body = type(snip.body) == "function" and snip.body() or snip.body

		table.insert(items, {
			label = snip.trigger,
			kind = vim.lsp.protocol.CompletionItemKind.Snippet,
			insertText = body,
			-- This tells Neovim to parse the $1, $2 variables using vim.snippet
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
			detail = "Custom Snippet",
		})
	end

	-- Return the completions to blink
	callback({
		is_incomplete_forward = false,
		is_incomplete_backward = false,
		items = items,
	})
end

return CustomSnippets
