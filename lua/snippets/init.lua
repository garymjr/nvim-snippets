local snippets = {}

snippets.config = require("snippets.config")
snippets.utils = require("snippets.utils")

Snippets = snippets

---@class Snippet
---@field prefix string
---@field body string

---@private
---@type table<string, Snippet>
snippets.loaded_snippets = {}

---@private
---@type table<string, string|string[]>
snippets.registry = {}

---@private
---@type table<string, string>
snippets.prefix_lookup = {}

---@type fun(filetype?: string): table<string, table>|nil
function snippets.load_snippets_for_ft(filetype)
	if snippets.utils.is_filetype_ignored(filetype) then
		return nil
	end

	local global_snippets = snippets.utils.get_global_snippets()
	local extended_snippets = snippets.utils.get_extended_snippets(filetype)
	local ft_snippets = snippets.utils.get_snippets_for_ft(filetype)
	snippets.loaded_snippets = vim.tbl_deep_extend("force", {}, global_snippets, extended_snippets, ft_snippets)

	for key, snippet in pairs(snippets.loaded_snippets) do
		snippets.prefix_lookup[snippet.prefix] = key
	end
	return snippets.loaded_snippets
end

---@return table<string, Snippet>
function snippets.get_loaded_snippets()
	return snippets.loaded_snippets
end

---@param opts? table  -- Make a better type for this
function snippets.setup(opts)
	snippets.config.new(opts)
	local has_friendly_snippets, path = snippets.utils.has_friendly_snippets()
	if has_friendly_snippets then
		local search_paths = snippets.config.get_option("search_paths", {})
		table.insert(search_paths, path)
		snippets.config.set_option("search_paths", search_paths)
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
