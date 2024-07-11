--- *NvimSnippets* Add custom snippet support to `vim.snippet`

--- @class __snippets.Snippet : {prefix: string, body: string|string[], description?: string}

local Snippets = {}
local H = {}

---@param opts? table  -- Make a better type for this
function snippets.setup(opts)
	if snippets.config.get_option "create_cmp_source" then
		snippets.utils.register_cmp_source()
	end
end

---
-- Module setup
--
--- @param config __snippets.Config Configuration options to be applied
function Snippets.setup(config)
	_G.Snippets = Snippets

	H.apply_config(config)
	H.load_friendly_snippets()
	H.register_snippets()
end

---
-- Module config
--
--- @class __snippets.Config
Snippets.config = {
	--- List of filetypes to ignore for snippet processing.
	--- @type string[]
	ignored_filetypes = {},

	--- Table mapping filetypes to arrays of extended snippets.
	--- @type table<string, string[]>
	extended_filetypes = {},

	--- List of global snippets available to all filetypes.
	--- @type string[]
	global_snippets = { "all" },

	--- List of paths to search for snippet files.
	--- @type string[]
	search_paths = { vim.fn.stdpath "config" .. "/snippets" },
}

---
-- Clears the cache for a specific filetype or all filetypes.
-- If a specific `filetype` is provided, clears the cache entry for that `filetype`.
-- If `filetype` is `nil`, clears the entire cache.
--
--- @param filetype? string Specific filetype to clear the cache for.
function Snippets.clear_cache(filetype)
	if filetype ~= nil then
		H.cache[filetype] = nil
	else
		H.cache = {}
	end
end

---
-- Returns the value associated with the given `key` in the configuration table,
-- or `fallback` if the `key` is not found or its value is falsy.
--
--- @param key string Key of configuration option.
--- @param fallback any Value to use if `key` is not found or falsey.
--- @return any
function Snippets.get_option(key, fallback)
	return Snippets.config[key] or fallback
end

---
-- Sets the value associated with the given `key` in the configuration table to `val`.
--
--- @param key string Key of configuration option
--- @param val any Value to apply to the configuration `key`
function Snippets.set_option(key, val)
	Snippets.config[key] = val
end

---
-- Retrieves snippets for the specified `filetype`, caching them for future use.
-- If snippets for `filetype` are cached, loads them from cache; otherwise, retrieves and caches them.
-- Ignores the `filetype` if it is configured to be ignored.
--
--- @param filetype string The specific filetype for which snippets are to be loaded.
--- @return table<string, __snippets.Snippet>|nil
function Snippets.load_snippets_for_ft(filetype)
	if H.cache[filetype] then
		H.loaded_snippets = H.cache[filetype]
	end

	if H.is_filetype_ignored(filetype) then
		return
	end

	H.loaded_snippets = Snippets.get_snippets(filetype)
	H.cache[filetype] = vim.deepcopy(H.loaded_snippets)

	return H.loaded_snippets
end

---
-- Combines snippets from three sources: snippets specific to the `filetype`,
-- extended snippets associated with the `filetype` and its extended filetypes,
-- and global snippets applicable to all filetypes.
--
--- @param filetype string The specific filetype for which snippets are to be retrieved.
--- @return table<string, __snippets.Snippet>
function Snippets.get_snippets(filetype)
	return vim.tbl_deep_extend(
		"force",
		{},
		H.get_snippets_for_ft(filetype),
		H.get_extended_snippets(filetype),
		H.get_global_snippets()
	)
end

---
-- Returns a table containing all snippets currently loaded.
--
--- @return table<string, __snippets.Snippet>
function Snippets.get_loaded_snippets()
	return H.loaded_snippets
end

--- Cached snippets for each loaded language
--- @class __snippets.Cache : table<string, table<string, __snippets.Snippet>>
H.cache = {}

--- Loaded snippets
--- @class __snippets.LoadedSnippets : table<string, table<string, Snippet>>
H.loaded_snippets = {}

--- Registry of all available filetypes and snippet files
--- @class __snippets.Registry : table<string, string[]>
H.registry = {}

--- Builtin variables to use for variable expansion.
H.builtin_vars = {
	lazy = {
		TM_FILENAME = function()
			return vim.fn.expand "%:t"
		end,
		TM_FILENAME_BASE = function()
			return vim.fn.expand "%:t:s?\\.[^\\.]\\+$??"
		end,
		TM_DIRECTORY = function()
			return vim.fn.expand "%:p:h"
		end,
		TM_FILEPATH = function()
			return vim.fn.expand "%:p"
		end,
		CLIPBOARD = function()
			return vim.fn.getreg(vim.v.register, true)
		end,
		CURRENT_YEAR = function()
			return os.date "%Y"
		end,
		CURRENT_YEAR_SHORT = function()
			return os.date "%y"
		end,
		CURRENT_MONTH = function()
			return os.date "%m"
		end,
		CURRENT_MONTH_NAME = function()
			return os.date "%B"
		end,
		CURRENT_MONTH_NAME_SHORT = function()
			return os.date "%b"
		end,
		CURRENT_DATE = function()
			return os.date "%d"
		end,
		CURRENT_DAY_NAME = function()
			return os.date "%A"
		end,
		CURRENT_DAY_NAME_SHORT = function()
			return os.date "%a"
		end,
		CURRENT_HOUR = function()
			return os.date "%H"
		end,
		CURRENT_MINUTE = function()
			return os.date "%M"
		end,
		CURRENT_SECOND = function()
			return os.date "%S"
		end,
		CURRENT_SECONDS_UNIX = function()
			return tostring(os.time())
		end,
		RELATIVE_FILEPATH = function()
			return H.buf_to_ws_part()[2]
		end,
		WORKSPACE_FOLDER = function()
			return H.buf_to_ws_part()[1]
		end,
		WORKSPACE_NAME = function()
			local parts = vim.split(H.buf_to_ws_part()[1] or "", "[\\/]")
			return parts[#parts]
		end,
	},
	eager = {},
}

---
-- Determines whether the specified `filetype` is included in the list of ignored
-- filetypes.
--
--- @param filetype string Filetype to check whether or not it is ignored.
--- @return boolean
function H.is_filetype_ignored(filetype)
	local ignored_filetypes = Snippets.get_option("ignored_filetypes", {})
	return vim.tbl_contains(ignored_filetypes, filetype)
end

---
-- Determines whether the specified `filetype` is included in the list of extended filetypes
-- retrieved from the Snippets configuration.
--
--- @param filetype string The filetype to check.
--- @return boolean
function H.is_filetype_extended(filetype)
	if vim.tbl_contains(Snippets.get_option("extended_filetypes", {}), filetype) then
		return true
	end
	return false
end

---
-- Opens the file at the given `path` in read mode, reads its entire content,
-- and returns the content as a string. If the file cannot be opened or read,
-- `nil` is returned.
--
--- @param path string File path to read.
--- @return string|nil
function H.read_file(path)
	local file = io.open(path, "r")
	if not file then
		return
	end
	local content = file:read "*a"
	file:close()
	return content
end

---
-- Converts the given `snippet` into one or more normalized snippets,
-- ensuring consistent structure for prefix, body, and description fields.
--
--- @param snippet {body: string|string[], description?: string, prefix?: string|string[]} The snippet to be normalized.
--- @param fallback string The fallback value to use for optional `prefix` and `description` fields if not provided in `snippet`.
--- @return table<string, __snippets.Snippet>
function H.read_snippet(snippet, fallback)
	local snippets = {}
	local prefix = snippet.prefix or fallback
	local description = snippet.description or fallback
	local body = snippet.body
	if type(prefix) == "table" then
		for _, p in ipairs(prefix) do
			snippets[p] = {
				prefix = p,
				body = body,
				description = description,
			}
		end
	else
		snippets[prefix] = {
			prefix = prefix,
			body = body,
			description = description,
		}
	end
	return snippets
end

---
-- Loads and processes snippets from registered snippet files associated with the specified `filetype`.
-- Snippets are read from each file, parsed from JSON format, normalized, and merged into a single table.
--
--- @param filetype string The specific filetype for which snippets are to be retrieved.
--- @return table<string, __snippets.Snippet>
function H.get_snippets_for_ft(filetype)
	local loaded_snippets = {}
	local files = H.registry[filetype]
	if not files then
		return loaded_snippets
	end

	if type(files) == "table" then
		for _, f in ipairs(files) do
			local contents = H.read_file(f)
			if contents then
				local snippets = vim.json.decode(contents)
				for _, key in ipairs(vim.tbl_keys(snippets)) do
					local snippet = H.read_snippet(snippets[key], key)
					loaded_snippets = vim.tbl_deep_extend("force", {}, loaded_snippets, snippet)
				end
			end
		end
	else
		local contents = H.read_file(files)
		if contents then
			local snippets = vim.json.decode(contents)
			for _, key in ipairs(vim.tbl_keys(snippets)) do
				local snippet = H.read_snippet(snippets[key], key)
				loaded_snippets = vim.tbl_deep_extend("force", {}, loaded_snippets, snippet)
			end
		end
	end

	return loaded_snippets
end

---
-- Loads and combines snippets for the specified `filetype` and its recursively defined extended filetypes,
-- merging them into a single table of loaded snippets.
--
--- @param filetype string The specific filetype for which extended snippets are to be retrieved.
--- @return table<string, __snippets.Snippet>
function H.get_extended_snippets(filetype)
	local loaded_snippets = {}
	if not filetype then
		return loaded_snippets
	end

	local extended_snippets = Snippets.get_option("extended_filetypes", {})[filetype] or {}
	for _, ft in ipairs(extended_snippets) do
		if H.is_filetype_extended(ft) then
			loaded_snippets = vim.tbl_deep_extend("force", {}, loaded_snippets, H.get_extended_snippets(ft))
		else
			loaded_snippets = vim.tbl_deep_extend("force", {}, loaded_snippets, H.get_snippets_for_ft(ft))
		end
	end
	return loaded_snippets
end

---
-- Loads and combines global snippets defined in the configuration,
-- including snippets from extended filetypes if applicable, into a single table of loaded snippets.
--
--- @return table<string, __snippets.Snippet>
function H.get_global_snippets()
	local loaded_snippets = {}
	local global_snippets = Snippets.get_option("global_snippets", {})
	for _, ft in ipairs(global_snippets) do
		if H.is_filetype_extended(ft) then
			loaded_snippets = vim.tbl_deep_extend("force", {}, loaded_snippets, H.get_extended_snippets(ft))
		else
			loaded_snippets = vim.tbl_deep_extend("force", {}, loaded_snippets, H.get_snippets_for_ft(ft))
		end
	end
	return loaded_snippets
end

---
-- Merges the provided `config` object with the current configuration,
-- ensuring that existing configuration values are overwritten by new ones if specified.
--
--- @param config __snippets.Config
function H.apply_config(config)
	Snippets.config = vim.tbl_deep_extend("force", {}, Snippets.config, config or {})
end

---
-- Updates the search paths for snippet files by adding any paths containing "friendly_snippets"
-- found within Neovim's runtime paths.
function H.load_friendly_snippets()
	local search_paths = Snippets.get_option("search_paths", {})
	for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
		if string.match(path, "friendly.snippets") then
			table.insert(search_paths, path)
		end
	end
	Snippets.set_option("search_paths", search_paths)
end

function H.register_snippets()
	local search_paths = Snippets.get_option("search_paths", {})

	for _, path in ipairs(search_paths) do
		local files = H.load_package_json(path) or H.scan_for_snippets(path)
		for ft, file in pairs(files) do
			local key
			if type(ft) == "number" then
				key = vim.fn.fnamemodify(files[ft], ":t:r")
			else
				key = ft
			end

			if not key then
				return
			end

			Snippets.registry[key] = Snippets.registry[key] or {}
			if type(file) == "table" then
				vim.list_extend(Snippets.registry[key], file)
			else
				table.insert(Snippets.registry[key], file)
			end
		end
	end
end

---
-- Reads and parses the `package.json` file to extract snippet information,
-- organizing them by language and their respective snippet file paths.
--
--- @param path string The path to the directory containing the package.json file.
--- @return table<string, string[]>|nil
function H.load_package_json(path)
	local file = path .. "/package.json"
	local data = H.read_file(file)

	if not data then
		return
	end

	local pkg = vim.json.decode(data)
	---@type {path: string, language: string|string[]}[]
	local snippets = vim.tbl_get(pkg, "contributes", "snippets")

	if not snippets then
		return
	end

	local ret = {} ---@type table<string, string[]>
	for _, s in ipairs(snippets) do
		local langs = s.language or {}
		langs = type(langs) == "string" and { langs } or langs
		---@cast langs string[]
		for _, lang in ipairs(langs) do
			ret[lang] = ret[lang] or {}
			table.insert(ret[lang], vim.fs.normalize(vim.fs.joinpath(path, s.path)))
		end
	end
	return ret
end

---
-- Traverse the directory specified by `dir`, recursively searching for snippet files,
-- adding found JSON files to the `result` table under their respective directories.
--
--- @param dir string The directory path to scan for snippet files.
--- @param result? table<string, string[]> A table to store the results of the scan.
--- @return table<string, string[]>
function H.scan_for_snippets(dir, result)
	result = result or {}

	local stat = vim.uv.fs_stat(dir)
	if not stat then
		return result
	end

	if stat.type == "directory" then
		local req = vim.uv.fs_scandir(dir)
		if not req then
			return result
		end

		local function iter()
			return vim.uv.fs_scandir_next(req)
		end

		for name, ftype in iter do
			local path = string.format("%s/%s", dir, name)

			if ftype == "directory" then
				result[name] = H.scan_for_snippets(path, result[name] or {})
			else
				H.scan_for_snippets(path, result)
			end
		end
	elseif stat.type == "file" then
		local name = vim.fn.fnamemodify(dir, ":t")

		if name:match "%.json$" then
			table.insert(result, dir)
		end
	elseif stat.type == "link" then
		local target = vim.uv.fs_readlink(dir)

		if target then
			H.scan_for_snippets(target, result)
		end
	end

	return result
end

---
-- Attempts to parse the provided `input` string using the LSP snippet grammar parser.
-- If parsing is successful, returns the parsed snippet data; otherwise, returns `nil`.
--
--- @param input string The snippet input string to parse.
--- @return vim.snippet.Node<vim.snippet.SnippetData>|nil
function H.safe_parse(input)
	local safe, parsed = pcall(vim.lsp._snippet_grammar.parse, input)
	if not safe then
		return nil
	end
	return parsed
end

--- @param input string
function H.expand_vars(input)
	local lazy_vars = Snippets.utils.builtin_vars.lazy
	local eager_vars = Snippets.utils.builtin_vars.eager or {}

	local resolved_snippet = input
	local parsed_snippet = H.safe_parse(input)
	if not parsed_snippet then
		return input
	end

	for _, child in ipairs(parsed_snippet.data.children) do
		local type, data = child.type, child.data
		if type == vim.lsp._snippet_grammar.NodeType.Variable then
			if eager_vars[data.name] then
				resolved_snippet = resolved_snippet:gsub("%$[{]?(" .. data.name .. ")[}]?", eager_vars[data.name])
			elseif lazy_vars[data.name] then
				resolved_snippet = resolved_snippet:gsub("%$[{]?(" .. data.name .. ")[}]?", lazy_vars[data.name]())
			end
		end
	end

	return resolved_snippet
end

--- @param snippet string
function H.preview(snippet)
	local parse = H.safe_parse(utils.expand_vars(snippet))
	return parse and tostring(parse) or snippet
end

---
-- Checks if the workspace parts are already stored in the buffer-local variable "LSP_WORSKPACE_PARTS".
-- If not found, attempts to derive the workspace parts based on LSP workspace folders or falls back to the file path.
--
--- @return string[]
function H.buf_to_ws_part()
	local LSP_WORSKPACE_PARTS = "LSP_WORSKPACE_PARTS"
	local ok, ws_parts = pcall(vim.api.nvim_buf_get_var, 0, LSP_WORSKPACE_PARTS)
	if not ok then
		local file_path = vim.fn.expand "%:p"

		for _, ws in pairs(vim.lsp.buf.list_workspace_folders()) do
			if file_path:find(ws, 1, true) == 1 then
				ws_parts = { ws, file_path:sub(#ws + 2, -1) }
				break
			end
		end
		-- If it can't be extracted from lsp, then we use the file path
		if not ok and not ws_parts then
			ws_parts = { vim.fn.expand "%:p:h", vim.fn.expand "%:p:t" }
		end
		vim.api.nvim_buf_set_var(0, LSP_WORSKPACE_PARTS, ws_parts)
	end
	return ws_parts
end

---
-- Computes the timezone offset based on the difference between UTC and local time,
-- formatted as a string in the format ±HHMM (e.g., +0530, -0800).
--
--- @param ts number A timestamp (in seconds since the epoch) for which to calculate the timezone offset.
--- @return string
function H.get_timezone_offset(ts)
	local utcdate = os.date("!*t", ts)
	local localdate = os.date("*t", ts)
	localdate.isdst = false -- this is the trick
  --- @diagnostic disable-next-line
	local diff = os.difftime(os.time(localdate), os.time(utcdate))
	local h, m = math.modf(diff / 3600)
	return string.format("%+.4d", 100 * h + 60 * m)
end

return Snippets
