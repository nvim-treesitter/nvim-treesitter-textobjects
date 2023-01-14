local ts_utils = require "nvim-treesitter.ts_utils"
local attach = require "nvim-treesitter.textobjects.attach"
local shared = require "nvim-treesitter.textobjects.shared"
local queries = require "nvim-treesitter.query"
local configs = require "nvim-treesitter.configs"

local M = {}

M.last_move = nil
-- { func = move, args = { ... } }
-- { func = builtin_find, args = { ... } }
-- register any other function, but make sure the the first args is `forward` boolean.

-- If you are a plugin developer,
-- you can register your own independent move functions using this
-- even if they are not related to treesitter-textobjects.
-- move_fn's first argument must be a boolean indicating whether to move forward (true) or backward (false)
-- Then you can use four functions:
--   M.repeat_last_move
--   M.repeat_last_move_opposite
--   M.repeat_last_move_next
--   M.repeat_last_move_previous
function M.make_repeatable_move(move_fn)
  return function(...)
    M.last_move = { func = move_fn, args = { ... } } -- remember that the first args should be `forward` boolean
    move_fn(...)
  end
end

local function move(forward, query_strings, start, winid)
  query_strings = shared.make_query_strings_table(query_strings)
  winid = winid or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)

  local config = configs.get_module "textobjects.move"
  local function filter_function(match)
    local range = { match.node:range() }
    local row, col = unpack(vim.api.nvim_win_get_cursor(winid))
    row = row - 1 -- nvim_win_get_cursor is (1,0)-indexed

    if not start then
      if range[4] == 0 then
        range[1] = range[3] - 1
        range[2] = range[4]
      else
        range[1] = range[3]
        range[2] = range[4] - 1
      end
    end
    if forward then
      return range[1] > row or (range[1] == row and range[2] > col)
    else
      return range[1] < row or (range[1] == row and range[2] < col)
    end
  end

  local function scoring_function(match)
    local score, _
    if start then
      _, _, score = match.node:start()
    else
      _, _, score = match.node:end_()
    end
    if forward then
      return -score
    else
      return score
    end
  end

  for _ = 1, vim.v.count1 do
    local best_match
    local best_score
    for _, query_string in ipairs(query_strings) do
      local current_match =
        queries.find_best_match(bufnr, query_string, "textobjects", filter_function, scoring_function)
      if current_match then
        local score = scoring_function(current_match)
        if not best_match then
          best_match = current_match
          best_score = score
        end
        if score > best_score then
          best_match = current_match
          best_score = score
        end
      end
    end
    ts_utils.goto_node(best_match and best_match.node, not start, not config.set_jumps)
  end
end

local move_repeatable = M.make_repeatable_move(move)

M.goto_next_start = function(query_strings)
  move_repeatable("forward", query_strings, "start")
end
M.goto_next_end = function(query_strings)
  move_repeatable("forward", query_strings, not "start")
end
M.goto_previous_start = function(query_strings)
  move_repeatable(not "forward", query_strings, "start")
end
M.goto_previous_end = function(query_strings)
  move_repeatable(not "forward", query_strings, not "start")
end

-- implements naive f, F, t, T with repeat support
local function builtin_find(forward, inclusive, char, repeating, winid)
  -- forward = true -> f, t
  -- inclusive = false -> t, T
  -- if repeating with till (t or T, inclusive = false) then search from the next character
  -- returns nil if cancelled or char
  char = char or vim.fn.nr2char(vim.fn.getchar())
  repeating = repeating or false
  winid = winid or vim.api.nvim_get_current_win()

  if char == vim.fn.nr2char(27) then
    -- escape
    return nil
  end

  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(winid)

  -- find the count-th occurrence of the char in the line
  local found
  for _ = 1, vim.v.count1 do
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

  -- move to the found position
  vim.api.nvim_win_set_cursor(winid, { cursor[1], cursor[2] })
  return char
end

-- We are not using M.make_repeatable_move and instead registering at M.last_move manually
-- because we don't want to behave the same way as the first movement.
-- For example, we want to repeat the search character given to f, F, t, T.
-- Also, we want to be able to to find the next occurence when using t, T with repeat, excluding the current position.
M.builtin_f = function()
  local char = builtin_find("forward", "inclusive")
  if builtin_find ~= nil then
    M.last_move = { func = builtin_find, args = { "forward", "inclusive", char, "repeating" } }
  end
end

M.builtin_F = function()
  local char = builtin_find(not "forward", "inclusive")
  if builtin_find ~= nil then
    M.last_move = { func = builtin_find, args = { not "forward", "inclusive", char, "repeating" } }
  end
end

M.builtin_t = function()
  local char = builtin_find("forward", not "inclusive")
  if builtin_find ~= nil then
    M.last_move = { func = builtin_find, args = { "forward", not "inclusive", char, "repeating" } }
  end
end

M.builtin_T = function()
  local char = builtin_find(not "forward", not "inclusive")
  if builtin_find ~= nil then
    M.last_move = { func = builtin_find, args = { not "forward", not "inclusive", char, "repeating" } }
  end
end

M.repeat_last_move = function()
  if M.last_move then
    M.last_move.func(unpack(M.last_move.args))
  end
end

M.repeat_last_move_opposite = function()
  if M.last_move then
    local args = { unpack(M.last_move.args) } -- copy the table
    args[1] = not args[1] -- reverse the direction
    M.last_move.func(unpack(args))
  end
end

M.repeat_last_move_next = function()
  if M.last_move then
    local args = { unpack(M.last_move.args) } -- copy the table
    args[1] = true -- set the direction to forward
    M.last_move.func(unpack(args))
  end
end

M.repeat_last_move_previous = function()
  if M.last_move then
    local args = { unpack(M.last_move.args) } -- copy the table
    args[1] = false -- set the direction to backward
    M.last_move.func(unpack(args))
  end
end

local nxo_mode_functions = { "goto_next_start", "goto_next_end", "goto_previous_start", "goto_previous_end" }

M.attach = attach.make_attach(nxo_mode_functions, "move", { "n", "x", "o" })
M.detach = attach.make_detach(nxo_mode_functions, "move", { "n", "x", "o" })

M.commands = {
  TSTextobjectGotoNextStart = {
    run = M.goto_next_start,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
  TSTextobjectGotoNextEnd = {
    run = M.goto_next_end,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
  TSTextobjectGotoPreviousStart = {
    run = M.goto_previous_start,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
  TSTextobjectGotoPreviousEnd = {
    run = M.goto_previous_end,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
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
