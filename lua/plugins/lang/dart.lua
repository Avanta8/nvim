return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- dart format is really slow
        -- dart = { "dart_format" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Could just not provide this as dartls as it isn't currently available by mason.
        -- But this is more "future proof"! (in case it does become available by mason and
        -- we somehow accidently install it by mason)
        dartls = {
          mason = false,
          setup = false,
        },
      },
    },
  },
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    opts = {},
  },
}
