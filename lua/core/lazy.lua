local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  ui = {
    border = "rounded",
  },
  spec = {
    -- { import = "plugins" },
    { import = "plugins/core" },
    { import = "plugins/editor" },
    { import = "plugins/lang" },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    enabled = false,
  },
})
