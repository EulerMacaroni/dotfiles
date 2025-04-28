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
    require("lspconfig").ruff.setup({
      settings = {
        ruff = {
          lineLength = 100,
          ignore = {
            "D100",
            "D101",
            "D102",
            "D103", -- docstring issues
            "N802",
            "N803",
            "N806",
            "N999", -- naming issues
            "PLR0903", -- too few public methods (correct Ruff code)
            "PLR0904"
          },
        },
      },
    })

    -- Pylsp: for real language server features
    require("lspconfig").pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            pylint = { enabled = false },
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            pylsp_mypy = { enabled = false },
            yapf = { enabled = false },
            pydocstyle = { enabled = false },
            flake8 = { enabled = false },
            jedi_completion = { include_params = true },
            jedi_signature_help = { enabled = true },
          },
        },
      },
    })
    -- configure python server
    -- lspconfig["pylsp"].setup({
    --   capabilities = default,
    -- })

    -- require("lspconfig").pylsp.setup({
    --   filetypes = { "python" },
    --   settings = {
    --     configurationSources = { "flake8" },
    --     pylsp = {
    --       plugins = {
    --         jedi_completion = { include_params = true },
    --         jedi_signature_help = { enabled = true },
    --         pyflakes = { enabled = true },
    --         pylsp_mypy = { enabled = false },
    --         pycodestyle = {
    --           enabled = true,
    --           ignore = {
    --             "E231",
    --             "E203",
    --             "E704",
    --             "E302",
    --             "E305",
    --             "E251",
    --             "E127",
    --             "E124",
    --             "E501",
    --             "W503",
    --           },
    --           maxLineLength = 140,
    --         },
    --         pylint = {
    --           enabled = true,
    --           args = { "--disable=C0114,C0115,C0116" },
    --         },
    --         yapf = { enabled = true },
    --       },
    --     },
    --   },
    -- })
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
