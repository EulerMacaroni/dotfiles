return {
  "lewis6991/hover.nvim",
  lazy = false, -- load early so mappings/commands are available
  opts = {
    -- Order and priorities: LSP > diagnostics > dictionary
    providers = {
      { module = 'hover.providers.lsp',        priority = 3000, name = 'LSP' },
      { module = 'hover.providers.diagnostic', priority = 2000, name = 'Diags' },
      { module = 'hover.providers.dictionary', priority = 1000, name = 'Dict'  },
    },
    preview_opts = {
      border = "rounded",
      winblend = 0,
    },
    title = true,
  },
  config = function(_, opts)
    local hover = require("hover")
    hover.setup(opts)

    -- Non-intrusive keymaps: keep your existing `K` mapping intact
    vim.keymap.set("n", "gK", hover.hover, { desc = "Hover" })
    vim.keymap.set("n", "gH", hover.hover_select, { desc = "Hover Select" })

    -- Cycle to next provider with Ctrl-n (safe, non-conflicting)
    vim.keymap.set('n', '<C-n>', function()
      require('hover').switch('next')
    end, { desc = 'hover.nvim (next source)' })
  end,
}
