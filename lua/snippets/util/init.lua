local Config = require("snippets.config")
local Registry = require("snippets.registry")

---@class SnippetsUtil
local M = {}

---@type fun(filetype: string): boolean
function M.is_filetype_ignored(filetype)
	local ignored_filetypes = Config.ignored_filetypes
	return ignored_filetypes ~= nil and vim.tbl_contains(ignored_filetypes, filetype)
end

---@type fun(): nil
function M.load_snippets()
	local ft = vim.bo.filetype
	M.load_snippets_for_ft(ft)
end

---@type fun(filetype: string): table
function M.load_snippets_for_ft(filetype)
	local loaded = {}
	if M.is_filetype_ignored(filetype) then
		return loaded
	end

	local files = Registry[filetype]
	if not files then
		return loaded
	end

	for _, f in ipairs(files) do
		local snippets = vim.fn.json_decode(vim.fn.readfile(f))
		loaded = vim.tbl_deep_extend("force", loaded, snippets) or loaded
	end
end

return M
