-- vim.opt.updatetime = 300 -- Time in milliseconds (0.3 seconds)
--
-- -- Trigger LSP hover on CursorHold
-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	pattern = "*", -- Apply to all filetypes, or change to "*.py" to limit to Python files
-- 	callback = function()
-- 		local lsp_clients = vim.lsp.get_active_clients()
-- 		if next(lsp_clients) ~= nil then
-- 			vim.lsp.buf.hover()
-- 		end
-- 	end,
-- })
--

vim.opt.updatetime = 500 -- Delay before CursorHold

-- Make LSP hover window non-focusable
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	focusable = false,
	border = "rounded",
})

-- Show LSP hover on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = { "*.py", "*.lua" },
	callback = function()
		local lsp_clients = vim.lsp.get_active_clients()
		if next(lsp_clients) ~= nil then
			vim.lsp.buf.hover()
		end
	end,
})
