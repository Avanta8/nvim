local lang = require("core.lang_setup")

vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=false",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
}

vim.lsp.enable("clangd")

lang.add_ensure_installed("clangd")
-- No formatter set here because clang-format is available on conform but
-- doesn't seem to be on mason.

return {}
