return {
  require("core.lang_setup").create_config({
    -- Dart format is really slow so don't use it.
    -- Defer formatting to LSP instead

    -- Could just not provide this as dartls as it isn't currently available by mason.
    -- But this is more "future proof"! (in case it does become available by mason and
    -- we somehow accidently install it by mason)
    dartls = {
      mason = false,
      setup = false,
    },
  }),

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = {
        disable = { "dart" },
      },
    },
  },

  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    opts = {},
  },
}
