return {
  require("core.lang_setup").create_config({
    yamlls = {
      on_attach = function(client, bufnr)
        assert(client.name == "yamlls")
        client.server_capabilities.documentFormattingProvider = true
      end,
    },
  }),
}
