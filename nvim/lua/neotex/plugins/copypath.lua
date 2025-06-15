-- :CopyPath, :CopyRelativePath  & :CopyFileName
return {
  "ohakutsu/socks-copypath.nvim",
  config = function()
    require("socks-copypath").setup()
  end,
}
