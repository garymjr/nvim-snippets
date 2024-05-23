-- credit to https://github.com/L3MON4D3 for these variables
-- see: https://github.com/L3MON4D3/LuaSnip/blob/master/lua/luasnip/util/_builtin_vars.lua

local builtin = {
	lazy = {},
}

function builtin.lazy.TM_FILENAME()
	return vim.fn.expand("%:t")
end

function builtin.lazy.TM_FILENAME_BASE()
	return vim.fn.expand("%:t:s?\\.[^\\.]\\+$??")
end

function builtin.lazy.TM_DIRECTORY()
	return vim.fn.expand("%:p:h")
end

function builtin.lazy.TM_FILEPATH()
	return vim.fn.expand("%:p")
end

function builtin.lazy.CLIPBOARD()
	return vim.fn.getreg('"', true)
end

local function buf_to_ws_part()
	local LSP_WORSKPACE_PARTS = "LSP_WORSKPACE_PARTS"
	local ok, ws_parts = pcall(vim.api.nvim_buf_get_var, 0, LSP_WORSKPACE_PARTS)
	if not ok then
		local file_path = vim.fn.expand("%:p")

		for _, ws in pairs(vim.lsp.buf.list_workspace_folders()) do
			if file_path:find(ws, 1, true) == 1 then
				ws_parts = { ws, file_path:sub(#ws + 2, -1) }
				break
			end
		end
		-- If it can't be extracted from lsp, then we use the file path
		if not ok and not ws_parts then
			ws_parts = { vim.fn.expand("%:p:h"), vim.fn.expand("%:p:t") }
		end
		vim.api.nvim_buf_set_var(0, LSP_WORSKPACE_PARTS, ws_parts)
	end
	return ws_parts
end

function builtin.lazy.RELATIVE_FILEPATH() -- The relative (to the opened workspace or folder) file path of the current document
	return buf_to_ws_part()[2]
end

function builtin.lazy.WORKSPACE_FOLDER() -- The path of the opened workspace or folder
	return buf_to_ws_part()[1]
end

function builtin.lazy.WORKSPACE_NAME() -- The name of the opened workspace or folder
	local parts = vim.split(buf_to_ws_part()[1] or "", "[\\/]")
	return parts[#parts]
end

function builtin.lazy.CURRENT_YEAR()
	return os.date("%Y")
end

function builtin.lazy.CURRENT_YEAR_SHORT()
	return os.date("%y")
end

function builtin.lazy.CURRENT_MONTH()
	return os.date("%m")
end

function builtin.lazy.CURRENT_MONTH_NAME()
	return os.date("%B")
end

function builtin.lazy.CURRENT_MONTH_NAME_SHORT()
	return os.date("%b")
end

function builtin.lazy.CURRENT_DATE()
	return os.date("%d")
end

function builtin.lazy.CURRENT_DAY_NAME()
	return os.date("%A")
end

function builtin.lazy.CURRENT_DAY_NAME_SHORT()
	return os.date("%a")
end

function builtin.lazy.CURRENT_HOUR()
	return os.date("%H")
end

function builtin.lazy.CURRENT_MINUTE()
	return os.date("%M")
end

function builtin.lazy.CURRENT_SECOND()
	return os.date("%S")
end

function builtin.lazy.CURRENT_SECONDS_UNIX()
	return tostring(os.time())
end

local function get_timezone_offset(ts)
	local utcdate = os.date("!*t", ts)
	local localdate = os.date("*t", ts)
	localdate.isdst = false -- this is the trick
	local diff = os.difftime(os.time(localdate), os.time(utcdate))
	local h, m = math.modf(diff / 3600)
	return string.format("%+.4d", 100 * h + 60 * m)
end

function builtin.lazy.CURRENT_TIMEZONE_OFFSET()
	return get_timezone_offset(os.time()):gsub("([+-])(%d%d)(%d%d)$", "%1%2:%3")
end

math.randomseed(os.time())

function builtin.lazy.RANDOM()
	return string.format("%06d", math.random(999999))
end

function builtin.lazy.RANDOM_HEX()
	return string.format("%06x", math.random(16777216)) --16^6
end

function builtin.lazy.UUID()
	local random = math.random
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	local out
	local function subs(c)
		local v = (((c == "x") and random(0, 15)) or random(8, 11))
		return string.format("%x", v)
	end

	out = template:gsub("[xy]", subs)
	return out
end

local _comments_cache = {}
local function buffer_comment_chars()
	local commentstring = vim.bo.commentstring
	if _comments_cache[commentstring] then
		return _comments_cache[commentstring]
	end
	local comments = { "//", "/*", "*/" }
	local placeholder = "%s"
	local index_placeholder = commentstring:find(vim.pesc(placeholder))
	if index_placeholder then
		index_placeholder = index_placeholder - 1
		if index_placeholder + #placeholder == #commentstring then
			comments[1] = vim.trim(commentstring:sub(1, -#placeholder - 1))
		else
			comments[2] = vim.trim(commentstring:sub(1, index_placeholder))
			comments[3] = vim.trim(commentstring:sub(index_placeholder + #placeholder + 1, -1))
		end
	end
	_comments_cache[commentstring] = comments
	return comments
end

function builtin.lazy.LINE_COMMENT()
	return buffer_comment_chars()[1]
end

function builtin.lazy.BLOCK_COMMENT_START()
	return buffer_comment_chars()[2]
end

function builtin.lazy.BLOCK_COMMENT_END()
	return buffer_comment_chars()[3]
end
