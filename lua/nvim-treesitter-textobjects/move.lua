local api = vim.api
local ts = vim.treesitter

local shared = require "nvim-treesitter-textobjects.shared"
local repeatable_move = require "nvim-treesitter-textobjects.repeatable_move"
local global_config = require "nvim-treesitter-textobjects.config"

---@param range TSTextObjects.Range?
---@param goto_end boolean
---@param avoid_set_jump boolean
local function goto_node(range, goto_end, avoid_set_jump)
  if not range then
    return
  end

  if not avoid_set_jump then
    shared.set_jump()
  end
  local vim_range = { range:to_vim_range() } ---@type Range4
  ---@type table<number>
  local position
  if not goto_end then
    position = { vim_range[1], vim_range[2] }
  else
    position = { vim_range[3], vim_range[4] }
  end

  -- Enter visual mode if we are in operator pending mode
  -- If we don't do this, it will miss the last character.
  local mode = vim.api.nvim_get_mode()
  if mode.mode == "no" then
    vim.cmd "normal! v"
  end

  -- Position is 1, 0 indexed.
  api.nvim_win_set_cursor(0, { position[1], position[2] - 1 })
end

local M = {}

---@class TSTextObjects.MoveOpts
---@field query_strings_regex string[]|string
---@field query_group? string
---@field forward boolean
---@field start? boolean If true, choose the start of the node, and false is for the end.
---@field winid? integer

---@param opts TSTextObjects.MoveOpts
local function move(opts)
  local query_group = opts.query_group or "textobjects"

  local query_strings_pattern = shared.make_query_strings_table(opts.query_strings_regex)
  local winid = opts.winid or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local query_strings = shared.get_query_strings_from_pattern(
    query_strings_pattern,
    query_group,
    ts.language.get_lang(vim.bo[bufnr].filetype)
  )

  if not shared.check_support(api.nvim_get_current_buf(), query_group, query_strings) then
    vim.notify(
      ("The filetype `%s` does not support the textobjects `%s` for the query file `%s`"):format(
        vim.bo.filetype,
        vim.inspect(query_strings),
        query_group
      ),
      vim.log.levels.WARN
    )
    return
  end

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
  ---@param range TSTextObjects.Range
  ---@return integer
  local function scoring_function(start_, range)
    local score ---@type integer
    if start_ then
      score = range.start_byte
    else
      score = range.end_byte
    end
    if forward then
      return -score
    else
      return score
    end
  end

  ---@param start_ boolean
  ---@param range TSTextObjects.Range
  ---@return boolean
  local function filter_function(start_, range)
    local range4 = range:range4()
    local row, col = unpack(vim.api.nvim_win_get_cursor(winid)) --[[@as integer, integer]]
    row = row - 1 -- nvim_win_get_cursor is (1,0)-indexed

    if not start_ then
      if range4[4] == 0 then
        range4[1] = range4[3] - 1
        range4[2] = range4[4]
      else
        range4[1] = range4[3]
        range4[2] = range4[4] - 1
      end
    end
    if forward then
      return range4[1] > row or (range4[1] == row and range4[2] > col)
    else
      return range4[1] < row or (range4[1] == row and range4[2] < col)
    end
  end

  for _ = 1, vim.v.count1 do
    local best_range ---@type TSTextObjects.Range
    local best_score ---@type integer
    local best_start ---@type boolean
    for _, query_string in ipairs(query_strings) do
      for _, start_ in ipairs(starts) do
        local current_range = shared.find_best_range(bufnr, query_string, query_group, function(range)
          return filter_function(start_, range)
        end, function(range)
          return scoring_function(start_, range)
        end)

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
    goto_node(best_range and best_range.range, not best_start, not config.set_jumps)
  end
end

---@type fun(opts: TSTextObjects.MoveOpts)
local move_repeatable = repeatable_move.make_repeatable_move(move)

---@param query_strings_regex string|string[]
---@param query_group? string
M.goto_next_start = function(query_strings_regex, query_group)
  move_repeatable {
    forward = true,
    start = true,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
---@param query_strings_regex string|string[]
---@param query_group? string
M.goto_next_end = function(query_strings_regex, query_group)
  move_repeatable {
    forward = true,
    start = false,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
---@param query_strings_regex string|string[]
---@param query_group? string
M.goto_previous_start = function(query_strings_regex, query_group)
  move_repeatable {
    forward = false,
    start = true,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
---@param query_strings_regex string|string[]
---@param query_group? string
M.goto_previous_end = function(query_strings_regex, query_group)
  move_repeatable {
    forward = false,
    start = false,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end

---@param query_strings_regex string|string[]
---@param query_group? string
M.goto_next = function(query_strings_regex, query_group)
  move_repeatable {
    forward = true,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
---@param query_strings_regex string|string[]
---@param query_group? string
M.goto_previous = function(query_strings_regex, query_group)
  move_repeatable {
    forward = false,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end

return M
