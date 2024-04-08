local utils = require("core.utils")

-- Quit all
vim.keymap.set("n", "<leader>qq", "<CMD>qa<CR>", { desc = "Quit all" })

-- Clear hlsearch
vim.keymap.set("n", "<leader>h", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch" })

-- Toggle comments
vim.keymap.set("n", "<c-_>", "gcc", { desc = "Comment line", remap = true })
vim.keymap.set("v", "<c-_>", "gcgv", { desc = "Comment selection", remap = true })

-- Ctrl-del to delete next word
vim.keymap.set("i", "<c-del>", "<space><esc>ce")

-- Lazy info
vim.keymap.set("n", "<leader>zp", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Remap for visual block mode
vim.keymap.set("n", "<leader>v", "<c-v>")

-- Remap record macro to Q
vim.keymap.set({ "n", "x" }, "Q", "q")
vim.keymap.set({ "n", "x" }, "q", "<nop>")

-- Add empty lines before and after cursor line
vim.keymap.set(
  "n",
  "gO",
  "<CMD>call append(line('.') - 1, repeat([''], v:count1))<CR>",
  { desc = "New line above cursor" }
)
vim.keymap.set(
  "n",
  "go",
  "<CMD>call append(line('.'),     repeat([''], v:count1))<CR>",
  { desc = "New line below cursor" }
)

-- Paste from yank register
vim.keymap.set({ "n", "x" }, "<leader>p", '"0p')
vim.keymap.set({ "n", "x" }, "<leader>P", '"0P')

-- Delete without overwriting unnamed register
vim.keymap.set({ "n", "x" }, "<leader>d", '"_d')
vim.keymap.set({ "n", "x" }, "<leader>D", '"_D')

-- Change without overwriting unnamed register
vim.keymap.set({ "n", "x" }, "<leader>c", '"_c')
vim.keymap.set({ "n", "x" }, "<leader>C", '"_C')

-- Delete char without overwriting unnamed register by default
vim.keymap.set({ "n", "x" }, "x", '"_x')
vim.keymap.set({ "n", "x" }, "X", '"_X')

-- Select line
vim.keymap.set("n", "vv", "^vg_")

-- ESC to close certain floating windows (eg. hover, diagnostics, gitsigns) and clear hlsearch
vim.keymap.set("n", "<ESC>", function()
  utils.close_lsp_floating_window()
  utils.close_gitsigns_floating_windows()
  vim.cmd.noh()

  -- Now also simulate the acutal <ESC> keypress
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", false)
end)

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
-- vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
-- vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
-- vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
-- vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Easier window <C-w> bindings
-- vim.keymap.set("", "<leader>ww", "<C-w>w", { desc = "Switch Windows" })
-- vim.keymap.set("", "<leader>wp", "<C-w>p", { desc = "Prev Window" })
-- vim.keymap.set("", "<leader>wq", "<C-w>c", { desc = "Close Window" })
--
-- vim.keymap.set("", "<leader>wh", "<C-w>h", { desc = "Go to Left Window" })
-- vim.keymap.set("", "<leader>wj", "<C-w>j", { desc = "Go to Down Window" })
-- vim.keymap.set("", "<leader>wk", "<C-w>k", { desc = "Go to Right Window" })
-- vim.keymap.set("", "<leader>wl", "<C-w>l", { desc = "Go to Up Window" })
--
-- vim.keymap.set("", "<leader>wH", "<C-w>H", { desc = "Move Window Left" })
-- vim.keymap.set("", "<leader>wJ", "<C-w>J", { desc = "Move Window Down" })
-- vim.keymap.set("", "<leader>wK", "<C-w>K", { desc = "Move Window Right" })
-- vim.keymap.set("", "<leader>wL", "<C-w>L", { desc = "Move Window Up" })

-- Replace windows
-- stylua: ignore start
-- vim.keymap.set("n", "<leader>wrh", function() utils.replace_win_dir("h") end, { desc = "Replace Window Left" })
-- vim.keymap.set("n", "<leader>wrj", function() utils.replace_win_dir("j") end, { desc = "Replace Window Down" })
-- vim.keymap.set("n", "<leader>wrk", function() utils.replace_win_dir("k") end, { desc = "Replace Window Up" })
-- vim.keymap.set("n", "<leader>wrl", function() utils.replace_win_dir("l") end, { desc = "Replace Window Right" })

-- Jump to window with count, or previous window without count
vim.keymap.set("n", "\\", function()
  if vim.v.count > 0 then
    vim.cmd.wincmd(tostring(vim.v.count) .. " w")
  else
    vim.cmd.wincmd("p")
  end
end)

-- Delete windows
vim.keymap.set("n", "<leader>wdh", function() utils.del_win_dir("h") end, {desc = "Delete Window Left"})
vim.keymap.set("n", "<leader>wdj", function() utils.del_win_dir("j") end, {desc = "Delete Window Down"})
vim.keymap.set("n", "<leader>wdk", function() utils.del_win_dir("k") end, {desc = "Delete Window Up"})
vim.keymap.set("n", "<leader>wdl", function() utils.del_win_dir("l") end, {desc = "Delete Window Right"})
-- stylua: ignore end

-- Easier start / end of line mappings
vim.keymap.set("", "gh", "^")
vim.keymap.set("", "gl", "$")

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer switch
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- new file
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- tabs
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- vim.keymap.set("n", "<leader>by", bufyank.copy_buf, { desc = "Yank buffer" })
-- vim.keymap.set("n", "<leader>bp", bufyank.paste_buf, { desc = "Put buffer" })
--
-- vim.keymap.set("n", "<leader>wus", utils.user_swap_windows, { desc = "Swap windows" })
-- vim.keymap.set("n", "<leader>wud", utils.user_duplicate_window, { desc = "Duplicate window" })
-- vim.keymap.set("n", "<leader>wur", utils.user_replace_window, { desc = "Replace window" })
