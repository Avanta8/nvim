local utils = require("core.utils")
local lang = require("core.lang_setup")

vim.lsp.enable("marksman")

lang.add_ensure_installed({ "deno", "marksman" })
lang.set_formatters("markdown", { "deno_fmt", "injected" })

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    event = "VeryLazy",
    opts = {
      preview = {
        icon_provider = "devicons",
        filetypes = { "md", "markdown", "rmd", "codecompanion" },
        ignore_buftypes = {},

        condition = function(buffer)
          local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt

          -- CodeCompanion has a filtype of 'codecompanion' and a buftype of 'nofile'.
          -- However, we don't want markview to attach to all 'nofile' buffers.
          if ft == "codecompanion" then
            return true
          end

          return bt ~= "nofile"
        end,
      },
      markdown = {
        list_items = {
          shift_width = 2,
        },
      },
    },
    config = function(_, opts)
      require("markview").setup(opts)

      -- It seems that markview doesn't always automatically attach to CodeCompanion
      -- so we set up an autocommand to do that.
      vim.api.nvim_create_autocmd("FileType", {
        group = utils.augroup("MarkviewCodeCompanion"),
        pattern = "codecompanion",
        command = "Markview attach",
      })
    end,
    keys = {
      {
        "<leader>tm",
        "<cmd>Markview toggle<cr>",
        desc = "Toggle Markview Preview (local)",
      },
      {
        "<leader>tM",
        "<cmd>Markview Toggle<cr>",
        desc = "Toggle Markview Preview (global)",
      },
    },
  },

  {
    enabled = false,
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes.
        ["<leader>lc"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true, desc = "Toggle Checkbox" },
        },
      },
      workspaces = {
        {
          name = "notes",
          path = "~/.notes",
        },
      },
    },
  },
}
