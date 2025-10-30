-- dartls is not available in the mason registry so it needs to
-- be installed manually
--
-- dartls setup is handled by flutter-tools.nvim

return {
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
