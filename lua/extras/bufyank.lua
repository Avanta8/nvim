local M = {}

M.notify = function(...)
  vim.notify(...)
end

function M.picker_prompt(opts)
  local picker_opts = {
    -- hint = "floating-big-letter",
    picker_config = {
      statusline_winbar_picker = {
        use_winbar = "smart",
      },
    },
    show_prompt = false,
    -- filter_func = function(wins)
    --   return vim.tbl_filter(function(win)
    --     local config = vim.api.nvim_win_get_config(win)
    --     return config.focusable
    --   end, wins)
    -- end,
    -- filter_rules = {
    --   include_current_win = true,
    --   autoselect_one = false,
    --   bo = {
    --     buftype = { "nofile", "nowrite", "prompt" },
    --   },
    -- },
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
    local pick = M.picker_prompt()
    if pick == nil then
      success = false
      break
    end

    picks[i] = pick
  end
  return picks, success
end

-- local function get_bufcursor(winid)
--   local bufid = vim.api.nvim_win_get_buf(winid)
--   local cursor = vim.api.nvim_win_get_cursor(winid)
--   local localopts = vim.api.nvim_exec2("setlocal!", { output = true }).output
--   -- vim.notify(vim.inspect(localopts))
--   localopts = string.sub(localopts, 31)
--   -- vim.notify(vim.inspect(localopts))
--   local opts = {}
--   for opt in localopts:gmatch("[^\n]+") do
--     opt = vim.trim(opt)
--     -- vim.notify(opt)
--     table.insert(opts, opt)
--   end
--   return bufid, cursor, opts
-- end
--
-- local function set_bufcursor(winid, bufid, cursor, localopts)
--   vim.api.nvim_win_set_buf(winid, bufid)
--   vim.api.nvim_win_set_cursor(winid, cursor)
--   -- for k, v in pairs(vim.api.nvim_get_all_options_info()) do
--   --   -- vim.notify(k)
--   --   pcall(vim.api.nvim_exec2, "setlocal " .. k .. "<", {})
--   -- end
--   -- for _, opt in ipairs(localopts) do
--   --   -- vim.api.nvim_exec2("setlocal " .. opt, {})
--   --   pcall(vim.api.nvim_exec2, "setlocal " .. opt, {})
--   -- end
-- end

local function get_bufcursor(winid)
  local bufid = vim.api.nvim_win_get_buf(winid)
  local view = vim.api.nvim_win_call(winid, vim.fn.winsaveview)
  return bufid, view
end

local function set_bufcursor(win, buf, view)
  local config = vim.api.nvim_win_get_config(win)
  local new_win = vim.api.nvim_open_win(buf, false, {
    row = 0,
    col = 0,
    width = 1,
    height = 1,
    relative = "editor",
  })
  vim.api.nvim_win_set_config(new_win, {
    win = win,
    vertical = true,
  })
  vim.api.nvim_win_close(win, false)
  vim.api.nvim_win_set_config(new_win, config)

  vim.api.nvim_win_call(new_win, function()
    vim.fn.winrestview(view)
  end)
end

function M._test()
  local win = M.picker_prompt()
  if not win then
    return
  end

  local duplicate = vim.api.nvim_open_win(vim.api.nvim_win_get_buf(win), false, {
    win = win,
    split = "right",
  })
end

function M._print()
  local win = M.picker_prompt()
  if not win then
    return
  end

  local current_win = vim.api.nvim_get_current_win()

  local config = vim.api.nvim_win_get_config(win)
  -- vim.api.nvim_set_current_win(win)
  -- local view = vim.fn.winsaveview()
  -- vim.api.nvim_set_current_win(current_win)
  local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)

  vim.notify(vim.inspect(config))
  -- config.win = -1
  -- vim.api.nvim_win_set_config(win, config)
  -- vim.api.nvim_open_win(vim.api.nvim_win_get_buf(win), true, config)
  -- vim.notify(vim.inspect(config))
  -- local cursor = vim.api.nvim_win_get_cursor(win)

  local temp = vim.api.nvim_win_get_buf(win)
  local new_win = vim.api.nvim_open_win(temp, true, {
    -- relative = "editor",
    -- width = 100,
    -- height = 50,
    -- row = 20,
    -- col = 40,
    -- win = target,
    win = -1,
    vertical = true,
    -- split = splitdir,
  })

  -- vim.api.nvim_win_set_config(new_win, {
  --   win = target,
  --   split = splitdir,
  -- })

  if true then
    return
  end

  local scratch = vim.api.nvim_create_buf(false, true)
  local new_win = vim.api.nvim_open_win(scratch, true, {
    row = 0,
    col = 0,
    width = 100,
    height = 100,
    relative = "editor",
  })
  vim.api.nvim_win_set_buf(new_win, vim.api.nvim_win_get_buf(win))
  if true then
    return
  end
  -- local new_win = vim.api.nvim_open_win(vim.api.nvim_win_get_buf(win), false, {
  --   win = win,
  --   vertical = true,
  -- })
  vim.api.nvim_win_set_config(new_win, {
    win = win,
    vertical = true,
  })
  vim.api.nvim_win_close(win, false)
  vim.api.nvim_win_set_config(new_win, config)
  -- vim.api.nvim_win_set_cursor(new_win, cursor)

  vim.api.nvim_win_call(new_win, function()
    vim.fn.winrestview(view)
  end)
  -- vim.api.nvim_set_current_win()
  -- vim.fn.winrestview(view)
  -- vim.api.nvim_set_current_win(current_win)
end

local copy_buf_data = nil
function M.copy_buf(winid)
  winid = winid or 0
  -- local bufid, cursor = get_bufcursor(winid)
  -- copy_buf_data = { bufid, cursor }
  copy_buf_data = { get_bufcursor(winid) }
  -- M.notify("Yanked buffer: " .. bufid, vim.log.levels.INFO)
  M.notify("Yanked buffer: " .. copy_buf_data[1], vim.log.levels.INFO)
end
function M.paste_buf(winid)
  winid = winid or 0
  if copy_buf_data == nil then
    M.notify("No currently yanked buffer", vim.log.levels.ERROR)
    return
  end

  local bufid, cursor = unpack(copy_buf_data)
  if not vim.api.nvim_buf_is_valid(bufid) then
    M.notify("Yanked buffer is not valid", vim.log.levels.ERROR)
    return
  end

  -- set_bufcursor(winid, bufid, cursor)
  set_bufcursor(winid, unpack(copy_buf_data))
end

function M.duplicate_window(source, target)
  set_bufcursor(target, get_bufcursor(source))
  -- vim.api.nvim_win_set_config(target, vim.api.nvim_win_get_config(source))
end

function M.swap_windows(winid1, winid2)
  local data1 = { get_bufcursor(winid1) }
  local data2 = { get_bufcursor(winid2) }
  set_bufcursor(winid2, unpack(data1))
  set_bufcursor(winid1, unpack(data2))
end

function M.replace_window(source, target)
  M.duplicate_window(source, target)
  vim.api.nvim_win_close(source, false)
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

local function get_splitdir()
  local dir = vim.fn.getcharstr()
  local dirmap = { h = "left", j = "below", k = "above", l = "right" }
  local splitdir = dirmap[dir]
  return splitdir
end

local function do_split(source, target, opts)
  opts = vim.tbl_deep_extend("force", {
    enter = true,
  }, opts or {})

  local splitdir = get_splitdir()
  if not splitdir then
    return nil
  end

  -- local temp = vim.api.nvim_create_buf(false, true)
  -- local temp = vim.api.nvim_get_current_buf()
  local temp = vim.api.nvim_win_get_buf(source)
  local win = vim.api.nvim_open_win(temp, opts.enter, {
    -- relative = "editor",
    -- width = 100,
    -- height = 50,
    -- row = 20,
    -- col = 40,
    -- win = target,
    win = -1,
    vertical = true,
    -- split = splitdir,
  })

  vim.api.nvim_win_set_config(win, {
    win = target,
    split = splitdir,
  })

  -- M.duplicate_window(source, win)

  return win
end

local function move_split(source, target, dir)
  local opts = {}
  opts.vertical = dir == "left" or dir == "right"
  opts.rightbelow = dir == "right" or dir == "below"

  vim.fn.win_splitmove(source, target, opts)
end

M.win_duplicate_select_new_split = M.wrap_toggle_floating(function()
  local source = vim.api.nvim_get_current_win()
  local target = M.picker_prompt()
  if not target then
    return
  end

  local splitdir = get_splitdir()
  if not splitdir then
    return nil
  end

  local source_config = vim.api.nvim_win_get_config(source)
  local split
  if source_config.split == "left" or source_config.split == "right" then
    split = "above"
  else
    split = "left"
  end
  local duplicate = vim.api.nvim_open_win(vim.api.nvim_win_get_buf(source), false, {
    win = source,
    split = split,
    -- split = "above",
    -- vertical = true,
    -- win = target,
    -- split = splitdir
  })

  move_split(duplicate, target, splitdir)

  vim.api.nvim_win_set_config(source, source_config)

  return duplicate
  -- return do_split(source, target, { enter = false })
end)

M.win_move_select_new_split = M.wrap_toggle_floating(function()
  local source = vim.api.nvim_get_current_win()
  local target = M.picker_prompt({ current = false })
  if not target then
    return
  end

  local splitdir = get_splitdir()
  if not splitdir then
    return nil
  end

  move_split(source, target, splitdir)

  return source

  -- vim.api.nvim_win_set_config(source, {
  --   win = target,
  --   split = splitdir,
  -- })

  -- local win = do_split(source, target)
  --
  -- if win then
  --   -- TODO: also set current window to the new one
  --   vim.api.nvim_win_close(source, false)
  --   return win
  -- else
  --   return nil
  -- end
end)

M.win_is_swappable = function(win) end

M.win_replace_select = function(floating)
  floating = floating == true
  local target = M.picker_prompt({ floating = floating })
  if not target then
    return
  end

  M.replace_window(vim.api.nvim_get_current_win(), target)
  return target
end

M.win_swap_select = function(floating, follow)
  floating = floating == true
  follow = follow ~= false

  local target = M.picker_prompt({ floating = floating, current = false })
  if not target then
    return
  end

  M.swap_windows(vim.api.nvim_get_current_win(), target)

  if follow then
    vim.api.nvim_set_current_win(target)
  end

  return target
end

M.win_select = function(floating)
  floating = floating == true

  local target = M.picker_prompt({ floating = floating })
  if not target then
    return
  end

  vim.api.nvim_set_current_win(target)
  return target
end

return M
