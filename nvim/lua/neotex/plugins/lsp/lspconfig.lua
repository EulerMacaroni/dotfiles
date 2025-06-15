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

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    })
    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      -- vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
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
            "D103", -- docstring issues
            "N802",
            "N803",
            "N806",
            "N999", -- naming issues
            "PLR0903", -- too few public methods (correct Ruff code)
            "PLR0904",
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
    require("lspconfig").gopls.setup({
      cmd = { "gopls" },
      filetypes = { "go", "gomod" },
      root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
    })

    -- ── TypeScript / JavaScript ────────────────────────────────────────────────────
    -- lspconfig["tsserver"].setup = nil

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
    -- ── Swift (SourceKit-LSP) ──────────────────────────────────────────────────────
    lspconfig["sourcekit"].setup({
      -- If sourcekit-lsp is already on your PATH (Xcode 13+ or the
      -- official Swift toolchain puts it in /usr/bin), you can omit cmd.
      -- Otherwise, give the full path:
      --   cmd = { "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp" },
      capabilities = default,
      filetypes = { "swift", "objective-c", "objective-cpp" },
      -- SwiftPM projects have a buildServer.json that SourceKit-LSP reads,
      -- but falling back to Package.swift / .git covers most cases.
      root_dir = require("lspconfig.util").root_pattern("buildServer.json", "Package.swift", ".git"),
      -- Optional tweaks
      settings = {
        -- You can turn on inlay hints the way you did for tsserver:
        -- swift = { inlayHints = { ... } }
      },
      init_options = {
        -- Enable server-side formatting if you have swift-format on PATH
        formatting = true,
      },
    })
  end,
}
