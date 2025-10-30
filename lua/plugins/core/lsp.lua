local utils = require("core.utils")

local setup_keymaps = function()
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
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- mason must be setup before lspconfig
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    keys = {
      { "<leader>zl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
    },
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      require("lspconfig.ui.windows").default_options.border = "rounded"

      setup_keymaps()

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

      local server_configs = opts.servers or {}
      local function setup_server(server_name)
        -- vim.notify("setup server: " .. server_name, vim.log.levels.DEBUG)
        local server_config = server_configs[server_name]

        -- if `server_config` == nil, then it may not be explicitly provided by the user.
        -- It may be installed by mason, and `setup_server` was called by mason-lspconfig
        -- In this case, we still do want to set up the lsp (with the default setup).
        server_config = server_config or {}

        -- User provided their own dedicated setup function
        -- TODO: Assert that the user didn't provide any other entries to the table
        -- other than the setup function and mason. Otherwise, they may have made a mistake in
        -- their config and we should explicitly tell them.
        if server_config.setup ~= nil then
          assert(
            server_config.setup == false or type(server_config.setup) == "function",
            (
              "Error with lsp server: "
              .. server_name
              .. ".`server_config.setup` must either be a function or be false."
            )
          )
          if server_config.setup then
            server_config.setup(server_name)
          end
          return
        end

        -- Merge config with default capabilities.
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          -- Disabling incremental sync may prevent LSP diagnostics getting stuck
          flags = { allow_incremental_sync = false },
        }, server_config or {})

        lspconfig[server_name].setup(server_opts)
      end

      local mlsp = require("mason-lspconfig")
      local available_servers = mlsp.get_available_servers()
      local installed_servers = mlsp.get_installed_servers()
      -- Return true if `server_name` can be installed by mason.
      local function mason_available(server_name)
        return vim.tbl_contains(available_servers, server_name)
      end
      -- Return true if `server_name` is currently installed by mason.
      local function mason_installed(server_name)
        return vim.tbl_contains(installed_servers, server_name)
      end

      local ensure_installed = {}
      for server_name, server_config in pairs(server_configs) do
        -- Delegate the setting up to mason if the server is installed by mason, even if
        -- the user doesn't want it to be installed by mason. This is because the same setup
        -- function (`setup_server`) will be called with the same argument either way, no
        -- matter if we call it here, or if it gets called by mason.
        --
        -- mason will call the setup handler for every lsp it has installed, so this is to
        -- avoid the setup function being called twice for the same server.
        --
        -- TODO: We could give a warning notifying to the user that they specified
        -- mason = false, but the lsp is actually currently installed by mason.
        if server_config.mason == false and mason_installed(server_name) then
          vim.notify(
            "You specified for "
              .. server_name
              .. " not to be installed with mason. However, it is installed by mason.\n(Check that you don't have it installed by mason tool installer)",
            vim.log.levels.WARN
          )
        end

        local setup_now = not mason_available(server_name)
          or server_config.mason == false and not mason_installed(server_name)
        if setup_now then
          setup_server(server_name)
        elseif server_config.mason ~= false then
          ensure_installed[#ensure_installed + 1] = server_name
        end
      end
      mlsp.setup({
        ensure_installed = ensure_installed,
        handlers = { setup_server },
      })

      -- Lsp doesn't start properly when opening a file directly unless we add this
      -- https://www.reddit.com/r/neovim/comments/14cikep/comment/jokw2j6/
      vim.api.nvim_exec_autocmds("FileType", {})
    end,
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
