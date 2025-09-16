-- local State = require("which-key.state")

-- local M = {}
--
-- -- M.hydra_count = 0
--
-- M.old_start = State.start
--
-- -- ---@param opts? wk.Filter
-- -- function M.start(opts)
-- --   vim.notify("start")
-- --   vim.notify(vim.inspect(M.hydra_count))
-- --   vim.notify(vim.inspect(opts))
-- --   if opts ~= nil then
-- --     if opts.loop == true then
-- --       if opts.hydra_count == nil then
-- --         M.hydra_count = M.hydra_count + 1
-- --         opts.hydra_count = M.hydra_count
-- --       else
-- --         if opts.hydra_count ~= M.hydra_count then
-- --           vim.notify("ignoring")
-- --           return false
-- --         end
-- --       end
-- --     end
-- --   end
-- --   return M.old_start(opts)
-- -- end
-- --
--
-- ---@param opts? wk.Filter
-- function M.start(opts)
--   vim.notify("start")
--   vim.notify(vim.inspect(M.hydra_count))
--   vim.notify(vim.inspect(opts))
--   if opts ~= nil then
--     if opts.loop == true then
--       -- if opts.hydra_count == nil then
--       --   M.hydra_count = M.hydra_count + 1
--       --   opts.hydra_count = M.hydra_count
--       -- else
--       --   if opts.hydra_count ~= M.hydra_count then
--       --     vim.notify("ignoring")
--       --     return false
--       --   end
--       -- end
--     end
--   end
--   return M.old_start(opts)
-- end
--
-- State.start = M.start

return {
  {
    -- "Avanta8/which-key.nvim",
    "folke/which-key.nvim",
    event = "VeryLazy",

    ---@module "which-key"
    ---@type wk.Opts
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
      preset = "helix",
      show_help = false,
      notify = false,
      extras = {
        n = {
          mode = { "n" },
        },
        v = {
          mode = { "v" },
        },
      },
    },
    keys = function()
      local wk = require("which-key")
      -- local view = require("which-key.view")
      -- local state = require("which-key.state")
      -- local util = require("which-key.util")
      local hydra = function(keys)
        return function()
          -- local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
          -- vim.api.nvim_feedkeys(esc, "x", false)
          -- vim.schedule(function()
          --   wk.show({ keys = keys, loop = true })
          -- end)

          -- State.stop()
          -- vim.schedule(function()
          wk.show({ keys = keys, loop = true })
          -- end)
          -- vim.schedule(function()
          --   wk.show({ keys = keys, loop = true })
          -- end)

          -- vim.defer_fn(function()
          --   State.stop()
          --   State.state = nil
          --   view.hide()
          --
          --   vim.defer_fn(function()
          --     wk.show({ keys = keys, loop = true })
          --   end, 100)
          -- end, 100)
        end
      end
      return {
        { "<c-w><space>", hydra("<c-w>"), desc = "Window Hydra" },
        { "[<space>", hydra("["), desc = "[ Hydra" },
        { "][", hydra("["), desc = "[ Hydra" },
        { "]<space>", hydra("]"), desc = "] Hydra" },
        { "[]", hydra("]"), desc = "] Hydra" },
        { "[]", hydra("]"), desc = "] Hydra" },
        -- {
        --   "[]",
        --   -- function()
        --   -- vim.notify("[]")
        --   -- wk.show({ loop = false })
        --   -- local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        --   -- vim.schedule(function()
        --   --   vim.notify("ESC")
        --   --   vim.api.nvim_feedkeys("f", "x", false)
        --   -- end)
        --   -- vim.api.nvim_input("<esc>")
        --   -- M.exit()
        --   -- error()
        --   -- vim.cmd("feedkeys('<ESC>')")
        --   -- end,
        --   -- hydra("]"),
        --   function()
        --     vim.notify("Pressed")
        --     State.stop()
        --     M.hydra_count = M.hydra_count + 1
        --     -- state.stop()
        --     vim.schedule(function()
        --       -- view.hide()
        --       -- state.stop()
        --       -- M.exit()
        --       vim.notify("sc nydra")
        --       hydra("]")()
        --     end)
        --   end,
        --   desc = "] Hydra",
        -- },
      }
    end,
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
      wk.register(opts.extras.n)
      wk.register(opts.extras.v)
    end,
  },
}
