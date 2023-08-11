local M = {}

M.config = {
	definition_identifier = "gd",
	template = "%s ref:%s",
}

M.references_available = false
M.reference_count = 0
M.definition_available = false

local function debounce(func, delay)
	local timer_id = nil
	return function(...)
		if timer_id then
			vim.fn.timer_stop(timer_id)
		end
		local args = { ... }
		timer_id = vim.fn.timer_start(delay, function()
			func(unpack(args))
		end)
	end
end

local function get_current_context()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	return bufnr, { line = cursor[1] - 1, character = cursor[2] }, bufname
end

local function lsp_request(method, params, callback)
	local bufnr, position, uri = get_current_context()
	params.textDocument = { uri = uri }
	params.position = position
	vim.lsp.buf_request(bufnr, method, params, callback)
end

local function references()
	lsp_request("textDocument/references", {
		context = { includeDeclaration = true },
	}, function(err, result, _, _)
		if err then
			error(tostring(err))
		end

		if not result or vim.tbl_count(result) == 0 then
			M.references_available = false
			M.reference_count = 0
			return false
		end

		M.references_available = true
		M.reference_count = vim.tbl_count(result) - 1
		return true
	end)
end

local function definition()
	lsp_request("textDocument/definition", {}, function(err, result, _, _)
		if err then
			error(tostring(err))
		end

		if not result or vim.tbl_count(result) == 0 then
			M.definition_available = false
			return false
		end

		M.definition_available = true
		return true
	end)
end

local debounced_references = debounce(references, 100)
local debounced_definition = debounce(definition, 100)

M.statusline = function()
	debounced_references()
	debounced_definition()

	local definition_status = ""

	if M.definition_available then
		definition_status = M.config.definition_identifier
	end

	return string.format(M.config.template, definition_status, M.reference_count)
end

M.setup = function(options)
	if options == nil then
		options = {}
	end

	-- merge user supplied options with defaults..
	for k, v in pairs(options) do
		M.config[k] = v
	end
end

return M
