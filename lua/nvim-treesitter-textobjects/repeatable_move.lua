-- If you are a plugin developer (or just want to make other movement plugins repeatable),
-- you can register your own independent move functions
-- even if they are not related to treesitter-textobjects.
-- Use one of the followings:
--   M.make_repeatable_move(move_fn)
--   M.make_repeatable_move_pair(forward_move_fn, backward_move_fn)
--   M.set_last_move(move_fn, opts, ...)
--
-- Then you can use four functions to repeat the last movement:
--   M.repeat_last_move
--   M.repeat_last_move_opposite
--   M.repeat_last_move_next
--   M.repeat_last_move_previous

local M = {}

---@class TSTextObjects.RepeatableMove
---@field func string | function
---@field opts table
---@field additional_args table

---@type TSTextObjects.RepeatableMove
-- { func = move, opts = { ... }, additional_args = {} }
-- { func = "f", opts = { ... }, additional_args = {} }
-- register any other function, but make sure the the first args is an opts table with a `forward` boolean.
-- prefer to set using M.set_last_move
M.last_move = nil

M.clear_last_move = function()
  M.last_move = nil
end

--- move_fn's first argument must be a table of options, and it should include a `forward` boolean
--- indicating whether to move forward (true) or backward (false)
---
---@param move_fn function
---@param opts table
---@param ... any
---@return boolean
M.set_last_move = function(move_fn, opts, ...)
  if type(move_fn) ~= "function" then
    vim.notify(
      "nvim-treesitter-textobjects: move_fn has to be a function but got " .. vim.inspect(move_fn),
      vim.log.levels.ERROR
    )
    return false
  end

  if type(opts) ~= "table" then
    vim.notify(
      "nvim-treesitter-textobjects: opts has to be a table but got " .. vim.inspect(opts),
      vim.log.levels.ERROR
    )
    return false
  elseif opts.forward == nil then
    vim.notify(
      "nvim-treesitter-textobjects: opts has to include a `forward` boolean but got " .. vim.inspect(opts),
      vim.log.levels.ERROR
    )
    return false
  end

  M.last_move = { func = move_fn, opts = vim.deepcopy(opts), additional_args = { ... } }
  return true
end

--- Pass a function that takes a table of options (should include `forward` boolean)
--- and it returns the same function that is magically repeatable
---
---@param move_fn function
---@return fun(opts: table, ...: any)
M.make_repeatable_move = function(move_fn)
  return function(opts, ...)
    M.set_last_move(move_fn, opts, ...)
    move_fn(opts, ...)
  end
end

-- Alternative:
-- Get a movement function pair (forward, backward) and turn them into two repeatable movement functions
-- They don't need to have the first argument as a table of options
---@param forward_move_fn function
---@param backward_move_fn function
---@return fun(...: any) repeatable_forward_move_fn
---@return fun(...: any) repeatable_backward_move_fn
M.make_repeatable_move_pair = function(forward_move_fn, backward_move_fn)
  local general_repeatable_move_fn = function(opts, ...)
    if opts.forward then
      forward_move_fn(...)
    else
      backward_move_fn(...)
    end
  end

  local repeatable_forward_move_fn = function(...)
    M.set_last_move(general_repeatable_move_fn, { forward = true }, ...)
    forward_move_fn(...)
  end

  local repeatable_backward_move_fn = function(...)
    M.set_last_move(general_repeatable_move_fn, { forward = false }, ...)
    backward_move_fn(...)
  end

  return repeatable_forward_move_fn, repeatable_backward_move_fn
end

---@param opts_extend table?
---@return boolean
M.repeat_last_move = function(opts_extend)
  if M.last_move then
    local opts ---@type table
    if opts_extend ~= nil then
      if type(opts_extend) ~= "table" then
        vim.notify(
          "nvim-treesitter-textobjects: opts_extend has to be a table but got " .. vim.inspect(opts_extend),
          vim.log.levels.ERROR
        )
        return false
      end

      opts = vim.tbl_deep_extend("force", {}, M.last_move.opts, opts_extend)
    else
      opts = M.last_move.opts
    end

    if M.last_move.func == "f" or M.last_move.func == "t" then
      if opts.forward then
        vim.cmd([[normal! ]] .. vim.v.count1 .. ";")
      else
        vim.cmd([[normal! ]] .. vim.v.count1 .. ",")
      end
    elseif M.last_move.func == "F" or M.last_move.func == "T" then
      if opts.forward then
        vim.cmd([[normal! ]] .. vim.v.count1 .. ",")
      else
        vim.cmd([[normal! ]] .. vim.v.count1 .. ";")
      end
    else
      M.last_move.func(opts, unpack(M.last_move.additional_args))
    end
    return true
  end
  return false
end

M.repeat_last_move_opposite = function()
  return M.last_move and M.repeat_last_move { forward = not M.last_move.opts.forward }
end

M.repeat_last_move_next = function()
  return M.repeat_last_move { forward = true }
end

M.repeat_last_move_previous = function()
  return M.repeat_last_move { forward = false }
end

-- NOTE: map builtin_f_expr, builtin_F_expr, builtin_t_expr, builtin_T_expr with { expr = true }.
--
-- We are not using M.make_repeatable_move or M.set_last_move and instead registering at M.last_move manually
-- because move_fn is not a function (but string f, F, t, T).
-- We don't want to execute a move function, but instead return an expression (f, F, t, T).
M.builtin_f_expr = function()
  M.last_move = {
    func = "f",
    opts = { forward = true },
    additional_args = {},
  }
  return "f"
end

M.builtin_F_expr = function()
  M.last_move = {
    func = "F",
    opts = { forward = false },
    additional_args = {},
  }
  return "F"
end

M.builtin_t_expr = function()
  M.last_move = {
    func = "t",
    opts = { forward = true },
    additional_args = {},
  }
  return "t"
end

M.builtin_T_expr = function()
  M.last_move = {
    func = "T",
    opts = { forward = false },
    additional_args = {},
  }
  return "T"
end

---@class TSTextObjects.BuiltinFindOpts
---@field forward boolean forward = true -> f, t
---@field inclusive boolean inclusive = false -> t, T
---@field char? string
---@field repeating? boolean if repeating with till (t or T, inclusive = false) then search from the next character
---@field winid? integer

-- implements naive f, F, t, T with repeat support
---@deprecated
---@param opts TSTextObjects.BuiltinFindOpts
---@return string? char
local function builtin_find(opts)
  local forward = opts.forward
  local inclusive = opts.inclusive
  local char = opts.char or vim.fn.nr2char(vim.fn.getchar())
  local repeating = opts.repeating or false
  local winid = opts.winid or vim.api.nvim_get_current_win()

  if char == vim.fn.nr2char(27) then
    -- escape
    return nil
  end

  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(winid)

  -- count works like this with builtin vim motions.
  -- weird, but we're matching the behaviour
  local count ---@type integer
  if not inclusive and repeating then
    count = math.max(vim.v.count1 - 1, 1)
  else
    count = vim.v.count1
  end

  -- find the count-th occurrence of the char in the line
  local found ---@type integer?
  for _ = 1, count do
    if forward then
      if not inclusive and repeating then
        cursor[2] = cursor[2] + 1
      end
      found = line:find(char, cursor[2] + 2, true)
    else
      -- reverse find from the cursor position
      if not inclusive and repeating then
        cursor[2] = cursor[2] - 1
      end

      found = line:reverse():find(char, #line - cursor[2] + 1, true)
      if found then
        found = #line - found + 1
      end
    end

    if not found then
      return char
    end

    if forward then
      if not inclusive then
        found = found - 1
      end
    else
      if not inclusive then
        found = found + 1
      end
    end

    cursor[2] = found - 1
    repeating = true -- after the first iteration, search from the next character if not inclusive.
  end

  -- Enter visual mode if we are in operator-pending mode
  -- If we don't do this, it will miss the last character.
  local mode = vim.api.nvim_get_mode()
  if mode.mode == "no" then
    vim.cmd "normal! v"
  end

  -- move to the found position
  vim.api.nvim_win_set_cursor(winid, { cursor[1], cursor[2] })
  return char
end

-- We are not using M.make_repeatable_move and instead registering at M.last_move manually
-- because we don't want to behave the same way as the first movement.
-- For example, we want to repeat the search character given to f, F, t, T.
-- Also, we want to be able to to find the next occurence when using t, T with repeat, excluding the current position.
---@deprecated
M.builtin_f = function()
  vim.notify_once("nvim-treesitter-textobjects: map `builtin_f_expr` with `{expr=true}` instead.", vim.log.levels.WARN)
  local opts = { forward = true, inclusive = true }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

---@deprecated
M.builtin_F = function()
  vim.notify_once("nvim-treesitter-textobjects: map `builtin_F_expr` with `{expr=true}` instead.", vim.log.levels.WARN)
  local opts = { forward = false, inclusive = true }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

---@deprecated
M.builtin_t = function()
  vim.notify_once("nvim-treesitter-textobjects: map `builtin_t_expr` with `{expr=true}` instead.", vim.log.levels.WARN)
  local opts = { forward = true, inclusive = false }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

---@deprecated
M.builtin_T = function()
  vim.notify_once("nvim-treesitter-textobjects: map `builtin_T_expr` with `{expr=true}` instead.", vim.log.levels.WARN)
  local opts = { forward = false, inclusive = false }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

return M
