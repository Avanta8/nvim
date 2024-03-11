return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- To ensure that Rust Analyzer is installed by mason, but we don't
        -- want it to get autosetup.
        --
        -- It will get setup by rustaceanvim
        rust_analyzer = {
          setup = false,
        },
        taplo = {},
      },
    },
  },
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
