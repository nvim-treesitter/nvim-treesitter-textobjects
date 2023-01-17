local ts_utils = require "nvim-treesitter.ts_utils"
local attach = require "nvim-treesitter.textobjects.attach"
local shared = require "nvim-treesitter.textobjects.shared"
local repeatable_move = require "nvim-treesitter.textobjects.repeatable_move"
local queries = require "nvim-treesitter.query"
local configs = require "nvim-treesitter.configs"
local parsers = require "nvim-treesitter.parsers"

local M = {}

local function move(opts)
  -- opts includes query_strings_regex, query_group, forward, start, winid
  -- start: bool or nil. If true, choose the start of the node, and false is for the end.
  -- If nil, it considers both and chooses the closer side.
  local query_strings_regex = shared.make_query_strings_table(opts.query_strings_regex)
  local query_group = opts.query_group or "textobjects"
  local forward = opts.forward
  local starts
  if opts.start == nil then
    starts = { true, false }
  else
    if opts.start then
      starts = { true }
    else
      starts = { false }
    end
  end
  local winid = opts.winid or vim.api.nvim_get_current_win()

  local bufnr = vim.api.nvim_win_get_buf(winid)
  local query_strings =
    shared.get_query_strings_from_regex(query_strings_regex, query_group, parsers.get_buf_lang(bufnr))

  local config = configs.get_module "textobjects.move"

  -- score is a byte position.
  local function scoring_function(start_, match)
    local score, _
    if start_ then
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

  local function filter_function(start_, match)
    local range = { match.node:range() }
    local row, col = unpack(vim.api.nvim_win_get_cursor(winid))
    row = row - 1 -- nvim_win_get_cursor is (1,0)-indexed

    if not start_ then
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

  for _ = 1, vim.v.count1 do
    local best_match
    local best_score
    local best_start
    for _, query_string in ipairs(query_strings) do
      for _, start_ in ipairs(starts) do
        local current_match = queries.find_best_match(bufnr, query_string, query_group, function(match)
          return filter_function(start_, match)
        end, function(match)
          return scoring_function(start_, match)
        end)

        if current_match then
          local score = scoring_function(start_, current_match)
          if not best_match then
            best_match = current_match
            best_score = score
            best_start = start_
          end
          if score > best_score then
            best_match = current_match
            best_score = score
            best_start = start_
          end
        end
      end
    end
    ts_utils.goto_node(best_match and best_match.node, not best_start, not config.set_jumps)
  end
end

local move_repeatable = repeatable_move.make_repeatable_move(move)

M.goto_next_start = function(query_strings_regex, query_group)
  move_repeatable {
    forward = true,
    start = true,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
M.goto_next_end = function(query_strings_regex, query_group)
  move_repeatable {
    forward = true,
    start = false,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
M.goto_previous_start = function(query_strings_regex, query_group)
  move_repeatable {
    forward = false,
    start = true,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
M.goto_previous_end = function(query_strings_regex, query_group)
  move_repeatable {
    forward = false,
    start = false,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end

M.goto_next = function(query_strings_regex, query_group)
  move_repeatable {
    forward = true,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end
M.goto_previous = function(query_strings_regex, query_group)
  move_repeatable {
    forward = false,
    query_strings_regex = query_strings_regex,
    query_group = query_group,
  }
end

local nxo_mode_functions = {
  "goto_next_start",
  "goto_next_end",
  "goto_previous_start",
  "goto_previous_end",
  "goto_next",
  "goto_previous",
}

M.attach = attach.make_attach(nxo_mode_functions, "move", { "n", "x", "o" })
M.detach = attach.make_detach "move"

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
}

return M
