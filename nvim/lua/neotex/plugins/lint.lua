-- General purpose linters
return {
	-- https://github.com/mfussenegger/nvim-lint
	"mfussenegger/nvim-lint",
	event = "BufWritePost",
	config = function()
		-- Define a table of linters for each filetype (not extension).
		-- Additional linters can be found here: https://github.com/mfussenegger/nvim-lint#available-linters
		require("lint").linters_by_ft = {
			python = {
				-- Uncomment whichever linters you prefer
				"flake8",
				"mypy",
				"pylint",
			},
			tex = {
				"chktex",
			},
		}

		-- Automatically run linters after saving.  Use "InsertLeave" for more aggressive linting.
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			-- Only run linter for the following extensions. Remove this to always run.
			pattern = { "*.py", ".tex" },
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
