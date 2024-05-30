local snippets = {}

snippets.config = require("snippets.config")
snippets.utils = require("snippets.utils")

Snippets = snippets

---@class Snippet
---@field prefix string
---@field body string
---@field description? string

--- Cached snippets for each language loaded
---@private
---@type table<string, table<string, Snippet>>
snippets.cache = {}

---@private
---@type string|nil
snippets.active_filetype = nil

---@private
---@type table<string, table<string, Snippet>>
snippets.loaded_snippets = {}

---@private
---@type table<string, string|string[]>
snippets.registry = {}

---@param filetype string|nil
function snippets.clear_cache(filetype)
	if filetype ~= nil then
		snippets.cache[filetype] = nil
	else
		snippets.cache = {}
	end
end

---@type fun(filetype?: string): table<string, table>|nil
function snippets.load_snippets_for_ft(filetype)
	snippets.active_filetype = filetype
	if snippets.cache[filetype] then
		snippets.loaded_snippets = snippets.cache[filetype]
		return snippets.loaded_snippets
	end

	if snippets.utils.is_filetype_ignored(filetype) then
		return nil
	end

	local global_snippets = snippets.utils.get_global_snippets()
	local extended_snippets = snippets.utils.get_extended_snippets(filetype)
	local ft_snippets = snippets.utils.get_snippets_for_ft(filetype)
	snippets.loaded_snippets = vim.tbl_deep_extend("force", {}, global_snippets, extended_snippets, ft_snippets)
	snippets.cache[filetype] = vim.deepcopy(snippets.loaded_snippets)

	return snippets.loaded_snippets
end

---@return table<string, Snippet>
function snippets.get_loaded_snippets()
	return snippets.loaded_snippets
end

---@param opts? table  -- Make a better type for this
function snippets.setup(opts)
	snippets.config.new(opts)
	if snippets.config.get_option("friendly_snippets") then
		snippets.utils.load_friendly_snippets()
	end

	snippets.utils.register_snippets()

	if snippets.config.get_option("create_autocmd") then
		snippets.utils.create_autocmd()
	end

	if snippets.config.get_option("create_cmp_source") then
		snippets.utils.register_cmp_source()
	end
end

return snippets
