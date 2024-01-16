local Util = require("snippets.util")

---@class SnippetsConfig: SnippetsOptions
local M = {
	---@type table<string, string[]>
	registry = {},
}

---@class SnippetsOptions
local defaults = {
	--- Should filetype snippets be loaded automatically? If using snippets engine
	--- this can be left `false`.
	---@type boolean
	autoload = false,
	--- A list of filetypes for which snippets should not be loaded
	---@type table|nil
	ignored_filetypes = nil,
	--- A table of snippets to load for all filetypes
	---@type table|nil
	global_snippets = nil,
	--- The path to the snippets directory
	---@type string
	snippets_path = vim.fn.stdpath("config") .. "/snippets",
}

---@type SnippetsOptions
local options

---@type fun(opts?: SnippetsOptions)
function M.setup(opts)
	options = vim.tbl_extend("force", defaults, opts or {}) or {}

	if options.autoload then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			group = vim.api.nvim_create_augroup("Sippets", { clear = true }),
			callback = function(args)
				Util.get_registered_snippets(args.match)
			end,
		})
	end
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			options = vim.deepcopy(defaults)
		end
		return options[key]
	end,
})

return M
