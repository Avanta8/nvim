return {
  require("core.lang_setup").create_config({
    ruff_lsp = {
      -- mason = false,
      on_attach = function(client, bufnr)
        if client.name == "ruff_lsp" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        else
          error("Just checking that this is never the case")
        end
      end,
    },
    basedpyright = {
      -- mason = false,
    },
  }),
}
