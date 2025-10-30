local M = {}

local ensure_installed = {}

---@return string[]
function M.get_ensure_installed()
  return ensure_installed
end

---Add tool(s) to ensure_installed list
---The tools names should be their mason names (their LSP server names may differ
---to their mason names)
---@param tools string|string[] Element to add or table to extend
function M.add_ensure_installed(tools)
  if type(tools) == "table" then
    vim.list_extend(ensure_installed, tools)
  else
    ensure_installed[#ensure_installed + 1] = tools
  end
end

local formatters_by_ft = {}

---Set formatters for a given filetype
---
---NOTE: Conform is set up to fallback to LSP formatting if no formatter
---is set for the filetype
---@param ft string: filetype
---@param formatters table|string: formatter(s) to set
function M.set_formatters(ft, formatters)
  if type(formatters) ~= "table" then
    formatters = { formatters }
  end
  formatters_by_ft[ft] = formatters
end

---@return table<string, table>
function M.get_formatters_by_ft()
  return formatters_by_ft
end

return M
