---@class SnippetsRegistry
local M = {
	---@private
	---@type table<string, string[]>
	extended_filetypes = {},
	---@private
	---@type table<string, table>
	registry = {},
}

---@type fun(source: string, target: string|string[])
function M.register_filetype(source, target)
	local extended = M.extended_filetypes[source] or {}
	if type(target) == "table" then
		extended = vim.tbl_deep_extend("force", M.extended_filetypes[source] or {}, target) or {}
	else
		table.insert(extended, target)
	end
	M.extended_filetypes[source] = extended
end

---@type fun(ft: string): string[]|nil
function M.get_extended_filetypes(ft)
	if M.extended_filetypes[ft] then
		return M.extended_filetypes[ft]
	end
end

setmetatable(M, {
	__index = function(_, key)
		return M.registry[key]
	end,
})

return M
