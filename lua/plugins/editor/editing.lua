local core_utils = require("core.utils")

return {
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      label = {
        uppercase = false,
        after = false,
        before = true,
      },
      highlight = {
        -- backdrop = false,
      },
      modes = {
        search = {
          enabled = false,
        },
        -- Disable char mode for now as it affect dot (.) repeat with t and f actions
        char = {
          enabled = false,
          -- jump_labels = true,
          multi_line = false,
          char_actions = function(motion)
            return {
              [";"] = "right", -- set to `right` to always go right
              [","] = "left", -- set to `left` to always go left
              -- jump2d style: same case goes next, opposite case goes prev
              [motion] = "next",
              [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
            }
          end,
          highlight = {
            backdrop = false,
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<CR>", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<S-CR>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
    },
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
      -- These are the default mappings
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = "gc",

        -- Toggle comment on current line
        comment_line = "gcc",

        -- Toggle comment on visual selection
        comment_visual = "gc",

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        -- Works also in Visual mode if mapping differs from `comment_visual`
        textobject = "gc",
      },
    },
  },

  -- Swap arguments
  {
    "mizlan/iswap.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = core_utils.which_key_dep({
      ["<leader>i"] = { name = "iswap" },
    }),
    keys = {
      { "<leader>is", "<cmd>ISwap<cr>", desc = "ISwap" },
      { "<leader>iw", "<cmd>ISwapWith<cr>" },
      { "<leader>in", "<cmd>ISwapNode<cr>" },

      { "<leader>im", "<cmd>IMove<cr>" },
      { "<leader>ie", "<cmd>IMoveWith<cr>" },
      { "<leader>ij", "<cmd>IMoveNode<cr>" },
    },
  },
}
