return {
  require("core.lang_setup").create_config({
    install = { "rust_analyzer" },
    rust_analyzer = {
      setup = false,
    },
  }),

  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    ft = { "rust" },
    -- init = function()
    --   vim.g.rustaceanvim = {
    --     tools = {
    --       hover_actions = {
    --         replace_builtin_hover = false,
    --       },
    --       code_actions = {
    --         ui_select_fallback = true,
    --       },
    --     },
    --   }
    -- end,
  },
}
