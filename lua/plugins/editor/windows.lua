return {
  {
    enabled = false,
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinNew" },
    opts = {
      smooth = false,
    },
  },

  {
    enabled = false,
    "sindrets/winshift.nvim",
    opts = {},
  },

  {
    "s1n7ax/nvim-window-picker",
    keys = function()
      local bufyank = require("extras.bufyank")
      return {
        {
          "<leader>ws",
          function()
            bufyank.win_swap_select(false, false)
          end,
          desc = "Swap Windows",
        },
        {
          "<leader>wS",
          function()
            bufyank.win_swap_select(false, false)
          end,
          desc = "Swap Windows (floating)",
        },
        {
          "<leader>ww",
          function()
            bufyank.win_select(false)
          end,
          desc = "Select Window",
        },
        {
          "<leader>wW",
          function()
            bufyank.win_select(true)
          end,
          desc = "Select Window (floating)",
        },
        {
          "<leader>wr",
          function()
            bufyank.win_replace_select(false)
          end,
          desc = "Replace Window",
        },
        {
          "<leader>wR",
          function()
            bufyank.win_replace_select(true)
          end,
          desc = "Replace Window (floating)",
        },
        { "<leader>wm", bufyank.win_move_select_new_split, desc = "Move Window to New Split" },
        { "<leader>wo", bufyank.win_duplicate_select_new_split, desc = "Open Window in New Split" },

        { "<leader>by", bufyank.copy_buf, desc = "Copy buffer" },
        { "<leader>bp", bufyank.paste_buf, desc = "Paste buffer" },
      }
    end,
    opts = {},
  },
}
