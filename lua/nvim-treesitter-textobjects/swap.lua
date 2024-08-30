local api = vim.api

local shared = require "nvim-treesitter-textobjects.shared"

---@class TSTextObjects.LspLocation
---@field line integer
---@field character integer

---@param range1 TSTextObjects.Range
---@param range2 TSTextObjects.Range
---@param bufnr integer
---@param cursor_to_second any
local function swap_nodes(range1, range2, bufnr, cursor_to_second)
  if not range1 or not range2 then
    return
  end

  local lsp_range1 = range1:to_lsp_range()
  local lsp_range2 = range2:to_lsp_range()

  local text1 = range1:get_text()
  local text2 = range2:get_text()

  local edit1 = { range = lsp_range1, newText = table.concat(text2, "\n") }
  local edit2 = { range = lsp_range2, newText = table.concat(text1, "\n") }
  vim.lsp.util.apply_text_edits({ edit1, edit2 }, bufnr, "utf-8")

  if cursor_to_second then
    vim.cmd "normal! m'" -- set jump

    local char_delta = 0
    local line_delta = 0
    if
      lsp_range1["end"].line < lsp_range2.start.line
      or (lsp_range1["end"].line == lsp_range2.start.line and lsp_range1["end"].character <= lsp_range2.start.character)
    then
      line_delta = #text2 - #text1
    end

    if
      lsp_range1["end"].line == lsp_range2.start.line and lsp_range1["end"].character <= lsp_range2.start.character
    then
      if line_delta ~= 0 then
        --- why?
        --correction_after_line_change =  -range2.start.character
        --text_now_before_range2 = #(text2[#text2])
        --space_between_ranges = range2.start.character - range1["end"].character
        --char_delta = correction_after_line_change + text_now_before_range2 + space_between_ranges
        --- Equivalent to:
        char_delta = #text2[#text2] - lsp_range1["end"].character

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
---
---@param range TSTextObjects.Range
---@param query_string string
---@param query_group string
---@param bufnr integer
---@return TSTextObjects.Range?
local next_textobject = function(range, query_string, query_group, bufnr)
  local node_end = range.end_byte
  local search_start = node_end

  ---@param current_range TSTextObjects.Range
  ---@return boolean
  local function filter_function(current_range)
    if current_range == range then
      return false
    end
    if range.parent_id == current_range.parent_id then
      local start = current_range.start_byte
      local end_ = current_range.end_byte
      return start >= search_start and end_ >= node_end
    end
    return false
  end

  ---@param current_range TSTextObjects.Range
  ---@return integer
  local function scoring_function(current_range)
    local start = current_range.start_byte
    return -start
  end

  local next_range = shared.find_best_range(bufnr, query_string, query_group, filter_function, scoring_function)

  return next_range
end

---@param range TSTextObjects.Range
---@param query_string string
---@param query_group string
---@param bufnr integer
---@return TSTextObjects.Range?
local previous_textobject = function(range, query_string, query_group, bufnr)
  local node_start = range.start_byte
  local search_end = node_start

  ---@param current_range TSTextObjects.Range
  ---@return boolean
  local function filter_function(current_range)
    if current_range.parent_id == current_range.parent_id then
      local end_ = current_range.end_byte
      local start = current_range.start_byte
      return end_ <= search_end and start < node_start
    end
    return false
  end

  ---@param current_range TSTextObjects.Range
  ---@return integer
  local function scoring_function(current_range)
    local node_end = current_range.end_byte
    return node_end
  end

  local previous_range = shared.find_best_range(bufnr, query_string, query_group, filter_function, scoring_function)

  return previous_range
end

local M = {}

---@param captures string|string[]
---@param query_group? string
---@param direction integer
local function swap_textobject(captures, query_group, direction)
  local query_strings = type(captures) == "string" and { captures } or captures
  query_group = query_group or "textobjects"

  local bufnr, textobject_range, query_string ---@type integer?, TSTextObjects.Range?, string?
  for _, query_string_iter in ipairs(query_strings) do
    bufnr, textobject_range = shared.textobject_at_point(query_string_iter, query_group)
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
    local adjacent = direction > 0 and next_textobject(textobject_range, query_string, query_group, bufnr)
      or previous_textobject(textobject_range, query_string, query_group, bufnr)
    if adjacent then
      swap_nodes(textobject_range, adjacent, bufnr, "yes, set cursor!")
    end
  end
end

---@param fn function
local function make_dot_repeatable(fn)
  _G._nvim_treesitter_textobject_last_function = fn
  vim.o.opfunc = "v:lua._nvim_treesitter_textobject_last_function"
  api.nvim_feedkeys("g@l", "n", false)
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
