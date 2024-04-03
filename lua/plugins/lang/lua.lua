return {
  require("core.lang_setup").create_config({
    install = { "stylua" },
    format = {
      lua = { "stylua" },
    },
    lua_ls = {
      settings = {
        Lua = {
          workspace = {
            -- checkThirdParty = false,
          },
          codeLens = {
            enable = true,
          },
          hint = {
            enable = true,
          },
          completion = {
            -- callSnippet = "Replace",
            -- callSnippet = "Both",
            callSnippet = "Disable",
          },
        },
      },
    },
  }),

  -- NOTE: If I put neodev here, then it doesn't seem to work, even though it is also
  -- in the dependencies of nvim-lspconfig.
  -- {
  --   "folke/neodev.nvim",
  --   opts = {
  --     library = {
  --       enabled = true,
  --       runtime = true,
  --       types = true,
  --       plugins = false,
  --     },
  --   },
  -- },
}
