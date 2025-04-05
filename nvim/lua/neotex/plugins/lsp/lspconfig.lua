return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- used to enable autocompletion (assign to every lsp server config)
    local default = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- configure python server
    -- lspconfig["pylsp"].setup({
    --   capabilities = default,
    -- })

    require("lspconfig").pylsp.setup({
      -- on_attach = on_attach,
      filetypes = { "python" },
      settings = {
        configurationSources = { "flake8" },
        pylsp = {
          plugins = {
            jedi_completion = {
              include_params = true,
            },
            jedi_signature_help = {
              enabled = true,
            },
            -- jedi = {
            --   extra_paths = {
            --     '~/projects/work_odoo/odoo14',
            --     '~/projects/work_odoo/odoo14',
            --   },
            --   -- Uncomment and modify if you want to specify a virtual env
            -- environment = "odoo",
            -- },
            pyflakes = {
              enabled = true,
            },
            pylsp_mypy = {
              enabled = false,
            },
            pycodestyle = {
              enabled = true,
              ignore = {
                "E501",
                "E231",
                "E203",
                "E704",
                "E302",
                "E305",
                "E251",
                "E127",
                "E124",
                "F405",
                "E501",
              },
              maxLineLength = 120,
            },
            yapf = {
              enabled = true,
            },
          },
        },
      },
    })
    -- configure texlab (LaTeX LSP) server
    lspconfig["texlab"].setup({
      capabilities = default,
      settings = {
        texlab = {
          build = {
            onSave = true,
          },
          chktex = {
            onEdit = false,
            onOpenAndSave = false,
          },
          diagnosticsDelay = 300,
          -- formatterLineLength = 80,
          -- bibtexFormatter = "texlab",
          -- -- Set up bibliography paths
          -- bibParser = {
          --   enabled = true,
          --   -- Add paths where your .bib files might be located
          --   paths = {
          --     "./bib",           -- bib folder in current directory
          --     "~/texmf/bibtex/bib", -- bib folder in Documents
          --     vim.fn.expand("$HOME/texmf/bibtex/bib"), -- Expanded path to Bibliography folder
          --   },
          -- },
          -- -- Enable forward search and inverse search if needed
          -- forwardSearch = {
          --   enabled = true,
          -- },
        },
      },
    })

    -- configure lua server (with special settings)
    lspconfig["lua_ls"].setup({
      capabilities = default,
      settings = {
        -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
  end,
}
-- return {
-- 	-- LSP Configuration
-- 	"neovim/nvim-lspconfig",
--
-- 	dependencies = {
-- 		-- LSP Management
-- 		{ "williamboman/mason.nvim" },
-- 		{ "williamboman/mason-lspconfig.nvim" },
--
-- 		-- Auto-Install LSPs, Linters, Formatters
-- 		{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
--
-- 		-- Useful status updates for LSP
-- 		{ "j-hui/fidget.nvim", opts = {} },
--
-- 		-- Additional Lua configuration
-- 		{ "folke/neodev.nvim", opts = {} },
-- 	},
--
-- 	config = function()
-- 		-- Load Mason & LSP Configs
-- 		require("mason").setup()
-- 		require("mason-lspconfig").setup({
-- 			ensure_installed = {
-- 				"bashls",
-- 				"cssls",
-- 				"html",
-- 				"lua_ls",
-- 				"jsonls",
-- 				"lemminx",
-- 				"marksman",
-- 				"quick_lint_js",
-- 				"yamlls",
-- 				"pyright", -- Ensures Pyright is installed
-- 			},
-- 			automatic_installation = true,
-- 		})
--
-- 		-- Ensure Linters/Formatters are installed
-- 		require("mason-tool-installer").setup({
-- 			ensure_installed = {
-- 				"black",
-- 				"debugpy",
-- 				"flake8",
-- 				"isort",
-- 				"mypy",
-- 				"pylint",
-- 				"latexindent",
-- 			},
-- 		})
--
-- 		-- Ensure Mason installs missing tools
-- 		-- vim.api.nvim_command("MasonToolsInstall")
--
-- 		-- Set up LSP handlers
-- 		local lspconfig = require("lspconfig")
-- 		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
--
-- 		-- Function to attach LSP clients
-- 		local lsp_attach = function(client, bufnr)
-- 			print("LSP started for: " .. client.name) -- Debug message
-- 		end
--
-- 		-- Set up general LSP servers
-- 		require("mason-lspconfig").setup_handlers({
-- 			function(server_name)
-- 				lspconfig[server_name].setup({
-- 					on_attach = lsp_attach,
-- 					capabilities = lsp_capabilities,
-- 				})
-- 			end,
-- 		})
--
-- 		-- Explicit Pyright setup
-- 		-- lspconfig.pyright.setup({
-- 		-- 	-- cmd = {"/Users/azeem/.nvm/versions/node/v22.12.0/bin/pyright-langserver", "--stdio"},
-- 		-- 	on_attach = function(client, bufnr)
-- 		-- 		-- print("Pyright attached successfully")
-- 		-- 	end,
-- 		-- 	capabilities = lsp_capabilities,
-- 		-- 	settings = {
-- 		-- 		python = {
-- 		-- 			analysis = {
-- 		-- 				autoSearchPaths = true,
-- 		-- 				useLibraryCodeForTypes = true,
-- 		-- 				diagnosticMode = "workspace",
-- 		-- 			},
-- 		-- 		},
-- 		-- 	},
-- 		-- })
--
-- 		-- Lua LSP settings
-- 		lspconfig.lua_ls.setup({
-- 			settings = {
-- 				Lua = {
-- 					diagnostics = {
-- 						globals = { "vim" }, -- Recognize Neovim globals
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- Floating preview UI tweaks
-- 		vim.opt.updatetime = 500 -- Reduce delay for LSP popups
-- 		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
-- 			focusable = false,
-- 			border = "rounded",
-- 		})
-- 		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
-- 			border = "rounded",
-- 		})
-- 	end,
-- }
-- --
-- -- return {
-- --   {
-- --     "williamboman/mason.nvim",
-- --     lazy = false,
-- --     config = function()
-- --       require("mason").setup()
-- --     end,
-- --   },
-- --   {
-- --     "williamboman/mason-lspconfig.nvim",
-- --     lazy = false,
-- --     opts = {
-- --       auto_install = true,
-- --     },
-- --   },
-- --   {
-- --     "neovim/nvim-lspconfig",
-- --     lazy = false,
-- --     config = function()
-- --       local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- --
-- --       local lspconfig = require("lspconfig")
-- --       lspconfig.solargraph.setup({
-- --         capabilities = capabilities
-- --       })
-- --       lspconfig.html.setup({
-- --         capabilities = capabilities
-- --       })
-- --       lspconfig.lua_ls.setup({
-- --         capabilities = capabilities
-- --       })
-- --       lspconfig.pyright.setup({
-- --         capabilities = capabilities
-- --       })
-- --
-- --       -- vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
-- --       -- vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
-- --       -- vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
-- --       -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
-- --     end,
-- --   },
-- -- }
