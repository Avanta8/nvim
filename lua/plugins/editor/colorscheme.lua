return {
  {
    "Shatur/neovim-ayu",
    opts = {},
    config = function(_, opts)
      require("ayu").setup(opts)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "macchiato",
      integrations = {
        mason = true,
        neotree = true,
      },
    },
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
