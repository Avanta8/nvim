local lang = require("core.lang_setup")

vim.lsp.config.yamlls = {
  on_attach = function(client, bufnr)
    assert(client.name == "yamlls")
    client.server_capabilities.documentFormattingProvider = true
  end,
}

vim.lsp.enable("yamlls")

lang.add_ensure_installed("yaml-language-server")

return {}
