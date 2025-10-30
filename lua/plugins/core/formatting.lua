return {
  {
    "stevearc/conform.nvim",
    event = { "LspAttach", "BufWritePre" },
    keys = {
      { "<leader>zc", "<cmd>ConformInfo<cr>", desc = "Conform Info" },
    },
    opts = {
      -- notify_on_error = false,
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
    },
    config = function(_, opts)
      local conform = require("conform")

      opts.formatters_by_ft =
        vim.tbl_extend("error", opts.formatters_by_ft or {}, require("core.lang_setup").get_formatters_by_ft())
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
