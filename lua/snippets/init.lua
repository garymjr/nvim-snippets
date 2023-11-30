local snippets = {}

snippets.config = require("snippets.config")
snippets.utils = require("snippets.utils")

---@private
---@type table<string, table>
snippets.loaded_snippets = {}

---@type fun(filetype?: string): table<string, table>|nil
function snippets.load_snippets_for_ft(filetype)
	if snippets.utils.is_filetype_ignored(filetype) then
		return nil
	end

	local global_snippets = snippets.utils.get_global_snippets()
	local extended_snippets = snippets.utils.get_extended_snippets(filetype)
	local ft_snippets = snippets.utils.get_snippets_for_ft(filetype)
	snippets.loaded_snippets = vim.tbl_deep_extend("force", {}, global_snippets, extended_snippets, ft_snippets)
	return snippets.loaded_snippets
end

---@return table<string, table>
function snippets.get_loaded_snippets()
	return snippets.loaded_snippets
end

function snippets.create_autocmd()
	if not snippets.config.get_option("create_autocmd") then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("snippets_ft_detect", { clear = true }),
		pattern = "*",
		callback = function()
			snippets.load_snippets_for_ft(vim.bo.filetype)
		end,
	})
end

function snippets.register_cmp_source()
	require("snippets.utils.cmp").register()
end

---@param opts? table  -- Make a better type for this
function snippets.setup(opts)
	local defaults = snippets.config.load_defaults()
	snippets.config = vim.tbl_extend("force", {}, defaults, opts or {})

	if snippets.config.get_option("create_autocmd") then
		snippets.create_autocmd()
	end

	if snippets.config.get_option("create_cmp_source") then
		snippets.register_cmp_source()
	end
end

return snippets
