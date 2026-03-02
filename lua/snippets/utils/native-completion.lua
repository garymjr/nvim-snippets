local utils = require("snippets.utils")

local function get_snippet_body(snippet)
	if type(snippet.body) == "table" then
		return table.concat(snippet.body, "\n")
	else
		return snippet.body
	end
end

local function snippet_to_complete_items(prefix, snippet, kind)
	local body = get_snippet_body(snippet)
	local preview = utils.preview(body)
	if require("snippets.config").get_option("highlight_preview", false) then
		preview = string.format("```%s\n%s\n```", vim.bo.filetype, preview)
	end
	local description = ""
	if snippet.description then
		local string_description = snippet.description
		if type(snippet.description) == "table" then
			string_description = table.concat(snippet.description, "\n")
		end
		description = string_description .. "\n\n"
	end
	local info = string.format("%s%s", description or "", preview)

	return {
		word = prefix,
		abbr = prefix .. "~",
		info = info,
		kind = kind,
		user_data = {
			nvim_snippet = true,
			prefix = prefix,
			body = body,
		},
		dup = 1,
		icase = 1,
	}
end

--- The function to register the global completion function and the autocmd to expand snippets on completion
--- @param kind string The completion item kind to use for native completion items
local function register(kind)
	--- Complete function for snippets
	--- @param findstart number 1 to find start position, 0 to find matches
	--- @param base string The text to match (empty on first call)
	--- @return number|table Column position on first call, list of matches on second call
	_G.nvim_snippets_complete = function(findstart, base)
		if findstart == 1 then
			-- First call: find the start of the completion
			local col = vim.api.nvim_win_get_cursor(0)[2]

			return col
		else
			local loaded_snippets = Snippets.load_snippets_for_ft(vim.bo.filetype)
			if loaded_snippets == nil then
				return {}
			end

			local response = {}
			for key in pairs(loaded_snippets) do
				local snippet = loaded_snippets[key]

				local prefix = snippet.prefix
				if type(prefix) == "table" then
					for _, p in ipairs(prefix) do
						table.insert(response, snippet_to_complete_items(p, snippet, kind))
					end
				else
					table.insert(response, snippet_to_complete_items(prefix, snippet, kind))
				end
			end
			return response
		end
	end

	vim.api.nvim_create_autocmd("CompleteDone", {
		group = vim.api.nvim_create_augroup("_nvim_snippet_complete", { clear = true }),
		callback = function()
			local completed = vim.v.completed_item
			local word = completed.word
			local reason = vim.v.event.reason

			if not word or reason ~= "accept" then
				return
			end

			if not completed.user_data or not completed.user_data.nvim_snippet then
				return
			end

			-- Get current line and cursor position
			local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_buf_set_text(0, lnum - 1, col - #word, lnum - 1, col, {})
			vim.snippet.expand(completed.user_data.body)
		end,
	})
end

return { register = register }
