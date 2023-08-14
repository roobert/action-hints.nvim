local M = {}

M.config = {
	template = {
		{ " ⊛", "ActionHintsDefinition" },
		{ " ↱%s", "ActionHintsReferences" },
	},
	use_virtual_text = false,
	definition_color = "#add8e6",
	reference_color = "#ff6666",
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

	if
		vim.api.nvim_buf_get_option(bufnr, "buftype") ~= ""
		or vim.api.nvim_buf_get_option(bufnr, "filetype") == "help"
		or vim.fn.bufname(bufnr) == ""
	then
		return
	end

	vim.api.nvim_buf_set_virtual_text(bufnr, references_namespace, line, chunks, {})
	last_virtual_text_line = line
end

local function references()
	if not M.supports_method("referencesProvider") then
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
	if not M.supports_method("definitionProvider") then
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

M.supports_method = function(method)
	local clients = vim.lsp.buf_get_clients()
	for _, client in pairs(clients) do
		if client.server_capabilities[method] then
			return true
		end
	end
	return false
end

local debounced_references = debounce(references, 100)
local debounced_definition = debounce(definition, 100)

M.update = function()
	debounced_references()
	debounced_definition()
end

M.statusline = function()
	local definition_status = M.definition_available and string.format(M.config.template[1][1], "") or ""
	local reference_status = M.reference_count > 0
			and string.format(M.config.template[2][1], tostring(M.reference_count))
		or ""
	local chunks = {
		{ definition_status, M.config.template[1][2] },
		{ reference_status, M.config.template[2][2] },
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

	for k, v in pairs(options) do
		M.config[k] = v
	end

	local defColor = M.config.definition_color
	local refColor = M.config.reference_color

	vim.api.nvim_command("highlight ActionHintsDefinition guifg=" .. defColor)
	vim.api.nvim_command("highlight ActionHintsReferences guifg=" .. refColor)

	vim.api.nvim_command([[autocmd CursorMoved * lua require("action-hints").update()]])
	vim.api.nvim_command([[autocmd CursorMovedI * lua require("action-hints").update()]])
end

return M
