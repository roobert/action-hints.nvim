M = {}

M.references_available = false
M.reference_count = 0
M.definition_available = false

local function references()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local params = {
		textDocument = { uri = bufname },
		position = { line = cursor[1] - 1, character = cursor[2] },
		context = { includeDeclaration = true },
	}

	vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result, _, _)
		if err then
			error(tostring(err))
		end

		if not result then
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
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local params = {
		textDocument = { uri = bufname },
		position = { line = cursor[1] - 1, character = cursor[2] },
	}

	vim.lsp.buf_request(bufnr, "textDocument/definition", params, function(err, result, _, _)
		if err then
			error(tostring(err))
		end

		if not result then
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

M.statusline = function()
	references()
	definition()

	local definition_status = ""

	if M.definition_available then
		definition_status = "gd"
	end

	return string.format("%s refs:%s", definition_status, M.reference_count)
end

M.setup = function() end

return M
