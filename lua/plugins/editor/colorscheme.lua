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
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      dim_inactive = {
        enabled = true,
        shade = "light",
        percentage = 0.20,
      },
      flavour = "macchiato",
      -- flavour = "mocha",
      integrations = {
        illuminate = {
          enabled = false,
          -- enabled = true,
          lsp = false,
          -- lsp = true,
        },
        mason = true,
        navic = {
          enabled = true,
        },
        neotree = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- vim.cmd.highlight("IlluminatedWordText gui=underline")
      -- vim.cmd.highlight("IlluminatedWordRead gui=underline")
      -- vim.cmd.highlight("IlluminatedWordWrite gui=underline")
    end,
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    opts = {},
    config = function(_, opts)
      require("rainbow-delimiters.setup").setup(opts)
    end,
  },
}
