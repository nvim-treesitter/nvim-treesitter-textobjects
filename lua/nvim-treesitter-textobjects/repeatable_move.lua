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

--- move_fn's first argument must be a table of options, and it should include a `forward` boolean
--- indicating whether to move forward (true) or backward (false)
---
---@param move_fn function
---@param opts table
---@param ... any
---@return boolean
local set_last_move = function(move_fn, opts, ...)
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
    set_last_move(move_fn, opts, ...)
    move_fn(opts, ...)
  end
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
        vim.cmd.normal { args = { vim.v.count1, ";" }, bang = true }
      else
        vim.cmd.normal { args = { vim.v.count1, "," }, bang = true }
      end
    elseif M.last_move.func == "F" or M.last_move.func == "T" then
      if opts.forward then
        vim.cmd.normal { args = { vim.v.count1, "," }, bang = true }
      else
        vim.cmd.normal { args = { vim.v.count1, ";" }, bang = true }
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

return M
