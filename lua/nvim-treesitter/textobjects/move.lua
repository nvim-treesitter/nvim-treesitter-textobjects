local ts_utils = require'nvim-treesitter.ts_utils'
local attach = require'nvim-treesitter.textobjects.attach'
local queries = require'nvim-treesitter.query'

local M = {}

local function move(query_string, forward, start, bufnr)
  local bufnr = bufnr or vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local function filter_function(match)
    local range = {match.node:range()}
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

  local match = queries.find_best_match(bufnr, query_string, 'textobjects', filter_function, scoring_function)
  ts_utils.goto_node(match and match.node, not start)
end

-- luacheck: push ignore 631
M.goto_next_start = function(query_string) move(query_string, 'forward', 'start') end
M.goto_next_end = function(query_string) move(query_string, 'forward', not 'start') end
M.goto_previous_start = function(query_string) move(query_string, not 'forward', 'start') end
M.goto_previous_end = function(query_string) move(query_string, not 'forward', not 'start') end
-- luacheck: pop

local normal_mode_functions = {"goto_next_start",
                               "goto_next_end",
                               "goto_previous_start",
                               "goto_previous_end"}

M.attach = attach.make_attach(normal_mode_functions, "move")
M.deattach = attach.make_detach(normal_mode_functions, "move")

return M
