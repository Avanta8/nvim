local utils = require("extras.bufyank.utils")
local M = {}

---Returns list of window ids, and success
---Returns early if the result of any pick is nil
---@param count integer?
---@return integer[]
---@return boolean
function M.request_picks(count)
  count = count or 1
  local picks = {}
  local success = true
  for i = 1, count do
    local pick = utils.picker_prompt()
    if pick == nil then
      success = false
      break
    end

    picks[i] = pick
  end
  return picks, success
end

local copy_buf_data = nil
function M.copy_buf(winid)
  winid = winid or 0
  copy_buf_data = { utils.get_bufview(winid) }
  utils.notify("Yanked buffer: " .. copy_buf_data[1], vim.log.levels.INFO)
end

function M.paste_buf(winid)
  winid = winid or 0
  if copy_buf_data == nil then
    utils.notify("No currently yanked buffer", vim.log.levels.ERROR)
    return
  end

  local buf = copy_buf_data[1]
  if not vim.api.nvim_buf_is_valid(buf) then
    utils.notify("Yanked buffer is not valid: " .. buf, vim.log.levels.ERROR)
    return
  end

  utils.set_bufview(winid, unpack(copy_buf_data))
end

M.win_duplicate_select_new_split = utils.wrap_toggle_floating(function()
  local source = vim.api.nvim_get_current_win()
  local target = utils.picker_prompt()
  if not target then
    return
  end

  local splitdir = utils.request_splitdir()
  if not splitdir then
    return nil
  end

  local duplicate = vim.api.nvim_open_win(vim.api.nvim_win_get_buf(source), false, {
    win = source,
    relative = "win",
    row = 0,
    col = 0,
    width = 1,
    height = 1,
  })

  utils.move_split(duplicate, target, splitdir)

  return duplicate
end)

M.win_move_select_new_split = utils.wrap_toggle_floating(function()
  local source = vim.api.nvim_get_current_win()
  local target = utils.picker_prompt({ current = false })
  if not target then
    return
  end

  local splitdir = utils.request_splitdir()
  if not splitdir then
    return nil
  end

  utils.move_split(source, target, splitdir)

  return source
end)

M.win_replace_select = function(floating)
  floating = floating == true
  local target = utils.picker_prompt({ floating = floating, current = false })
  if not target then
    return
  end

  utils.replace_window(vim.api.nvim_get_current_win(), target)
  return target
end

M.win_swap_select = function(floating, follow)
  floating = floating == true
  follow = follow ~= false

  local target = utils.picker_prompt({ floating = floating, current = false })
  if not target then
    return
  end

  utils.swap_window(vim.api.nvim_get_current_win(), target)

  if follow then
    vim.api.nvim_set_current_win(target)
  end

  return target
end

M.win_select = function(floating)
  floating = floating == true

  local target = utils.picker_prompt({ floating = floating })
  if not target then
    return
  end

  vim.api.nvim_set_current_win(target)
  return target
end

return M
