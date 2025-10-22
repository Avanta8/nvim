local utils = require("core.utils")

return {
  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = "<C-y>",
          accept_word = "<C-a>",
          accept_line = "<C-t>",
          next = "<C-n>",
          prev = "<C-p>",
          dismiss = "<C-d>",
        },
      },
      panel = {
        enabled = false,
        auto_refresh = true,
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          keymaps = {
            send = {
              modes = {
                n = { "<CR>", "<C-j>" },
                i = "<C-j>",
              },
            },
          },
          -- opts = {
          --   ---Decorate the user message before it's sent to the LLM
          --   ---@param message string
          --   ---@param adapter table
          --   ---@param context table
          --   ---@return string
          --   prompt_decorator = function(message, adapter, context)
          --     if adapter["name"] == "copilot" then
          --       return string.format([[<prompt>%s</prompt>]], message)
          --     end
          --
          --     return message
          --   end,
          -- },
        },
      },
      adapters = {
        http = {
          tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
              env = {
                api_key = "cmd: cat ~/.config/tavily_api_key",
              },
            })
          end,
        },
      },
    },

    config = function(_, opts)
      require("codecompanion").setup(opts)

      -- Show notification when a request starts
      local augroup = utils.augroup("CodeCompanion")
      vim.api.nvim_create_autocmd("User", {
        group = augroup,
        pattern = { "CodeCompanionRequestStarted", "CodeCompanionInlineStarted" },
        callback = function(request)
          local event = request["match"]
          local name = request["data"]["adapter"]["name"]
          local model = request["data"]["adapter"]["model"]

          vim.notify(string.format("%s: %s: %s", event, name, model))
        end,
      })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
    keys = {
      -- Main workflows
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions (Prompt Library)", mode = { "n", "v" } },
      { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "New Chat", mode = { "n", "v" } },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "Inline Prompt", mode = { "n", "v" } },

      -- Chat buffer management
      { "<leader>av", "<cmd>CodeCompanionChat Add<cr>", desc = "Add to Chat (Visual)", mode = "v" },

      -- Inline prompts
      { "<leader>aC", "<cmd>CodeCompanion /commit<cr>", desc = "Commit", mode = "n" },
      { "<leader>af", "<cmd>CodeCompanion /fix<cr>", desc = "Fix Code", mode = "v" },
      { "<leader>aT", "<cmd>CodeCompanion /tests<cr>", desc = "Generate Tests", mode = "v" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", desc = "Explain Code", mode = "v" },
      { "<leader>al", "<cmd>CodeCompanion /lsp<cr>", desc = "Explain LSP Diagnostics", mode = "v" },
    },
  },

  {
    enabled = false,
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          backend = "zellij",
          enabled = true,
        },
      },
    },
    keys = {},
  },
}
