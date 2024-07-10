local cmp = require("cmp")
local utils = require("snippets.utils")

local source = {}

source.new = function()
	return setmetatable({}, { __index = source })
end

source.get_keyword_pattern = function()
	return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)"
end

function source:is_available()
	local ok, _ = pcall(require, "snippets")
	return ok
end

function source:get_debug_name()
	return "snippets"
end

function source:complete(_, callback)
	local loaded_snippets = Snippets.load_snippets_for_ft(vim.bo.filetype)

	if loaded_snippets == nil then
		return
	end

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
					insertTextFormat = cmp.lsp.InsertTextFormat.Snippet,
					insertTextMode = cmp.lsp.InsertTextMode.AdjustIndentation,
					insertText = body,
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
				insertTextFormat = cmp.lsp.InsertTextFormat.Snippet,
				insertTextMode = cmp.lsp.InsertTextMode.AdjustIndentation,
				insertText = body,
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
	-- highlight code block
	local preview = utils.preview(completion_item.data.body)
	if require("snippets.config").get_option("highlight_preview", false) then
		preview = string.format("```%s\n%s\n```", vim.bo.filetype, preview)
	end
	completion_item.documentation = {
		kind = cmp.lsp.MarkupKind.Markdown,
		value = preview,
	}

	completion_item.insertText = Snippets.utils.expand_vars(completion_item.data.body)
	callback(completion_item)
end

function source:execute(completion_item, callback)
	callback(completion_item)
end

local function register()
	cmp.register_source("snippets", source)
end

return { register = register }
