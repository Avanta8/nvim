local utils = require("core.utils")

-- LspAttach autocommand to setup keymaps and other settings when an LSP client attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = utils.augroup("lsp_attach"),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local register = require("which-key").register

    if client == nil then
      vim.notify("LSP client was nil", vim.log.levels.WARN)
      return
    end

    local refresh = function()
      vim.lsp.codelens.refresh({ bufnr = event.buf })
    end
    if client:supports_method("textDocument/codeLens") then
      refresh()

      -- autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = event.buf,
        callback = refresh,
      })
    end

    local builtin = require("telescope.builtin")
    local gtp = require("goto-preview")
    local trouble = require("trouble")
    local glance = require("glance")

    local lsp_rename = vim.lsp.buf.rename
    -- NOTE: disable this for now
    if false and utils.has_plugin("inc-rename.nvim") then
      local inc_rename = require("inc_rename")
      -- kinda jank way of doing this, but we need to simulate the user actually typeing these keys.
      lsp_rename = function()
        return vim.fn.feedkeys(":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>"))
      end
    end

    local function trouble_inner(opts)
      if trouble.is_open(opts) then
        -- don't close
      elseif trouble.is_open() then
        trouble.close()
      end
      trouble.open(opts)
    end

    local function trouble_wrapper(...)
      local args = ...
      return function()
        trouble_inner(args)
      end
    end

    ---@param method GlanceMethod
    local function glance_open(method)
      return function()
        glance.open(method)
      end
    end

    local opts = { buffer = event.buf }

    register({
      K = { vim.lsp.buf.hover, "Hover" },
      ["<c-k>"] = {
        function()
          local cmp = require("cmp")
          if cmp.visible() then
            cmp.close()
          end
          vim.lsp.buf.signature_help()
        end,
        "Signature Help",
        mode = { "n", "i", "v" },
      },
      g = {
        d = { builtin.lsp_definitions, "Definition" },
        D = { vim.lsp.buf.declaration, "Declaration" },
        t = { builtin.lsp_type_definitions, "Type Definition" },
        y = { builtin.lsp_implementations, "Implementation" },
        r = { builtin.lsp_references, "References" },
      },
      ["<leader>"] = {
        l = {
          name = "lsp",
          f = { "<CMD>Format<CR>", "Format file", mode = { "n", "v" } },
          d = { vim.diagnostic.open_float, "Line Diagnostics" },

          -- d = { trouble_wrapper("lsp_definitions"), "Definition" },
          -- D = { trouble_wrapper("lsp_declarations"), "Declaration" },
          -- t = { trouble_wrapper("lsp_type_definitions"), "Type Definition" },
          -- y = { trouble_wrapper("lsp_implementations"), "Implementation" },
          -- z = { trouble_wrapper("lsp_references"), "References" },

          r = { lsp_rename, "Rename" },
          c = { vim.lsp.codelens.run, "Run Codelens", mode = { "n", "v" } },
          C = { refresh, "Refresh Codelens" },
          a = { vim.lsp.buf.code_action, "Code Action", mode = { "n", "v" } },
          A = {
            function()
              vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
            end,
            "Source action",
          },

          -- p = {
          --   name = "preview",
          --   p = { gtp.close_all_win, "Close preview windows" },
          --   d = { gtp.goto_preview_definition, "Definition" },
          --   D = { gtp.goto_preview_declaration, "Declaration" },
          --   t = { gtp.goto_preview_type_definition, "Type Definition" },
          --   y = { gtp.goto_preview_implementation, "Implementation" },
          --   z = { gtp.goto_preview_references, "References" },
          -- },
        },
        r = {
          name = "Lsp Help",
            -- stylua: ignore
            d = { function() builtin.diagnostics({ bufnr = 0 }) end, "Search Diagnostics" },
          e = { builtin.diagnostics, "Search Workspace Diagnostics" },

          q = { trouble_wrapper("diagnostics"), "Diagnostics Trouble" },
          Q = { vim.diagnostic.setloclist, "Diagnostic Quickfix" },

          s = { builtin.lsp_document_symbols, "Search Document Symbols" },
          w = { builtin.lsp_workspace_symbols, "Search Workspace Symbols" },
          j = { builtin.lsp_dynamic_workspace_symbols, "Search Dynamic Workspace Symbols" },
        },
        k = {
          name = "Glance",
          d = { glance_open("definitions"), "Glance definitions" },
          t = { glance_open("type_definitions"), "Glance type definitions" },
          y = { glance_open("implementations"), "Glance implementations" },
          r = { glance_open("references"), "Glance references" },
        },
        t = {
          f = {
            function()
              if trouble.is_open() then
                trouble.focus()
              end
            end,
            "Trouble Focus",
          },
          q = { trouble.close, "Trouble Close" },
          h = {
            function()
              if vim.lsp.inlay_hint == nil then
                vim.notify("Inlay hints not supported", vim.log.levels.WARN)
                return
              end

              local enable = not vim.lsp.inlay_hint.is_enabled(nil)
              vim.notify("Inlay hints " .. (enable and "enabled" or "disabled"), vim.log.levels.INFO)
              vim.lsp.inlay_hint.enable(enable, nil)
            end,
            "Toggle inlay hints",
          },
        },
      },
      ["["] = {
        e = { vim.diagnostic.goto_prev, "Prev Diagnostic" },
      },
      ["]"] = {
        e = { vim.diagnostic.goto_next, "Next Diagnostic" },
      },
    }, opts)
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    -- If we lazy load then LSP doesn't start properly when opening a file directly
    -- https://www.reddit.com/r/neovim/comments/14cikep/comment/jokw2j6/
    lazy = false,
    keys = {
      { "<leader>zl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {},
    config = function(_, opts)
      opts.ensure_installed =
        vim.list_extend(opts.ensure_installed or {}, require("core.lang_setup").get_ensure_installed())
      require("mason-tool-installer").setup(opts)
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>zm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },
}
