local M = {}

-- local formatters_by_ft = {}
-- local ensure_installed = {}
-- local servers = {}
--
-- local function treesitter(ft, opts)
--   return {}
-- end
--
-- local function formatting(ft, opts)
--   vim.tbl_deep_extend("force", formatters_by_ft, { [ft] = opts })
-- end
--
-- local function server(ft, opts)
--   local name = server.name
--   local keymaps = server.keymaps
--   opts.name = nil
--   opts.keymaps = nil
--   servers.tbl_deep_extend("force", servers, { [name] = opts })
-- end
--
-- local function mason(ft, opts)
--   vim.list_extend(ensure_installed, opts)
-- end
--
-- local map = {
--   formatting = formatting,
--   mason = mason,
--   server = server,
--   treesitter = treesitter,
-- }
--
-- function M.setup(opts)
--   local ft = opts.ft
--   for k, f in pairs(map) do
--     if opts[k] then
--       f(ft, opts[k])
--     end
--   end
--   return {}
-- end
--
-- M.formatters_by_ft = formatters_by_ft
-- M.ensure_installed = ensure_installed
-- M.servers = servers

function M.conform(user_opts)
  return {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = user_opts,
    },
  }
end

function M.ensure_installed(user_opts)
  return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, user_opts)
    end,
  }
end

function M.lsp_servers(user_opts)
  return {
    "neovim/nvim-lspconfig",
    opts = {
      servers = user_opts,
    },
  }
end

local map = {
  install = M.ensure_installed,
  format = M.conform,
  -- servers = M.servers,
}

function M.create_config(opts)
  local config = {}
  local servers = {}
  for k, v in pairs(opts) do
    if map[k] then
      table.insert(config, map[k](v))
    else
      servers[k] = v
    end
  end
  table.insert(config, M.lsp_servers(servers))
  return config
end

return M
