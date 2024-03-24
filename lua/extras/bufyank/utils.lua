local M = {}

M.notify = function(...)
  return vim.notify(...)
end

function M.picker_prompt(opts)
  local picker_opts = {
    picker_config = {
      statusline_winbar_picker = {
        use_winbar = "smart",
      },
    },
    filter_rules = {
      autoselect_one = false,
    },
    show_prompt = false,
  }
  local default_opts = {
    filter = false,
    current = true,
    floating = true,
  }

  opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  local current_win = vim.api.nvim_get_current_win()
  local filter = function(win)
    local config = vim.api.nvim_win_get_config(win)
    if not config.focusable then
      return false
    end

    if not opts.current and win == current_win then
      return false
    end

    if not opts.floating and config.relative ~= "" then
      return false
    end

    if opts.filter and not opts.filter(win) then
      return false
    end

    return true
  end

  function picker_opts.filter_func(wins)
    return vim.tbl_filter(filter, wins)
  end

  local pick_window = require("window-picker").pick_window

  local f = opts.floating and pick_window or M.wrap_toggle_floating(pick_window)
  local win = f(picker_opts)

  if win and not (vim.api.nvim_win_is_valid(win) and (not opts.filter or opts.filter(win))) then
    error("Error with bufyank. win: " .. tostring(win) .. " is not supposed to be able to be chosen")
  end

  return win
end

---@param fun any
---@return function
function M.wrap_toggle_floating(fun)
  return function(...)
    M.hide_floating_windows()
    local result = { pcall(fun, ...) }
    local success = result[1]
    if not success then
      M.notify("Error with window op: " .. tostring(result[2]), vim.log.levels.ERROR)
    end
    M.unhide_floating_windows()
    if success then
      return unpack(result, 2)
    else
      return nil
    end
  end
end

function M.list_floating_windows()
  return vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative ~= ""
  end, vim.api.nvim_list_wins())
end

function M.hide_floating_windows()
  local floats = M.list_floating_windows()

  for _, win in ipairs(floats) do
    vim.api.nvim_win_set_config(win, { hide = true })
  end
end

function M.unhide_floating_windows()
  local floats = M.list_floating_windows()

  for _, win in ipairs(floats) do
    vim.api.nvim_win_set_config(win, { hide = false })
  end
end

function M.get_bufview(win)
  local bufid = vim.api.nvim_win_get_buf(win)
  local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  return bufid, view
end

function M.set_bufview(win, buf, view)
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview(view)
  end)
end

function M.request_splitdir()
  local dir = vim.fn.getcharstr()
  local dirmap = { h = "left", j = "below", k = "above", l = "right" }
  local splitdir = dirmap[dir]
  return splitdir
end

function M.move_split(source, target, dir)
  local opts = {}
  opts.vertical = dir == "left" or dir == "right"
  opts.rightbelow = dir == "right" or dir == "below"

  vim.fn.win_splitmove(source, target, opts)
end

function M.get_maintain_splitdir(win)
  local split = vim.api.nvim_win_get_config(win).split
  if split == "left" or split == "right" then
    return "above"
  else
    return "left"
  end
end

function M.replace_window(source, target)
  local target_config = vim.api.nvim_win_get_config(target)
  local split = M.get_maintain_splitdir(target)

  M.move_split(source, target, split)
  vim.api.nvim_win_hide(target)
  vim.api.nvim_win_set_config(source, target_config)
end

function M.swap_window(source, target)
  local rest = vim.fn.winrestcmd()
  local target_splitdir = M.get_maintain_splitdir(target)
  local source_splitdir = M.get_maintain_splitdir(source)

  local tempbuf = vim.api.nvim_create_buf(false, true)
  local tempsource = vim.api.nvim_open_win(tempbuf, false, {
    win = source,
    split = source_splitdir,
  })

  -- Moving source to target
  M.move_split(source, target, target_splitdir)
  vim.api.nvim_win_set_config(target, {
    relative = "editor",
    row = 0,
    col = 0,
    width = 1,
    height = 1,
  })

  M.move_split(target, tempsource, source_splitdir)
  vim.api.nvim_win_hide(tempsource) -- Could force delete instead
  vim.fn.execute(rest)
end

return M
