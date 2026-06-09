
-- CONFIGURATION AND UTILITY FUNCTIONS --
------------------------------------------
local opts = { noremap = true, silent = true }

-- Helper function for more readable keymap definition
local function map(mode, key, cmd, options, description)
  local opts = vim.tbl_deep_extend("force",
    { noremap = true, silent = true, desc = description },
    options or {}
  )
  vim.keymap.set(mode, key, cmd, opts)
end

-- Helper for buffer-local mapping
local function buf_map(bufnr, mode, key, cmd, description)
  vim.api.nvim_buf_set_keymap(
    bufnr or 0,
    mode,
    key,
    cmd,
    { noremap = true, silent = true, desc = description }
  )
end

----------------------------------------
-- BUFFER-SPECIFIC KEYMAP FUNCTIONS  --
----------------------------------------

-- Terminal mappings setup function triggered by an auto-command
function _G.set_terminal_keymaps()
  -- Set the terminal window as fixed
  vim.wo.winfixbuf = true

  -- Terminal navigation
  buf_map(0, "t", "<esc>", "<C-\\><C-n>", "Exit terminal mode")
  buf_map(0, "t", "<C-h>", "<Cmd>wincmd h<CR>", "Navigate left")
  buf_map(0, "t", "<C-j>", "<Cmd>wincmd j<CR>", "Navigate down")
  buf_map(0, "t", "<C-k>", "<Cmd>wincmd k<CR>", "Navigate up")
  buf_map(0, "t", "<C-l>", "<Cmd>wincmd l<CR>", "Navigate right")

  -- Terminal resizing
  buf_map(0, "t", "<M-Right>", "<Cmd>vertical resize -2<CR>", "Resize right")
  buf_map(0, "t", "<M-Left>", "<Cmd>vertical resize +2<CR>", "Resize left")
  buf_map(0, "t", "<M-l>", "<Cmd>vertical resize -2<CR>", "Resize right")
  buf_map(0, "t", "<M-h>", "<Cmd>vertical resize +2<CR>", "Resize left")

  -- Avante integration (only for non-lazygit buffers)
  -- if vim.bo.filetype ~= "lazygit" then
  --   buf_map(0, "t", "<C-a>", "<Cmd>AvanteAsk<CR>", "Ask Avante")
  --   buf_map(0, "n", "<C-a>", "<Cmd>AvanteAsk<CR>", "Ask Avante")
  --   buf_map(0, "v", "<C-a>", "<Cmd>AvanteAsk<CR>", "Ask Avante")
  -- end
end

-- Markdown mappings setup function triggered by an auto-command
-- function _G.set_markdown_keymaps()
--   -- List management
--   buf_map(0, "i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", "New bullet point")
--   buf_map(0, "n", "o", "o<cmd>AutolistNewBullet<cr>", "New bullet below")
--   buf_map(0, "n", "O", "O<cmd>AutolistNewBulletBefore<cr>", "New bullet above")
--   buf_map(0, "n", "<C-n>", "<cmd>lua HandleCheckbox()<CR>", "Toggle checkbox")
--
--   -- Indentation and recalculation
--   buf_map(0, "i", "<tab>", "<Esc>><cmd>AutolistRecalculate<cr>a<space>", "Indent bullet")
--   buf_map(0, "i", "<S-tab>", "<Esc><<cmd>AutolistRecalculate<cr>a", "Unindent bullet")
--   buf_map(0, "n", ">", "><cmd>AutolistRecalculate<cr>", "Indent bullet")
--   buf_map(0, "n", "<", "<<cmd>AutolistRecalculate<cr>", "Unindent bullet")
--   buf_map(0, "n", "<C-c>", "<cmd>AutolistRecalculate<cr>", "Recalculate list")
--
--   -- Deletion with list recalculation
--   buf_map(0, "n", "dd", "dd<cmd>AutolistRecalculate<cr>", "Delete and recalculate")
--   buf_map(0, "v", "d", "d<cmd>AutolistRecalculate<cr>", "Delete and recalculate")
--
--   -- Tab settings for markdown
--   vim.opt.tabstop = 2
--   vim.opt.shiftwidth = 2
--   vim.opt.softtabstop = 2
-- end

-- Avante AI buffer mappings setup function triggered by an auto-command
-- function _G.set_avante_keymaps()
--   -- Helper for buffer-local Avante mappings
--   local function avante_map(mode, key, cmd, description)
--     buf_map(0, mode, key, cmd, description)
--   end
--
--   -- Toggle Avante interface
--   avante_map("n", "<C-t>", "<cmd>AvanteToggle<CR>", "Toggle Avante interface")
--   avante_map("i", "<C-t>", "<cmd>AvanteToggle<CR>", "Toggle Avante interface")
--   avante_map("n", "q", "<cmd>AvanteToggle<CR>", "Toggle Avante interface")
--
--   -- Reset/clear Avante content
--   avante_map("n", "<C-c>", "<cmd>AvanteClear<CR>", "Clear chat history")
--   avante_map("i", "<C-c>", "<cmd>AvanteClear<CR>", "Clear chat history")
--
--   -- Model and provider selection
--   avante_map("n", "<C-m>", "<cmd>AvanteModel<CR>", "Select model")
--   avante_map("i", "<C-m>", "<cmd>AvanteModel<CR>", "Select model")
--   avante_map("n", "<C-p>", "<cmd>AvanteProvider<CR>", "Select provider")
--   avante_map("i", "<C-p>", "<cmd>AvanteProvider<CR>", "Select provider")
--
--   -- Generation control
--   avante_map("n", "<C-s>", "<cmd>AvanteStop<CR>", "Stop generation")
--   avante_map("i", "<C-s>", "<cmd>AvanteStop<CR>", "Stop generation")
--   avante_map("n", "<C-d>", "<cmd>AvanteProvider<CR>", "Default provider")
--   avante_map("i", "<C-d>", "<cmd>AvanteProvider<CR>", "Default provider")
--
--   -- Prevent accidental submission
--   avante_map("i", "<CR>", "<CR>", "Create new line")
-- end

-----------------------------
-- GLOBAL LEADER SETTINGS --
-----------------------------
vim.g.mapleader = " " -- Space as leader key

---------------------------------
-- GENERAL KEYBOARD MAPPINGS  --
---------------------------------

-- Prevents common mode mistakes
map("n", "<C-z>", "<nop>", {}, "Disable suspend")
map("n", "gc", "<nop>", {}, "Disable gc mappings")
map("n", "gcc", "<nop>", {}, "Disable gcc mappings")

-- Terminal integration
map("n", "<C-t>", "<cmd>ToggleTerm<CR>", { remap = true }, "Toggle terminal")
map("t", "<C-t>", "<cmd>ToggleTerm<CR>", { remap = true }, "Toggle terminal")

-- Spelling assistance
map("n", "<C-s>", function()
  require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor({
    previewer = false,
    layout_config = { width = 50, height = 15 }
  }))
end, { remap = true }, "Spelling suggestions")

-- Search functionality
map("n", "<CR>", "<cmd>noh<CR>", {}, "Clear search highlights") -- clear highlight with enter key
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { remap = true }, "Find files")

-- Comment toggling
map('n', "<C-;>", '<Plug>(comment_toggle_linewise_current)', {}, "Toggle comment")
map('x', "<C-;>", '<Plug>(comment_toggle_linewise_visual)', {}, "Toggle comment selection")

-- Help integration
map("n", "<S-m>", '<cmd>Telescope help_tags cword=true<cr>', {}, "Help for word under cursor")
map("n", "<C-m>", '<cmd>Telescope man_pages<cr>', {}, "Search man pages")

------------------------
-- TEXT EDITING KEYS --
------------------------

-- Fix standard behaviors
map("n", "Y", "y$", {}, "Yank to end of line")
map("n", "E", "ge", {}, "Go to end of previous word")
map("v", "Y", "y$", {}, "Yank to end of line")
-- paste fix
map("x", "p", '"_dP', {}, "Paste without overwriting yank")

-- Cursor centering
map("n", "m", "zt", {}, "Center cursor at top")
map("v", "m", "zt", {}, "Center cursor at top")

-- Window navigation
map("n", "<C-h>", "<C-w>h", {}, "Navigate left")
map("n", "<C-j>", "<C-w>j", {}, "Navigate down")
map("n", "<C-k>", "<C-w>k", {}, "Navigate up")
map("n", "<C-l>", "<C-w>l", {}, "Navigate right")

-- Window resizing
map("n", "<A-Left>", ":vertical resize -2<CR>", {}, "Decrease width")
map("n", "<A-Right>", ":vertical resize +2<CR>", {}, "Increase width")
map("n", "<A-h>", ":vertical resize -2<CR>", {}, "Decrease width")
map("n", "<A-l>", ":vertical resize +2<CR>", {}, "Increase width")

-- Buffer navigation
map("n", "<TAB>", "", { callback = function() GotoBuffer(1, 1) end }, "Next buffer")
map("n", "<S-TAB>", "", { callback = function() GotoBuffer(1, -1) end }, "Previous buffer")

-- Line manipulation
map("n", "<A-j>", "<Esc>:m .+1<CR>==", {}, "Move line down")
map("n", "<A-k>", "<Esc>:m .-2<CR>==", {}, "Move line up")
map("x", "<A-j>", ":move '>+1<CR>gv-gv", {}, "Move selection down")
map("x", "<A-k>", ":move '<-2<CR>gv-gv", {}, "Move selection up")
map("v", "<A-j>", ":m'>+<CR>gv", {}, "Move selection down")
map("v", "<A-k>", ":m-2<CR>gv", {}, "Move selection up")

-- Scrolling with centering
map("n", "<c-u>", "<c-u>zz", {}, "Scroll up with centering")
map("n", "<c-d>", "<c-d>zz", {}, "Scroll down with centering")

-- Line navigation
map("v", "<S-h>", "g^", {}, "Go to start of display line")
map("v", "<S-l>", "g$", {}, "Go to end of display line")
map("n", "<S-h>", "g^", {}, "Go to start of display line")
map("n", "<S-l>", "g$", {}, "Go to end of display line")

-- Indentation
map("v", "<", "<gv", {}, "Decrease indent and reselect")
map("v", ">", ">gv", {}, "Increase indent and reselect")
map("n", "<", "<S-v><<esc>", {}, "Decrease indent for line")
map("n", ">", "<S-v>><esc>", {}, "Increase indent for line")

-- Visual line navigation
map("n", "J", "gj", {}, "Move down display line")
map("n", "K", "gk", {}, "Move up display line")
map("v", "J", "gj", {}, "Move down display line")
map("v", "K", "gk", {}, "Move up display line")

-- Drag lines
map("v", "J", ":m '>+1<CR>gv=gv",opts)
map("v", "K", ":m '<-2<CR>gv=gv",opts)

-- Actions: <C-o> and <C-i>
-- vim.keymap.set("n", "<C-o>", "<leader>o", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-i>", "<leader>i", { noremap = true, silent = true })
