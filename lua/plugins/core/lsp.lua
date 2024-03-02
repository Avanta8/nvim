local core_utils = require("core.utils")

local setup_keymaps = function()
  core_utils.autocmd("LspAttach", {
    group = core_utils.augroup("lsp_attach"),
    callback = function(event)
      local builtin = require("telescope.builtin")
      local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
      end
      local nmap = function(keys, func, desc)
        map("n", keys, func, desc)
      end

      -- stylua: ignore start
      nmap("<leader>ll", "<cmd>LspInfo<cr>", "Lsp Info")
      nmap("gd", function() builtin.lsp_definitions({ reuse_win = true }) end, "Goto Definition")
      nmap("gr", builtin.lsp_references, "Show References")
      nmap("gD", vim.lsp.buf.declaration, "Goto Declaration")
      nmap("gI", function() builtin.lsp_implementations({ reuse_win = true }) end, "Goto Implementation")
      nmap("gy", function() builtin.lsp_type_definitions({ reuse_win = true }) end, "Goto Type Definition")
      nmap("K", vim.lsp.buf.hover, "Hover")
      nmap("gK", vim.lsp.buf.signature_help, "Signature Help")
      map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
      map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code Action")
      -- stylua: ignore end
      nmap("<leader>lA", function()
        vim.lsp.buf.code_action({
          context = {
            only = {
              "source",
            },
            diagnostics = {},
          },
        })
      end, "Source action")

      if core_utils.has_plugin("inc-rename.nvim") then
        nmap("<leader>lr", function()
          local inc_rename = require("inc_rename")
          return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end, "Rename")
      else
        nmap("<leader>lr", vim.lsp.buf.rename, "Rename")
      end
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
        local server_config = server_configs[server_name]

        -- if `server_config` == nil, then it may not be explicitly setup by the user.
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
    enabled = false,
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    setup = false,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {},
  },
}
