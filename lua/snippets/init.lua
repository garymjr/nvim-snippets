local Snippets = {}
local M = {}

---@type fun(opts?: SnippetsOptions)
function M.setup(opts)
	require("snippets.config").setup(opts)
end

return M

H.config = {
	--- Should an autocmd be created to load snippets automatically?
	---@type boolean
	create_autocmd = false,
	--- A list of filetypes to ignore snippets for
	---@type table|nil
	ignored_filetypes = nil,
	--- A table of filetypes to apply additional snippets for
	--- example: { typescript = { "javascript" } }
	---@type table|nil
	extended_filetypes = nil,
	--- A table of global snippets to load for all filetypes
	---@type table|nil
	global_snippets = { "all" },
	--- Paths to search for snippets
	---@type string[]
	search_paths = { vim.fn.stdpath("config") .. "/snippets" },
}

function Snippets.setup(opts) end

Snippets.config = require("snippets.config")
Snippets.utils = require("snippets.utils")

---@class Snippet
---@field prefix string
---@field body string
---@field description string

---@type table<string, Snippet>
H.cached_snippets = {}

---@type table<string, string|string[]>
H.registry = {}

---@type table<string, string>
H.prefix_lookup = {}

---@type fun(filetype?: string): table<string, table>|nil
function Snippets.load_snippets_for_ft(filetype)
	if Snippets.utils.is_filetype_ignored(filetype) then
		return nil
	end

	local global_snippets = Snippets.utils.get_global_snippets()
	local extended_snippets = Snippets.utils.get_extended_snippets(filetype)
	local ft_snippets = Snippets.utils.get_snippets_for_ft(filetype)
	Snippets.loaded_snippets = vim.tbl_deep_extend("force", {}, global_snippets, extended_snippets, ft_snippets)

	for key, snippet in pairs(Snippets.loaded_snippets) do
		Snippets.prefix_lookup[snippet.prefix] = key
	end
	return Snippets.loaded_snippets
end

---@return table<string, Snippet>
function Snippets.get_loaded_snippets()
	return Snippets.loaded_snippets
end

return Snippets
