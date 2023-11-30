local snippets = require("snippets")
local cmp = require("cmp")

local source = {}

---@alias lsp.CompletionResponse lsp.CompletionList|lsp.CompletionItem[]

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

---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(_, callback)
	if cache[vim.bo.filetype] == nil then
		cache[vim.bo.filetype] = snippets.load_snippets_for_ft(vim.bo.filetype)
	end

	local loaded_snippets = cache[vim.bo.filetype]

	---@type lsp.CompletionItem[]
	local response = {}

	for key in pairs(loaded_snippets) do
		table.insert(response, {
			label = loaded_snippets[key].label or key,
			kind = cmp.lsp.CompletionItemKind.Snippet,
			insertText = key,
			data = {
				word = key,
				body = loaded_snippets[key].body,
			},
		})
	end
	callback(response)
end

---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
	callback(completion_item)
	local cursor = vim.api.nvim_win_get_cursor(0)
	cursor[1] = cursor[1] - 1

	vim.api.nvim_buf_set_text(0, cursor[1], cursor[2] - #completion_item.data.word, cursor[1], cursor[2], { "" })
	---@diagnostic disable-next-line: param-type-mismatch
	vim.snippet.expand(completion_item.data.body)
end

local function register()
	cmp.register_source("snippets", source)
end

return { register = register }
