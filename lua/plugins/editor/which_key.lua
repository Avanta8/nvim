return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>b"] = { name = "+buffers" },
        ["<leader>f"] = { name = "+file" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        -- ["<leader>l"] = { name = "+code" },  -- done in lsp mapping
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>j"] = { name = "+find text" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+toggle" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>z"] = { name = "+managers" },
      },
      extras = {
        n = {
          mode = { "n" },
        },
        v = {
          mode = { "v" },
        },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
      wk.register(opts.extras.n)
      wk.register(opts.extras.v)
    end,
  },
}
