local config = {}

---@class snippets.config.Options : snippets.config.DefaultOptions
local C = {}

---@class snippets.config.DefaultOptions
local defaults = {
	--- Should an autocmd be created to load snippets automatically?
	---@type boolean
	create_autocmd = false,
	--- Should the cmp source be created and registered?
	--- The created source name is "snippets"
	---@type boolean
	create_cmp_source = true,
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
	--- The path to the snippets folder
	---@type string
	snippets_path = vim.fn.stdpath("config") .. "/snippets",
}

---@param opts? snippets.config.Options
---@return snippets.config.Options
function config.new(opts)
	C = vim.tbl_extend("force", {}, defaults, opts or {})
	return C
end

---@return snippets.config.DefaultOptions
function config.load_defaults()
	return defaults
end

---@param option string
---@param defaultValue? any
---@return any
function config.get_option(option, defaultValue)
	return C[option] or defaultValue
end

return config
