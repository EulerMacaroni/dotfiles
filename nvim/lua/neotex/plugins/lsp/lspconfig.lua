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

    -- Rounded borders for hover, signature help, and diagnostics floats
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
    vim.diagnostic.config({ float = { border = "rounded" } })
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    -- Ruff for fast Python linting/diagnostics
    require("lspconfig").ruff.setup({
      capabilities = default,
      -- Avoid intercepting hover so basedpyright provides docs immediately
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
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

    -- Use basedpyright for Python type checking, navigation, and completions
    local util = require("lspconfig.util")
    require("lspconfig").basedpyright.setup({
      capabilities = default,
      root_dir = util.root_pattern(
        "pyproject.toml",
        "setup.cfg",
        "setup.py",
        "requirements.txt",
        ".git"
      ),
      settings = {
        basedpyright = {
          disableOrganizeImports = true, -- Let Ruff handle imports if desired
          analysis = {
            typeCheckingMode = "basic", -- or "strict" if you want
            autoImportCompletions = true,
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly", -- faster on large repos
            useLibraryCodeForTypes = true,
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
            onOpenAndSave = true,
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

    lspconfig["clangd"].setup({
      capabilities = default,
      cmd = { "clangd" },
      filetypes = { "c", "cpp", "objc", "objcpp" },
      root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
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

    -- Mojo
    lspconfig["mojo"].setup({
      capabilities = default,
      cmd = { "mojo-lsp-server" },
      filetypes = { "mojo" },
      root_dir = util.root_pattern(".git"),
      single_file_support = true,
    })

    -- Terraform
    lspconfig["terraformls"].setup({
      capabilities = default,
      filetypes = { "terraform", "terraform-vars" },
      root_dir = require("lspconfig.util").root_pattern(".terraform", ".git"),
    })
    -- Rust
    lspconfig["rust_analyzer"].setup({
      capabilities = default,
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_dir = require("lspconfig.util").root_pattern("Cargo.toml", "rust-project.json", ".git"),
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            buildScripts = { enable = true },
          },
          procMacro = { enable = true },
          check = { -- run `clippy` on save
            command = "clippy",
            extraArgs = { "--all-targets", "--all-features" },
          },
          inlayHints = {
            enable = true,
            bindingModeHints = { enable = true },
            chainingHints = { enable = true },
            parameterHints = { enable = true },
            typeHints = { enable = true },
          },
          diagnostics = { enable = true },
          files = {
            excludeDirs = { ".git", "target", "node_modules" },
          },
        },
      },
    })
  end,
}
