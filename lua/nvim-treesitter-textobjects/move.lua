local api = vim.api

local shared = require('nvim-treesitter-textobjects.shared')
local repeatable_move = require('nvim-treesitter-textobjects.repeatable_move')
local global_config = require('nvim-treesitter-textobjects.config')

---@param range Range4?
---@param goto_end boolean
---@param avoid_set_jump boolean
local function goto_node(range, goto_end, avoid_set_jump)
  if not range then
    return
  end

  if not avoid_set_jump then
    vim.cmd("normal! m'")
  end
  ---@type integer, integer, integer, integer
  local start_row, start_col, end_row, end_col = unpack(range)

  -- Enter visual mode if we are in operator pending mode
  -- If we don't do this, it will miss the last character.
  local mode = api.nvim_get_mode()
  if mode.mode == 'no' then
    vim.cmd('normal! v')
  end

  -- Position is 1, 0 indexed.
  if not goto_end then
    api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  else
    api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
  end
end

local M = {}

---@param opts TSTextObjects.MoveOpts
---@param query_strings string[]|string
---@param query_group? string
local function move(opts, query_strings, query_group)
  query_group = query_group or 'textobjects'
  if type(query_strings) == 'string' then
    query_strings = { query_strings }
  end

  local winid = api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)

  local forward = opts.forward
  local starts ---@type {[1]: boolean, [2]: boolean}
  if opts.start == nil then
    starts = { true, false }
  else
    if opts.start then
      starts = { true }
    else
      starts = { false }
    end
  end

  local config = global_config.move

  -- score is a byte position.
  ---
  ---@param start_ boolean
  ---@param range Range6
  ---@return integer
  local function scoring_function(start_, range)
    local score ---@type integer
    if start_ then
      score = range[3]
    else
      score = range[6]
    end
    if forward then
      return -score
    else
      return score
    end
  end

  ---@param start_ boolean
  ---@param range Range6
  ---@return boolean
  local function filter_function(start_, range)
    local row, col = unpack(api.nvim_win_get_cursor(winid)) --[[@as integer, integer]]
    row = row - 1 -- nvim_win_get_cursor is (1,0)-indexed
    ---@type integer, integer, integer, integer, integer, integer
    local start_row, start_col, _, end_row, end_col, _ = unpack(range)

    if not start_ then
      if end_col == 0 then
        start_row = end_row - 1
        start_col = end_col
      else
        start_row = end_row
        start_col = end_col - 1 ---@type integer
      end
    end
    if forward then
      return start_row > row or (start_row == row and start_col > col)
    else
      return start_row < row or (start_row == row and start_col < col)
    end
  end

  for _ = 1, vim.v.count1 do
    local best_range ---@type Range6?
    local best_score ---@type integer
    local best_start ---@type boolean
    for _, query_string in ipairs(query_strings) do
      for _, start_ in ipairs(starts) do
        local current_range = shared.find_best_range(
          bufnr,
          query_string,
          query_group,
          function(range)
            return filter_function(start_, range)
          end,
          function(range)
            return scoring_function(start_, range)
          end
        )

        if current_range then
          local score = scoring_function(start_, current_range)
          if not best_range then
            best_range = current_range
            best_score = score
            best_start = start_
          end
          if score > best_score then
            best_range = current_range
            best_score = score
            best_start = start_
          end
        end
      end
    end
    goto_node(best_range and shared.torange4(best_range), not best_start, not config.set_jumps)
  end
end

---@type fun(opts: TSTextObjects.MoveOpts, query_strings: string[]|string, query_group?: string)
local move_repeatable = repeatable_move.make_repeatable_move(move)

---@param query_strings string|string[]
---@param query_group? string
M.goto_next_start = function(query_strings, query_group)
  move_repeatable({
    forward = true,
    start = true,
  }, query_strings, query_group)
end
---@param query_strings string|string[]
---@param query_group? string
M.goto_next_end = function(query_strings, query_group)
  move_repeatable({
    forward = true,
    start = false,
  }, query_strings, query_group)
end
---@param query_strings string|string[]
---@param query_group? string
M.goto_previous_start = function(query_strings, query_group)
  move_repeatable({
    forward = false,
    start = true,
  }, query_strings, query_group)
end
---@param query_strings string|string[]
---@param query_group? string
M.goto_previous_end = function(query_strings, query_group)
  move_repeatable({
    forward = false,
    start = false,
  }, query_strings, query_group)
end

---@param query_strings string|string[]
---@param query_group? string
M.goto_next = function(query_strings, query_group)
  move_repeatable({
    forward = true,
  }, query_strings, query_group)
end
---@param query_strings string|string[]
---@param query_group? string
M.goto_previous = function(query_strings, query_group)
  move_repeatable({
    forward = false,
    query_strings = query_strings,
    query_group = query_group,
  }, query_strings, query_group)
end

return M
