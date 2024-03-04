local core_utils = require("core.utils")

local setup_keymaps = function()
  core_utils.autocmd("LspAttach", {
    group = core_utils.augroup("lsp_attach"),
    callback = function(event)
      local register = require("which-key").register

      local builtin = require("telescope.builtin")
      local gtp = require("goto-preview")

      local lsp_rename = vim.lsp.buf.rename
      if core_utils.has_plugin("inc-rename.nvim") then
        local inc_rename = require("inc_rename")
        -- kinda jank way of doing this, but we need to simulate the user actually typeing these keys.
        lsp_rename = function()
          return vim.fn.feedkeys(":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>"))
        end
      end

      local opts = { buffer = event.buf }

      register({
        K = { vim.lsp.buf.hover, "Hover" },
        ["<c-k>"] = { vim.lsp.buf.signature_help, "Signature Help", mode = { "i" } },
        ["<leader>"] = {
          zl = { "<cmd>LspInfo<cr>", "Lsp Info" },
          l = {
            name = "lsp",
            P = { gtp.close_all_win, "Close preview windows" },
            p = {
              name = "preview",
              d = { gtp.goto_preview_definition, "Definition" },
              t = { gtp.goto_preview_type_definition, "Type Definition" },
              i = { gtp.goto_preview_implementation, "Implementation" },
              D = { gtp.goto_preview_declaration, "Declaration" },
              r = { gtp.goto_preview_references, "References" },
            },
            l = {
              name = "search",
              d = { builtin.lsp_definitions, "Definition" },
              t = { builtin.lsp_type_definitions, "Type Definition" },
              i = { builtin.lsp_implementations, "Implementation" },
              D = { vim.lsp.buf.declaration, "Declaration" },
              r = { builtin.lsp_references, "References" },
              s = { builtin.lsp_document_symbols, "Document Symbols" },
              w = { builtin.lsp_workspace_symbols, "Workspace Symbols" },
              W = { builtin.lsp_dynamic_workspace_symbols, "Dynamic Workspace Symbols" },
              e = {
                function()
                  builtin.diagnostics({ bufnr = 0 })
                end,
                "Diagnostics",
              },
              E = { builtin.diagnostics, "Workspace Diagnostics" },
            },
            k = { vim.lsp.buf.signature_help, "Signature Help" },
            r = { lsp_rename, "Rename" },
            a = { vim.lsp.buf.code_action, "Code Action", mode = { "n", "v" } },
            A = {
              function()
                vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
              end,
              "Source action",
            },
          },
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
      -- NOTE: neodev must be setup before lspconfig (nvim-lspconfig)
      -- I think that putting it as a dependency mandates that it is setup before this
      -- plugin but not 100% sure.
      { "folke/neodev.nvim", opts = {} },
    },
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      -- require("neodev").setup({})
      -- require("mason").setup()
      local lspconfig = require("lspconfig")

      setup_keymaps()

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

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
        local server_opts =
          vim.tbl_deep_extend("force", { capabilities = vim.deepcopy(capabilities) }, server_config or {})

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
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = false,
  },
  {
    -- NOTE:
    -- For some reason, if this plugin is lazy loaded, then it doesn't install the ensure_installed servers.
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      -- NOTE: ensure_installed should NOT be provided in the format that mason-tool-installer wants!
      -- This is because lazy (due to using vim.tbl_deep_extend) doesn't merge lists
      -- properly (it overwrites instead). Therefore, we use a slightly different format
      -- and then convert into the expected format for mason-tool-installer.
      ensure_installed = {},
    },
    config = function(_, opts)
      local ensure = vim.deepcopy(opts.ensure_installed)
      for name, s_opts in pairs(opts.ensure_installed) do
        ensure[#ensure + 1] = vim.tbl_extend("error", { name }, s_opts)
      end
      opts.ensure_installed = ensure
      require("mason-tool-installer").setup(opts)
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>zm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {},
  },
}
