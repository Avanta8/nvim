return require("core.lang_setup").create_config({
  install = { "stylua" },
  format = {
    lua = { "stylua" },
  },
  lua_ls = {
    settings = {
      Lua = {
        hint = {
          enable = true,
        },
        completion = {
          callSnippet = "Replace",
          -- callSnippet = "Both",
        },
        diagnostics = {
          -- testing
          globals = { "abab" },
        },
      },
    },
  },
})
