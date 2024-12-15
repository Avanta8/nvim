return {
  require("core.lang_setup").create_config({
    ruff = {
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
    },
    basedpyright = {
      settings = {
        basedpyright = {
          typeCheckingMode = "standard",
        },
      },
      -- mason = false,
    },
  }),
}
