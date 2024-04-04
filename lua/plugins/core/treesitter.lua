return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = "VeryLazy",
    dependencies = {
      {
        "RRethy/nvim-treesitter-endwise",
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = function()
      local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
      return {
        { "<c-space>", desc = "Increment selection" },
        { "<bs>", desc = "Decrement selection", mode = "x" },
        { ";", ts_repeat_move.repeat_last_move_next, mode = { "n", "x", "o" } },
        { ",", ts_repeat_move.repeat_last_move_previous, mode = { "n", "x", "o" } },
        { "f", ts_repeat_move.builtin_f, mode = { "n", "x", "o" } },
        { "F", ts_repeat_move.builtin_F, mode = { "n", "x", "o" } },
        { "t", ts_repeat_move.builtin_t, mode = { "n", "x", "o" } },
        { "T", ts_repeat_move.builtin_T, mode = { "n", "x", "o" } },
      }
    end,
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      auto_install = true,
      indent = { enable = true },
      -- ensure_installed = {
      --   "bash",
      --   "c",
      --   "diff",
      --   "html",
      --   "javascript",
      --   "jsdoc",
      --   "json",
      --   "jsonc",
      --   "lua",
      --   "luadoc",
      --   "luap",
      --   "markdown",
      --   "markdown_inline",
      --   "python",
      --   "query",
      --   "regex",
      --   "toml",
      --   "tsx",
      --   "typescript",
      --   "vim",
      --   "vimdoc",
      --   "yaml",
      -- },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
      endwise = {
        enable = true,
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
