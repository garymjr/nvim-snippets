local Config = require("snippets.config")
local Registry = require("snippets.registry")

---@class SnippetsUtil
local M = {}

---@type fun(filetype: string): boolean
function M.is_filetype_ignored(filetype)
	local ignored_filetypes = Config.ignored_filetypes
	return ignored_filetypes ~= nil and vim.tbl_contains(ignored_filetypes, filetype)
end

---@type fun(filetype: string): nil
function M.get_registered_snippets(filetype)
	local loaded = {}

	-- make sure we always load global snippets
	if Config.global_snippets then
		for _, g in ipairs(Config.global_snippets) do
			local is_ignored = M.is_filetype_ignored(g)
			local files = Registry[g]
			if not is_ignored and files and #files > 0 then
				for _, f in ipairs(files) do
					local snippets = vim.fn.json_decode(vim.fn.readfile(f))
					for _, s in pairs(snippets) do
						loaded[s.prefix] = {
							body = s.body,
							description = s.description,
						}
					end
				end
			end
		end
	end

	local files = Registry[filetype]
	local is_ignored = M.is_filetype_ignored(filetype)

	if not is_ignored and files and #files > 0 then
		for _, f in ipairs(files) do
			local snippets = vim.fn.json_decode(vim.fn.readfile(f))
			for _, s in pairs(snippets) do
				loaded[s.prefix] = {
					body = s.body,
					description = s.description,
				}
			end
		end
	end

	require("snippets").load_snippets(loaded)
end

return M
