local M = {}

---@param plugin string
function M.has_plugin(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

---@param name string
function M.augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

M.autocmd = vim.api.nvim_create_autocmd

function M.which_key_dep(mapping, modes)
  modes = modes or { "n" }
  local table = {}
  for _, mode in ipairs(modes) do
    table[mode] = mapping
  end
  return {
    "folke/which-key.nvim",
    opts = {
      extras = table,
    },
  }
end

return M
