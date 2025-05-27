local M = {}

---@class TSTextObjects.MoveOpts
---@field forward boolean If true, move forward, and false is for backward.
---@field start? boolean If true, choose the start of the node, and false is for the end.

---@alias TSTextObjects.MoveFunction fun(opts: TSTextObjects.MoveOpts, ...: any)

---@class TSTextObjects.RepeatableMove
---@field func string | TSTextObjects.MoveFunction
---@field opts TSTextObjects.MoveOpts
---@field additional_args table

---@type TSTextObjects.RepeatableMove
M.last_move = nil

--- Make move function repeatable. Creates a wrapper that takes a TSTextObjects.MoveOpts table,
--- stores them, and executes the move.
---
---@param move_fn TSTextObjects.MoveFunction
---@return TSTextObjects.MoveFunction
M.make_repeatable_move = function(move_fn)
  return function(opts, ...)
    M.last_move = { func = move_fn, opts = vim.deepcopy(opts), additional_args = { ... } }
    move_fn(opts, ...)
  end
end

---@param opts_extend TSTextObjects.MoveOpts?
---@return string?
M.repeat_last_move = function(opts_extend)
  if not M.last_move then
    return
  end
  local opts = vim.tbl_deep_extend('force', M.last_move.opts, opts_extend or {})
  if M.last_move.func == 'f' or M.last_move.func == 't' then
    return opts.forward and ';' or ','
  elseif M.last_move.func == 'F' or M.last_move.func == 'T' then
    return opts.forward and ',' or ';'
  else
    return M.last_move.func(opts, unpack(M.last_move.additional_args))
  end
end

M.repeat_last_move_opposite = function()
  return M.last_move and M.repeat_last_move({ forward = not M.last_move.opts.forward })
end

M.repeat_last_move_next = function()
  return M.repeat_last_move({ forward = true })
end

M.repeat_last_move_previous = function()
  return M.repeat_last_move({ forward = false })
end

-- NOTE: map builtin_f_expr, builtin_F_expr, builtin_t_expr, builtin_T_expr with { expr = true }.
--
-- We are not using M.make_repeatable_move or M.set_last_move and instead registering at M.last_move manually
-- because move_fn is not a function (but string f, F, t, T).
-- We don't want to execute a move function, but instead return an expression (f, F, t, T).
M.builtin_f_expr = function()
  M.last_move = {
    func = 'f',
    opts = { forward = true },
    additional_args = {},
  }
  return 'f'
end

M.builtin_F_expr = function()
  M.last_move = {
    func = 'F',
    opts = { forward = false },
    additional_args = {},
  }
  return 'F'
end

M.builtin_t_expr = function()
  M.last_move = {
    func = 't',
    opts = { forward = true },
    additional_args = {},
  }
  return 't'
end

M.builtin_T_expr = function()
  M.last_move = {
    func = 'T',
    opts = { forward = false },
    additional_args = {},
  }
  return 'T'
end

return M
