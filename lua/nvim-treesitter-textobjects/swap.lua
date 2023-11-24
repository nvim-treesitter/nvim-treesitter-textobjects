local ts = vim.treesitter
local api = vim.api

local shared = require "nvim-treesitter-textobjects.shared"

---@param node_or_range TSNode|Range4
---@param bufnr integer
---@return string[]
local function get_node_text(node_or_range, bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not node_or_range then
    return {}
  end

  local start_row, start_col, end_row, end_col = ts.get_node_range(node_or_range)
  -- We have to remember that end_col is end-exclusive

  if start_row ~= end_row then
    local lines = api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    if next(lines) == nil then
      return {}
    end
    lines[1] = string.sub(lines[1], start_col + 1)
    -- end_row might be just after the last line. In this case the last line is not truncated.
    if #lines == end_row - start_row + 1 then
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
    return lines
  else
    local line = api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
    -- If line is nil then the line is empty
    return line and { string.sub(line, start_col + 1, end_col) } or {}
  end
end

---@class TSTextObjects.LspLocation
---@field line integer
---@field character integer

---@param node TSNode|Range4
---@return {start: TSTextObjects.LspLocation, end: TSTextObjects.LspLocation}
local function node_to_lsp_range(node)
  -- TODO (TheLeoP): do not use this?
  local start_line, start_col, end_line, end_col = ts.get_node_range(node)
  local rtn = {}
  rtn.start = { line = start_line, character = start_col }
  rtn["end"] = { line = end_line, character = end_col }
  return rtn
end

---@param node_or_range1 Range4|TSNode
---@param node_or_range2 Range4|TSNode
---@param bufnr integer
---@param cursor_to_second any
local function swap_nodes(node_or_range1, node_or_range2, bufnr, cursor_to_second)
  if not node_or_range1 or not node_or_range2 then
    return
  end

  local range1 = node_to_lsp_range(node_or_range1)
  local range2 = node_to_lsp_range(node_or_range2)

  local text1 = get_node_text(node_or_range1, bufnr)
  local text2 = get_node_text(node_or_range2, bufnr)

  local edit1 = { range = range1, newText = table.concat(text2, "\n") }
  local edit2 = { range = range2, newText = table.concat(text1, "\n") }
  vim.lsp.util.apply_text_edits({ edit1, edit2 }, bufnr, "utf-8")

  if cursor_to_second then
    shared.set_jump()

    local char_delta = 0
    local line_delta = 0
    if
      range1["end"].line < range2.start.line
      or (range1["end"].line == range2.start.line and range1["end"].character <= range2.start.character)
    then
      line_delta = #text2 - #text1
    end

    if range1["end"].line == range2.start.line and range1["end"].character <= range2.start.character then
      if line_delta ~= 0 then
        --- why?
        --correction_after_line_change =  -range2.start.character
        --text_now_before_range2 = #(text2[#text2])
        --space_between_ranges = range2.start.character - range1["end"].character
        --char_delta = correction_after_line_change + text_now_before_range2 + space_between_ranges
        --- Equivalent to:
        char_delta = #text2[#text2] - range1["end"].character

        -- add range1.start.character if last line of range1 (now text2) does not start at 0
        if range1.start.line == range2.start.line + line_delta then
          char_delta = char_delta + range1.start.character
        end
      else
        char_delta = #text2[#text2] - #text1[#text1]
      end
    end

    api.nvim_win_set_cursor(
      api.nvim_get_current_win(),
      { range2.start.line + 1 + line_delta, range2.start.character + char_delta }
    )
  end
end

local M = {}

---@param query_strings_regex string|string[]
---@param query_group? string
---@param direction integer
local function swap_textobject(query_strings_regex, query_group, direction)
  query_strings_regex = shared.make_query_strings_table(query_strings_regex)
  query_group = query_group or "textobjects"

  if not shared.check_support(api.nvim_get_current_buf()) then
    vim.notify("This filetype is not supported by nvim-treesitter-textobjects", vim.log.levels.WARN)
    return
  end

  local query_strings = shared.get_query_strings_from_pattern(query_strings_regex, query_group)

  if not shared.check_support(api.nvim_get_current_buf(), "textobjects", query_strings) then
    vim.notify("This filetype is not supported by nvim-treesitter-textobjects", vim.log.levels.WARN)
    return
  end

  local bufnr, textobject_range, node, query_string ---@type integer?, Range4?, TSNode?, string?
  for _, query_string_iter in ipairs(query_strings) do
    bufnr, textobject_range, node = shared.textobject_at_point(query_string_iter, query_group)
    if node then
      query_string = query_string_iter
      break
    end
  end
  ---@cast node TSNode
  if not query_string or not textobject_range then
    return
  end

  local step = direction > 0 and 1 or -1
  local overlapping_range_ok = false
  local same_parent = true
  for _ = 1, math.abs(direction), step do
    local forward = direction > 0
    local adjacent =
      shared.get_adjacent(forward, node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
    if adjacent then
      swap_nodes(textobject_range, adjacent, bufnr, "yes, set cursor!")
    end
  end
end

---@param fn function
---@return function
local function make_dot_repeatable(fn)
  return function()
    _G._nvim_treesitter_textobject_last_function = fn
    vim.o.opfunc = "v:lua._nvim_treesitter_textobject_last_function"
    vim.api.nvim_feedkeys("g@l", "n", false)
  end
end

---@param query_strings_regex string lua pattern describing the query string
---@param query_group? string
---@return function #Function inteded to be used on mappings
function M.swap_next(query_strings_regex, query_group)
  return make_dot_repeatable(function()
    swap_textobject(query_strings_regex, query_group, 1)
  end)
end

---@param query_strings_regex string lua pattern describing the query string
---@param query_group? string
---@return function #Function inteded to be used on mappings
function M.swap_previous(query_strings_regex, query_group)
  return make_dot_repeatable(function()
    swap_textobject(query_strings_regex, query_group, -1)
  end)
end

return M
