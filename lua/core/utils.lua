local M = {}

---@param plugin string
function M.has_plugin(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

---@param name string
function M.augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

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

function M.close_gitsigns_floating_windows()
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    -- This is also valid
    -- if vim.w[winid].gitsigns_preview ~= nil then
    if pcall(vim.api.nvim_win_get_var, winid, "gitsigns_preview") then
      vim.api.nvim_win_close(winid, false)
    end
  end
end

function M.close_lsp_floating_window(buf_nr)
  local status, existing_float = pcall(vim.api.nvim_buf_get_var, buf_nr or 0, "lsp_floating_preview")
  if not status then
    return
  end

  if existing_float and vim.api.nvim_win_is_valid(existing_float) then
    vim.api.nvim_win_close(existing_float, true)
  end
end

function M.is_floating_window(win_id)
  local config = vim.api.nvim_win_get_config(win_id)
  return config.relative ~= "" or config.external
end

local opposite = { L = "h", H = "l", J = "k", K = "j" }
local key_ctrl_w = vim.api.nvim_replace_termcodes("<C-w>", true, false, true)
function M.replace_win(char)
  -- local keys = vim.api.nvim_replace_termcodes("<C-w>L", true, false, true)
  -- vim.api.nvim_feedkeys(keys, "n", false)

  -- NOTE: For some reason, if I use feedkeys (above), then it doesn't work.
  -- I have do to it like this
  vim.cmd("normal " .. key_ctrl_w .. char)

  local op = opposite[char]
  local replace_win = vim.fn.win_getid(vim.fn.winnr(op))
  local current_win = vim.api.nvim_get_current_win()
  if replace_win ~= current_win then
    vim.api.nvim_win_close(replace_win, false)
  end
end

function M.sfoo()
  local target_win = vim.fn.win_getid(vim.fn.winnr("#"))
  local other_win = vim.fn.win_getid(vim.fn.winnr("5l"))

  print("target:", target_win)
  print("end win:", other_win)
  print("valid1:", vim.api.nvim_win_is_valid(target_win))
  if target_win == 0 or not vim.api.nvim_win_is_valid(target_win) then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_win = vim.api.nvim_get_current_win()
  local winview = vim.fn.winsaveview()
  -- vim.notify(cursor)

  print("valid2:", vim.api.nvim_win_is_valid(target_win))

  -- HACK: necessary for Goto Preview: must call this before changing the current window
  -- because goto preview checks the current window on a WinClosed command. And if we change
  -- window before, then the current window changes, and so goto preview doesn't manage it's
  -- internal state correctly
  vim.api.nvim_exec_autocmds("WinClosed", {})

  print("current win:", current_win)
  print("target win:", target_win)

  -- NOTE: If I flip the following two lines, then this breaks.
  -- Not really sure why...
  -- OK its because `target_win` is the same as `current_win`.
  -- We should check earlier to see if this is the case
  -- Then we probably also don't need to do the goto preview hack
  print("win1", vim.api.nvim_get_current_win())
  vim.api.nvim_win_close(current_win, false)
  print("win2", vim.api.nvim_get_current_win())
  vim.api.nvim_set_current_win(target_win)
  print("valid3:", vim.api.nvim_win_is_valid(target_win))

  vim.api.nvim_set_current_buf(buf)

  -- NOTE: Should be able to do either one of these.
  vim.api.nvim_win_set_cursor(target_win, cursor)
  -- vim.api.nvim_win_set_cursor(0, cursor) -- NOTE: If I put `target_win` instead of 0, then it breaks. Acutally maybe not
  -- vim.fn.winrestview(winview)
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
