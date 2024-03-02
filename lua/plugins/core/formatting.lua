return {
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    lazy = false,
    keys = {
      { "<leader>lk", "<cmd>ConformInfo<cr>", desc = "Conform Info" },
      {
        "<leader>lf",
        "<cmd>Format<cr>",
        -- function()
        -- require("conform").format({ lsp_fallback = true })
        -- end,
        mode = { "n", "v" },
        desc = "Format file",
      },
    },
    opts = {
      format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = true,
        timeout_ms = 500,
      },
    },
    config = function(_, opts)
      local conform = require("conform")
      conform.setup(opts)

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil

        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        conform.format({ lsp_fallback = true, range = range })
        -- require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
    end,
  },
}
