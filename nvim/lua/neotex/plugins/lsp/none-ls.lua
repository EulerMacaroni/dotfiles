return {
	"nvimtools/none-ls.nvim", -- configure formatters
	lazy = true,
	ft = { "html", "js", "ts", "lua", "tex" },
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"jay-babu/mason-null-ls.nvim",
		"williamboman/mason.nvim",
	},
	config = function()
		local mason_null_ls = require("mason-null-ls")
		mason_null_ls.setup({
			"stylua", -- lua formatter
			"isort", -- python formatter
			"black", -- python formatter
			"latexindent", -- LaTeX formatter
		})

		-- for conciseness
		local null_ls = require("null-ls")
		local null_ls_utils = require("null-ls.utils")
		local formatting = null_ls.builtins.formatting -- to setup formatters

		-- Custom LaTeX formatter
		local latexindent_formatter = {
			method = null_ls.methods.FORMATTING,
			filetypes = { "tex", "plaintex" }, -- filetypes for LaTeX
			generator = null_ls.generator({
				command = "latexindent",
				args = { "-q", "-w" }, -- quiet and write directly to the file
				to_stdin = false, -- latexindent does not accept input from stdin
			}),
		}
		--
		-- to setup format on save
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		-- configure null_ls
		null_ls.setup({
			-- add package.json as identifier for root (for typescript monorepos)
			root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
			-- setup formatters
			sources = {
				formatting.stylua, -- lua formatter
				formatting.isort.with({ filetypes = { "python" } }), -- Format Python but don't take over LSP
				formatting.black.with({ filetypes = { "python" } }), -- Format Python but don't take over LSP
				-- formatting.latexindent.with({ filetypes = { "tex","plaintex" } }), -- LaTeX formatter
				latexindent_formatter, --custom latex formatting
			},
			-- configure format on save
			-- 	on_attach = function(current_client, bufnr)
			-- 		if current_client.supports_method("textDocument/formatting") then
			-- 			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			-- 			vim.api.nvim_create_autocmd("BufWritePre", {
			-- 				group = augroup,
			-- 				buffer = bufnr,
			-- 				callback = function()
			-- 					vim.lsp.buf.format({
			-- 						-- only use null-ls for formatting instead of lsp server
			-- 						filter = function(client)
			-- 							return client.name == "null-ls"
			-- 						end,
			-- 						async = false,
			-- 					})
			-- 				end,
			-- 			})
			-- 		end
			-- 	end,
		})
	end,
}
