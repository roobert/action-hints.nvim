local M = {}

M.config = {
	template = {
		{ " ⊛", "StatuslineActionHintsDefinition" },
		{ " ↱%s", "StatuslineActionHintsReferences" },
	},
	use_virtual_text = false,
}

M.references_available = false
M.reference_count = 0
M.definition_available = false

local references_namespace = vim.api.nvim_create_namespace("references")
local last_virtual_text_line = nil

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

local function set_virtual_text(bufnr, line, chunks)
	if last_virtual_text_line then
		vim.api.nvim_buf_clear_namespace(
			bufnr,
			references_namespace,
			last_virtual_text_line,
			last_virtual_text_line + 1
		)
	end
	vim.api.nvim_buf_set_virtual_text(bufnr, references_namespace, line, chunks, {})
	last_virtual_text_line = line
end

local function supports_method(method)
	local clients = vim.lsp.buf_get_clients()
	for _, client in pairs(clients) do
		if client.server_capabilities[method] then
			return true
		end
	end
	return false
end

local function references()
	if not supports_method("referencesProvider") then
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local params = {
		textDocument = { uri = bufname },
		position = { line = cursor[1] - 1, character = cursor[2] },
		context = { includeDeclaration = true },
	}

	vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result, _, _)
		if err or not result then
			M.references_available = false
			M.reference_count = 0
			return false
		end

		if vim.tbl_count(result) > 0 then
			M.references_available = true
			M.reference_count = vim.tbl_count(result) - 1
			return true
		end

		M.references_available = false
		M.reference_count = 0
		return false
	end)
end

local function definition()
	if not supports_method("definitionProvider") then
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local params = {
		textDocument = { uri = bufname },
		position = { line = cursor[1] - 1, character = cursor[2] },
	}

	vim.lsp.buf_request(bufnr, "textDocument/definition", params, function(err, result, _, _)
		if err or not result then
			M.definition_available = false
			return false
		end

		if vim.tbl_count(result) > 0 then
			M.definition_available = true
			return true
		end

		M.definition_available = false
		return false
	end)
end

local debounced_references = debounce(references, 100)
local debounced_definition = debounce(definition, 100)

M.statusline = function()
	debounced_references()
	debounced_definition()

	local definition_status = M.definition_available and " ⊛" or ""
	local reference_status = M.reference_count > 0 and " ↱" .. tostring(M.reference_count) or ""
	local chunks = {
		{ definition_status, "StatuslineActionHintsDefinition" },
		{ reference_status, "StatuslineActionHintsReferences" },
	}

	if M.config.use_virtual_text then
		local bufnr = vim.api.nvim_get_current_buf()
		local cursor = vim.api.nvim_win_get_cursor(0)
		set_virtual_text(bufnr, cursor[1] - 1, chunks)
	end

	local text = ""
	for i, chunk in ipairs(chunks) do
		text = text .. chunk[1]
	end

	return text
end

M.setup = function(options)
	if options == nil then
		options = {}
	end

	-- Merge user supplied options with defaults
	for k, v in pairs(options) do
		M.config[k] = v
	end

	-- Set default colors for StatuslineActionHintsDefinition and StatuslineActionHintsReferences
	vim.api.nvim_command("highlight StatuslineActionHintsDefinition guifg=#add8e6")
	vim.api.nvim_command("highlight StatuslineActionHintsReferences guifg=#ff6666")
end

return M
