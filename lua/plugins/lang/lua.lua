local lang = require("core.lang_setup")

vim.lsp.config.lua_ls = {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
      codeLens = {
        -- enable = true,
        enable = false,
      },
      hint = {
        enable = true,
      },
      completion = {
        -- callSnippet = "Replace",
        -- callSnippet = "Both",
        callSnippet = "Disable",
      },
    },
  },
}

vim.lsp.enable("lua_ls")

lang.add_ensure_installed({ "lua-language-server", "stylua" })
lang.set_formatters("lua", { "stylua" })

return {

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  { -- optional cmp completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },

  -- NOTE: If I put neodev here, then it doesn't seem to work, even though it is also
  -- in the dependencies of nvim-lspconfig.
  -- {
  --   "folke/neodev.nvim",
  --   opts = {
  --     library = {
  --       enabled = true,
  --       runtime = true,
  --       types = true,
  --       plugins = false,
  --     },
  --   },
  -- },
}
