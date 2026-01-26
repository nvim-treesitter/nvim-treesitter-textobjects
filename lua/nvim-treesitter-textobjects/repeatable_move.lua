local M = {}

---@class TSTextObjects.MovefFtTOpts
---@field forward boolean If true, move forward, and false is for backward.

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

--- Handle inclusive/exclusive behavior of the `;` and `,` motions used after fFtT motions.
---
--- Meaning, that the following operator-pending calls (with `y` operator in this case) behave
--- exactly like in plain NeoVim:
---
--- - `yfn` and `y;` - inclusive.
--- - `yfn` and `y,` - exclusive.
--- - `yFn` and `y;` - exclusive.
--- - `yFn` and `y,` - inclusive.
--- - `ytn` and `y;` - inclusive.
--- - `ytn` and `y,` - exclusive.
--- - `yTn` and `y;` - exclusive.
--- - `yTn` and `y,` - inclusive.
---@param opts TSTextObjects.MovefFtTOpts
---@return nil
local function repeat_last_move_fFtT(opts)
  local motion = ''

  if M.last_move.func == 'f' or M.last_move.func == 't' then
    motion = opts.forward and ';' or ','
  else
    motion = opts.forward and ',' or ';'
  end

  -- This changes operator-pending (no) mode to operator-pending-visual (nov) mode to include last
  -- character in the region when going forward. In other words, going forward will include current
  -- cursor and found character.
  local inclusive = (opts.forward and vim.api.nvim_get_mode().mode == 'no') and 'v' or ''

  local cursor_before = vim.api.nvim_win_get_cursor(0)
  vim.cmd([[normal! ]] .. inclusive .. vim.v.count1 .. motion)
  local cursor_after = vim.api.nvim_win_get_cursor(0)

  -- Handle a use case when a motion in an operator-pending doesn't visually selects any text
  -- region. Without "turning off" the `v` a single character at the cursor's position is selected.
  --
  -- For example: `yfn` and `y2;` at the end of the line.
  if inclusive == 'v' and vim.deep_equal(cursor_before, cursor_after) then
    vim.cmd([[normal! ]] .. inclusive)
  end
end

---@param opts_extend TSTextObjects.MoveOpts?
M.repeat_last_move = function(opts_extend)
  if not M.last_move then
    return
  end
  local opts = vim.tbl_deep_extend('force', M.last_move.opts, opts_extend or {})
  if vim.list_contains({ 'f', 'F', 't', 'T' }, M.last_move.func) then
    repeat_last_move_fFtT({ forward = opts.forward })
  else
    -- we assume other textobjects (move) already handle operator-pending mode correctly
    M.last_move.func(opts, unpack(M.last_move.additional_args))
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
