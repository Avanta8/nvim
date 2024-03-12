return {
  {
    "Shatur/neovim-ayu",
    opts = {},
    config = function(_, opts)
      require("ayu").setup(opts)
    end,
  },
  {
    "marko-cerovac/material.nvim",
    opts = {
      plugins = {
        "dap",
        "dashboard",
        "eyeliner",
        "fidget",
        "flash",
        "gitsigns",
        "harpoon",
        "hop",
        "illuminate",
        "indent-blankline",
        "lspsaga",
        "mini",
        "neogit",
        "neotest",
        "neo-tree",
        "neorg",
        "noice",
        "nvim-cmp",
        "nvim-navic",
        "nvim-tree",
        "nvim-web-devicons",
        "rainbow-delimiters",
        "sneak",
        "telescope",
        "trouble",
        "which-key",
        "nvim-notify",
      },
      lualine_style = "stealth",
      disable = {
        eob_lines = true,
      },
    },
    init = function()
      vim.g.material_style = "palenight"
      vim.cmd.colorscheme("material")
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
  },
}
