return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },
  {
    "echasnovski/mini.comment",
    version = '*',
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      -- disable the autocommand from ts-context-commentstring
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })

      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring({
              key = "commentstring",
            }) or vim.bo.commentstring
          end,
        },
        mappings = {
          comment = "gc",
          comment_line = "gcc",
          comment_visual = "gc",
          textobject = "gc",
        },
      })
    end,
  },
}
