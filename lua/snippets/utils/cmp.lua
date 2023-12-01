local cmp = require("cmp")

local source = {}

local cache = {}

source.new = function()
	return setmetatable({}, { __index = source })
end

source.clear_cache = function()
	cache = {}
end

function source:is_available()
	local ok, _ = pcall(require, "snippets")
	return ok
end

function source:get_debug_name()
	return "snippets"
end

function source:complete(_, callback)
	if cache[vim.bo.filetype] == nil then
		cache[vim.bo.filetype] = Snippets.load_snippets_for_ft(vim.bo.filetype)
	end

	local loaded_snippets = cache[vim.bo.filetype]

	local response = {}

	for key in pairs(loaded_snippets) do
		local snippet = loaded_snippets[key]
		local body
		if type(snippet.body) == "table" then
			body = table.concat(snippet.body, "\n")
		else
			body = snippet.body
		end

		local prefix = loaded_snippets[key].prefix
		if type(prefix) == "table" then
			for _, p in ipairs(prefix) do
				table.insert(response, {
					label = p,
					kind = cmp.lsp.CompletionItemKind.Snippet,
					insertText = p,
					data = {
						prefix = p,
						body = body,
					},
				})
			end
		else
			table.insert(response, {
				label = prefix,
				kind = cmp.lsp.CompletionItemKind.Snippet,
				insertText = prefix,
				data = {
					prefix = prefix,
					body = body,
				},
			})
		end
	end
	callback(response)
end

function source:resolve(completion_item, callback)
	completion_item.documentation = {
		kind = cmp.lsp.MarkupKind.Markdown,
		value = completion_item.data.body,
	}
	callback(completion_item)
end

function source:execute(completion_item, callback)
	callback(completion_item)
	local cursor = vim.api.nvim_win_get_cursor(0)
	cursor[1] = cursor[1] - 1

	vim.api.nvim_buf_set_text(0, cursor[1], cursor[2] - #completion_item.data.prefix, cursor[1], cursor[2], { "" })
	---@diagnostic disable-next-line: param-type-mismatch
	vim.snippet.expand(completion_item.data.body)
end

local function register()
	cmp.register_source("snippets", source)
end

return { register = register }
