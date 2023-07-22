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

M.last_move = nil
-- { func = move, opts = { ... }, additional_args = {} }
-- { func = builtin_find, opts = { ... }, additional_args = {} }
-- register any other function, but make sure the the first args is an opts table with a `forward` boolean.
-- prefer to set using M.set_last_move

M.clear_last_move = function()
  M.last_move = nil
end

-- move_fn's first argument must be a table of options, and it should include a `forward` boolean
-- indicating whether to move forward (true) or backward (false)
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

-- Pass a function that takes a table of options (should include `forward` boolean)
-- and it returns the same function that is magically repeatable
M.make_repeatable_move = function(move_fn)
  return function(opts, ...)
    M.set_last_move(move_fn, opts, ...)
    move_fn(opts, ...)
  end
end

-- Alternative:
-- Get a movement function pair (forward, backward) and turn them into two repeatable movement functions
-- They don't need to have the first argument as a table of options
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

M.repeat_last_move = function(opts_extend)
  if M.last_move then
    local opts
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

    M.last_move.func(opts, unpack(M.last_move.additional_args))
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

-- implements naive f, F, t, T with repeat support
local function builtin_find(opts)
  -- opts include forward, inclusive, char, repeating, winid
  -- forward = true -> f, t
  -- inclusive = false -> t, T
  -- if repeating with till (t or T, inclusive = false) then search from the next character
  -- returns nil if cancelled or char
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
  local count
  if not inclusive and repeating then
    count = math.max(vim.v.count1 - 1, 1)
  else
    count = vim.v.count1
  end

  -- find the count-th occurrence of the char in the line
  local found
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
M.builtin_f = function()
  local opts = { forward = true, inclusive = true }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

M.builtin_F = function()
  local opts = { forward = false, inclusive = true }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

M.builtin_t = function()
  local opts = { forward = true, inclusive = false }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

M.builtin_T = function()
  local opts = { forward = false, inclusive = false }
  local char = builtin_find(opts)
  if char ~= nil then
    opts.char = char
    opts.repeating = true
    M.set_last_move(builtin_find, opts)
  end
end

M.commands = {
  TSTextobjectRepeatLastMove = {
    run = M.repeat_last_move,
  },
  TSTextobjectRepeatLastMoveOpposite = {
    run = M.repeat_last_move_opposite,
  },
  TSTextobjectRepeatLastMoveNext = {
    run = M.repeat_last_move_next,
  },
  TSTextobjectRepeatLastMovePrevious = {
    run = M.repeat_last_move_previous,
  },
  TSTextobjectBuiltinf = {
    run = M.builtin_f,
  },
  TSTextobjectBuiltinF = {
    run = M.builtin_F,
  },
  TSTextobjectBuiltint = {
    run = M.builtin_t,
  },
  TSTextobjectBuiltinT = {
    run = M.builtin_T,
  },
}

return M
