-- General purpose linters
return {
	-- https://github.com/mfussenegger/nvim-lint
	"mfussenegger/nvim-lint",
	event = "BufWritePost",
	config = function()
		-- Define a table of linters for each filetype (not extension).
		-- Additional linters can be found here: https://github.com/mfussenegger/nvim-lint#available-linters
  require("lint").linters_by_ft = {
    -- Keep Python diagnostics in LSP (ruff + basedpyright) for speed
    -- If you still want CLI linters, add only what you need back here.
    tex = { "chktex" },
  }

		-- Automatically run linters after saving.  Use "InsertLeave" for more aggressive linting.
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    -- Only lint TeX here; Python is handled by LSP
    pattern = { "*.tex" },
    callback = function()
      require("lint").try_lint()
    end,
  })
		-- Configure the chktex linter
		require("lint").linters.chktex = {
			cmd = "chktex",
			args = { "-q", "-v0" }, -- Quiet mode, less verbose
			stdin = false, -- chktex doesn’t support stdin
		}
	end,
}
