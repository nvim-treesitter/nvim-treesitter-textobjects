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

-- NOTE: map builtin_f, builtin_F, builtin_t, builtin_T with { expr = true }.
--
-- We are not using M.make_repeatable_move or M.set_last_move and instead registering at M.last_move manually
-- because move_fn is not a function (but string f, F, t, T).
-- We don't want to execute a move function, but instead return an expression (f, F, t, T).
M.builtin_f = function()
  M.last_move = {
    func = "f",
    opts = { forward = true },
    additional_args = {},
  }
  return "f"
end

M.builtin_F = function()
  M.last_move = {
    func = "F",
    opts = { forward = false },
    additional_args = {},
  }
  return "F"
end

M.builtin_t = function()
  M.last_move = {
    func = "t",
    opts = { forward = true },
    additional_args = {},
  }
  return "t"
end

M.builtin_T = function()
  M.last_move = {
    func = "T",
    opts = { forward = false },
    additional_args = {},
  }
  return "T"
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
