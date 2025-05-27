local api = vim.api

local shared = require('nvim-treesitter-textobjects.shared')

---@class TSTextObjects.LspLocation
---@field line integer
---@field character integer

---@param range Range4
---@return lsp.Range
local function to_lsp_range(range)
  ---@type integer, integer, integer, integer
  local start_row, start_col, end_row, end_col = unpack(range)
  return {
    start = {
      line = start_row,
      character = start_col,
    },
    ['end'] = {
      line = end_row,
      character = end_col,
    },
  }
end

---@param range1 Range4
---@param range2 Range4
---@param bufnr integer
---@param cursor_to_second any
local function swap_nodes(range1, range2, bufnr, cursor_to_second)
  if not range1 or not range2 then
    return
  end

  local text1 = api.nvim_buf_get_text(bufnr, range1[1], range1[2], range1[3], range1[4], {})
  local text2 = api.nvim_buf_get_text(bufnr, range2[1], range2[2], range2[3], range2[4], {})

  local lsp_range1 = to_lsp_range(range1)
  local lsp_range2 = to_lsp_range(range2)

  local edit1 = { range = lsp_range1, newText = table.concat(text2, '\n') }
  local edit2 = { range = lsp_range2, newText = table.concat(text1, '\n') }
  vim.lsp.util.apply_text_edits({ edit1, edit2 }, bufnr, 'utf-8')

  if cursor_to_second then
    vim.cmd("normal! m'") -- set jump

    local char_delta = 0
    local line_delta = 0
    if
      lsp_range1['end'].line < lsp_range2.start.line
      or (
        lsp_range1['end'].line == lsp_range2.start.line
        and lsp_range1['end'].character <= lsp_range2.start.character
      )
    then
      line_delta = #text2 - #text1
    end

    if
      lsp_range1['end'].line == lsp_range2.start.line
      and lsp_range1['end'].character <= lsp_range2.start.character
    then
      if line_delta ~= 0 then
        --- why?
        --correction_after_line_change =  -range2.start.character
        --text_now_before_range2 = #(text2[#text2])
        --space_between_ranges = range2.start.character - range1["end"].character
        --char_delta = correction_after_line_change + text_now_before_range2 + space_between_ranges
        --- Equivalent to:
        char_delta = #text2[#text2] - lsp_range1['end'].character

        -- add range1.start.character if last line of range1 (now text2) does not start at 0
        if lsp_range1.start.line == lsp_range2.start.line + line_delta then
          char_delta = char_delta + lsp_range1.start.character
        end
      else
        char_delta = #text2[#text2] - #text1[#text1]
      end
    end

    api.nvim_win_set_cursor(
      api.nvim_get_current_win(),
      { lsp_range2.start.line + 1 + line_delta, lsp_range2.start.character + char_delta }
    )
  end
end

---@param range1 Range6
---@param range2 Range6
local function range_eq(range1, range2)
  local srow1, scol1, _, erow1, ecol1, _ = unpack(range1) ---@type integer, integer, integer, integer, integer, integer
  local srow2, scol2, _, erow2, ecol2, _ = unpack(range2) ---@type integer, integer, integer, integer, integer, integer
  return srow1 == srow2 and scol1 == scol2 and erow1 == erow2 and ecol1 == ecol2
end

---
---@param range Range6
---@param query_string string
---@param query_group string
---@param bufnr integer
---@return Range6?
local next_textobject = function(range, query_string, query_group, bufnr)
  local node_end = range[6]
  local search_start = node_end

  ---@param current_range Range6
  ---@return boolean
  local function filter_function(current_range)
    if range_eq(current_range, range) then
      return false
    end
    local start = current_range[3]
    local end_ = current_range[6]
    return start >= search_start and end_ >= node_end
  end

  ---@param current_range Range6
  ---@return integer
  local function scoring_function(current_range)
    local start = current_range[3]
    return -start
  end

  local next_range =
    shared.find_best_range(bufnr, query_string, query_group, filter_function, scoring_function)

  return next_range
end

---@param range Range6
---@param query_string string
---@param query_group string
---@param bufnr integer
---@return Range6?
local previous_textobject = function(range, query_string, query_group, bufnr)
  local node_start = range[3]
  local search_end = node_start

  ---@param current_range Range6
  ---@return boolean
  local function filter_function(current_range)
    local start = current_range[3]
    local end_ = current_range[6]
    return end_ <= search_end and start < node_start
  end

  ---@param current_range Range6
  ---@return integer
  local function scoring_function(current_range)
    local node_end = current_range[6]
    return node_end
  end

  local previous_range =
    shared.find_best_range(bufnr, query_string, query_group, filter_function, scoring_function)

  return previous_range
end

local M = {}

---@param query_strings string|string[]
---@param query_group? string
---@param direction integer
local function swap_textobject(query_strings, query_group, direction)
  if type(query_strings) == 'string' then
    query_strings = { query_strings }
  end
  query_group = query_group or 'textobjects'
  local bufnr = vim.api.nvim_get_current_buf()

  local textobject_range, query_string ---@type Range6?, string?
  for _, query_string_iter in ipairs(query_strings) do
    textobject_range = shared.textobject_at_point(query_string_iter, query_group, bufnr)
    if textobject_range then
      query_string = query_string_iter
      break
    end
  end
  if not query_string or not textobject_range then
    return
  end

  local step = direction > 0 and 1 or -1
  for _ = 1, math.abs(direction), step do
    local adjacent = direction > 0
        and next_textobject(textobject_range, query_string, query_group, bufnr)
      or previous_textobject(textobject_range, query_string, query_group, bufnr)
    if adjacent then
      swap_nodes(
        shared.torange4(textobject_range),
        shared.torange4(adjacent),
        bufnr,
        'yes, set cursor!'
      )
    end
  end
end

---@param fn function
local function make_dot_repeatable(fn)
  _G._nvim_treesitter_textobject_last_function = fn
  vim.o.opfunc = 'v:lua._nvim_treesitter_textobject_last_function'
  api.nvim_feedkeys('g@l', 'n', false)
end

---@param query_strings string lua pattern describing the query string
---@param query_group? string
function M.swap_next(query_strings, query_group)
  return make_dot_repeatable(function()
    swap_textobject(query_strings, query_group, 1)
  end)
end

---@param query_strings string lua pattern describing the query string
---@param query_group? string
function M.swap_previous(query_strings, query_group)
  return make_dot_repeatable(function()
    swap_textobject(query_strings, query_group, -1)
  end)
end

return M
