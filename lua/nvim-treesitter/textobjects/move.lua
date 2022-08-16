local ts_utils = require "nvim-treesitter.ts_utils"
local attach = require "nvim-treesitter.textobjects.attach"
local shared = require "nvim-treesitter.textobjects.shared"
local queries = require "nvim-treesitter.query"
local configs = require "nvim-treesitter.configs"

local M = {}

local function move(query_strings, forward, start, winid)
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

M.goto_next_start = function(query_strings)
  move(query_strings, "forward", "start")
end
M.goto_next_end = function(query_strings)
  move(query_strings, "forward", not "start")
end
M.goto_previous_start = function(query_strings)
  move(query_strings, not "forward", "start")
end
M.goto_previous_end = function(query_strings)
  move(query_strings, not "forward", not "start")
end

local normal_mode_functions = { "goto_next_start", "goto_next_end", "goto_previous_start", "goto_previous_end" }

M.attach = attach.make_attach(normal_mode_functions, "move")
M.detach = attach.make_detach(normal_mode_functions, "move")

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
