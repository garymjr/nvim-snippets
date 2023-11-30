local utils = {}

utils.cmp = require("snippets.utils.cmp")

---@type fun(filetype: string): boolean
function utils.is_filetype_ignored(filetype)
	local ignored_filetypes = Snippets.config.get_option("ignored_filetypes", {})
	return vim.tbl_contains(ignored_filetypes, filetype)
end

---@type fun(): string|nil
function utils.get_snippets_path()
	local path = Snippets.config.get_option("snippets_path")
	if not path then
		return nil
	end

	---@type string
	return vim.fn.expand(path, false, false)
end

---@type fun(): table<string, table>
function utils.get_global_snippets()
	local path = utils.get_snippets_path()
	if not path then
		return {}
	end

	local loaded = {}
	local global_snippets = Snippets.config.get_option("global_snippets", {})
	for _, snippet in ipairs(global_snippets) do
		local glob = path .. "/" .. snippet .. ".json"
		local files = vim.fn.glob(glob, true, true)
		if #files > 0 then
			for _, file in ipairs(files) do
				local snippets = vim.fn.json_decode(vim.fn.readfile(file))
				loaded = vim.tbl_deep_extend("force", {}, loaded, snippets) or loaded
			end
		end
	end
	return loaded
end

---@type fun(filetype?: string): table<string, table>
function utils.get_extended_snippets(filetype)
	local path = utils.get_snippets_path()
	if not path or not filetype then
		return {}
	end

	local loaded = {}
	local extended_snippets = Snippets.config.get_option("extended_filetypes", {})[filetype] or {}
	for _, snippet in ipairs(extended_snippets) do
		local glob = path .. "/" .. snippet .. ".json"
		local files = vim.fn.glob(glob, true, true)
		if #files > 0 then
			for _, file in ipairs(files) do
				local snippets = vim.fn.json_decode(vim.fn.readfile(file))
				loaded = vim.tbl_deep_extend("force", {}, loaded, snippets) or loaded
			end
		end
	end
	return loaded
end

---@type fun(filetype?: string): table<string, table>
function utils.get_snippets_for_ft(filetype)
	local path = utils.get_snippets_path()
	if utils.is_filetype_ignored(filetype) or not path or not filetype then
		return {}
	end

	local loaded = {}
	local glob = path .. "/" .. filetype .. ".json"
	local files = vim.fn.glob(glob, true, true)
	if #files > 0 then
		for _, file in ipairs(files) do
			local snippets = vim.fn.json_decode(vim.fn.readfile(file))
			loaded = vim.tbl_deep_extend("force", {}, loaded, snippets) or loaded
		end
	end
	return loaded
end

---@param prefix string|nil
function utils.find_snippet_prefix(prefix)
	for _, snippet in ipairs(Snippets.get_loaded_snippets()) do
		if snippet.prefix == prefix then
			return snippet
		end
	end
end

function utils.create_autocmd()
	if not Snippets.config.get_option("create_autocmd") then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("snippets_ft_detect", { clear = true }),
		pattern = "*",
		callback = function()
			Snippets.load_snippets_for_ft(vim.bo.filetype)
		end,
	})
end

function utils.register_cmp_source()
	utils.cmp.register()
end

return utils
