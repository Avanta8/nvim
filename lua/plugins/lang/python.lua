local lang = require("core.lang_setup")

vim.lsp.config.ruff = {
  settings = {
    -- Ruff language server settings go here
  },
  on_attach = function(client, bufnr)
    if client.name == "ruff" then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    else
      error("Just checking that this is never the case")
    end
  end,
}
vim.lsp.config.basedpyright = {
  settings = {
    basedpyright = {
      typeCheckingMode = "standard",
    },
  },
}

vim.lsp.enable({
  "ruff",
  "basedpyright",
})

lang.add_ensure_installed({ "ruff", "basedpyright" })
lang.set_formatters("python", { "ruff_organize_imports", "ruff_fix", "ruff_format" })

return {}
