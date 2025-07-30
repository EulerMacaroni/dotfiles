return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local lspconfig = require("lspconfig")

    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local default = cmp_nvim_lsp.default_capabilities()

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    })
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    require("lspconfig").ruff.setup({
      settings = {
        ruff = {
          lineLength = 100,
          ignore = {
            "D100",
            "D101",
            "D102",
            "D103",
            "N802",
            "N803",
            "N806",
            "N999",
            "PLR0903",
            "PLR0904",
          },
        },
      },
    })

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

    lspconfig["lua_ls"].setup({
      capabilities = default,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    require("lspconfig").gopls.setup({
      cmd = { "gopls" },
      filetypes = { "go", "gomod" },
      root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
    })

    lspconfig["tsserver"].setup({
      capabilities = default,
      filetypes = {
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "javascript",
        "javascriptreact",
        "javascript.jsx",
      },
      root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          },
        },
      },
      -- on_attach = function(client, _)
      --   client.server_capabilities.documentFormattingProvider = false
      -- end,
    })

    lspconfig["sourcekit"].setup({
      capabilities = default,
      filetypes = { "swift", "objective-c", "objective-cpp" },
      root_dir = require("lspconfig.util").root_pattern("buildServer.json", "Package.swift", ".git"),
      settings = {},
      init_options = {
        formatting = true,
      },
    })
  end,
}
