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
    shared.set_jump()

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

local M = {}

---@param query_strings_regex string|string[]
---@param query_group? string
---@param direction integer
local function swap_textobject(query_strings_regex, query_group, direction)
  query_strings_regex = shared.make_query_strings_table(query_strings_regex)
  query_group = query_group or "textobjects"

  local query_strings = shared.get_query_strings_from_pattern(query_strings_regex, query_group)

  if not shared.check_support(api.nvim_get_current_buf(), "textobjects", query_strings) then
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
    local forward = direction > 0
    local adjacent = shared.get_adjacent(forward, textobject_range, query_string, query_group, bufnr)
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
