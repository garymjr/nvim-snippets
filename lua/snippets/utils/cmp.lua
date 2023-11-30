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
		table.insert(response, {
			label = loaded_snippets[key].prefix,
			kind = cmp.lsp.CompletionItemKind.Snippet,
			insertText = loaded_snippets[key].prefix,
			data = {
				prefix = loaded_snippets[key].prefix,
				body = loaded_snippets[key].body,
			},
		})
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
