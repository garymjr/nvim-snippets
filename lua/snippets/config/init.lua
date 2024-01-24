local config = {}

---@class snippets.config.Options : snippets.config.DefaultOptions
local C = {}

---@class snippets.config.DefaultOptions
local defaults = {
	--- Should an autocmd be created to load snippets automatically?
	---@type boolean
	create_autocmd = false,
	--- Wrap the preview text in a markdown code block for highlighting?
	---@type boolean
	highlight_preview = true,
	--- Should the cmp source be created and registered?
	--- The created source name is "snippets"
	---@type boolean
	create_cmp_source = true,
	--- Should we try to load the friendly-snippets snippets?
	---@type boolean
	friendly_snippets = false,
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

---@type fun(opts?: snippets.config.Options): snippets.config.Options
function config.new(opts)
	C = vim.tbl_extend("force", {}, defaults, opts or {})
	return C
end

---@type fun(): snippets.config.DefaultOptions
function config.load_defaults()
	return defaults
end

---@type fun(option: string, defaultValue?: any): any
function config.get_option(option, defaultValue)
	return C[option] or defaultValue
end

---@type fun(option: string, value: any)
function config.set_option(option, value)
	C[option] = value
end

return config
