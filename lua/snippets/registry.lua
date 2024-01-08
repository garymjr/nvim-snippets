---@class SnippetsRegistry
local M = {
	---@private
	---@type table<string, string[]>
	registry = {},
}

setmetatable(M, {
	__index = function(_, key)
		return M.registry[key]
	end,
})

return M
