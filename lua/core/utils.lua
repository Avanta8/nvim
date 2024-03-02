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

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

return M
