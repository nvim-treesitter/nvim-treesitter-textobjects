local api = vim.api
local global_config = require "nvim-treesitter-textobjects.config"
local shared = require "nvim-treesitter-textobjects.shared"

---@param range TSTextObjects.Range
---@param selection_mode string
local function update_selection(range, selection_mode)
  local start_row, start_col, end_row, end_col = range:to_vim_range()

  local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
  selection_mode = selection_mode or "charwise"

  -- Normalise selection_mode
  if vim.tbl_contains(vim.tbl_keys(v_table), selection_mode) then
    selection_mode = v_table[selection_mode]
  end

  -- enter visual mode if normal or operator-pending (no) mode
  -- Why? According to https://learnvimscriptthehardway.stevelosh.com/chapters/15.html
  --   If your operator-pending mapping ends with some text visually selected, Vim will operate on that text.
  --   Otherwise, Vim will operate on the text between the original cursor position and the new position.
  local mode = api.nvim_get_mode()
  if mode.mode ~= selection_mode then
    -- Call to `nvim_replace_termcodes()` is needed for sending appropriate command to enter blockwise mode
    selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)
    api.nvim_cmd({ cmd = "normal", bang = true, args = { selection_mode } }, {})
  end

  api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
  vim.cmd "normal! o"
  api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

local M = {}

---@param bufnr integer
---@param row integer
---@param col integer
---@return string?
local function get_char_after_position(bufnr, row, col)
  if row == nil then
    return nil
  end
  local ok, char = pcall(vim.api.nvim_buf_get_text, bufnr, row, col, row, col + 1, {})
  if ok then
    return char[1]
  end
end

---@param bufnr integer
---@param row integer
---@param col integer
---@return boolean
local function is_whitespace_after(bufnr, row, col)
  local char = get_char_after_position(bufnr, row, col)
  if char == nil then
    return false
  end
  if char == "" then
    if row == vim.api.nvim_buf_line_count(bufnr) - 1 then
      return false
    else
      return true
    end
  end
  return string.match(char, "%s")
end

local function get_line(bufnr, row)
  return vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
end

---@param bufnr integer
---@param row integer?
---@param col integer?
---@param forward boolean
---@return integer? row
---@return integer? col
local function next_position(bufnr, row, col, forward)
  local max_col = #get_line(bufnr, row)
  local max_row = vim.api.nvim_buf_line_count(bufnr)
  if forward then
    if col == max_col then
      if row == max_row then
        return nil
      end
      row = row + 1
      col = 0
    else
      col = col + 1
    end
  else
    if col == 0 then
      if row == 0 then
        return nil
      end
      row = row - 1
      col = #get_line(bufnr, row)
    else
      col = col - 1
    end
  end
  return row, col
end

---@param bufnr integer
---@param range TSTextObjects.Range
---@param selection_mode string
---@return TSTextObjects.Range
local function include_surrounding_whitespace(bufnr, range, selection_mode)
  local start_row, start_col, end_row, end_col = unpack(range:range4()) ---@type integer, integer, integer, integer
  local extended = false
  while is_whitespace_after(bufnr, end_row, end_col) do
    extended = true
    end_row, end_col = next_position(bufnr, end_row, end_col, true)
  end
  if extended then
    -- don't extend in both directions
    return { start_row, start_col, end_row, end_col }
  end
  local next_row, next_col = next_position(bufnr, start_row, start_col, false)

  -- TODO (TheLeoP): this is only to prevent warnings from lsp
  if not next_row or not next_col then
    return {}
  end

  while is_whitespace_after(bufnr, next_row, next_col) do
    start_row = next_row
    start_col = next_col
    next_row, next_col = next_position(bufnr, start_row, start_col, false)

    -- TODO (TheLeoP): this is only to prevent warnings from lsp
    if not next_row or not next_col then
      break
    end
  end
  if selection_mode == "linewise" then
    start_row, start_col = next_position(bufnr, start_row, start_col, true)
  end
  assert(start_row)
  assert(start_col)
  range:set_range4 { start_row, start_col, end_row, end_col }
  return range
end

---@generic T
---@param val `T`|fun(opts: table):`T`
---@param opts table
---@return T
local function_or_value_to_value = function(val, opts)
  if type(val) == "function" then
    return val(opts)
  else
    return val
  end
end

---@param query_string string
---@param query_group? string
function M.select_textobject(query_string, query_group)
  query_group = query_group or "textobjects"

  if not shared.check_support(api.nvim_get_current_buf(), query_group, { query_string }) then
    vim.notify(
      ("The filetype `%s` does not support the textobject `%s` for the query file `%s`"):format(
        vim.bo.filetype,
        query_string,
        query_group
      ),
      vim.log.levels.WARN
    )
    local mode = api.nvim_get_mode().mode
    if mode == "v" or mode == "V" or mode == "\22" then
      -- '\28\14' is an escaped version of `<C-\><C-n>`
      vim.cmd "normal! \28\14"
    end
    return
  end

  local config = global_config.select
  local lookahead = config.lookahead
  local lookbehind = config.lookbehind
  local surrounding_whitespace = config.include_surrounding_whitespace
  local bufnr, textobject =
    shared.textobject_at_point(query_string, query_group, nil, nil, { lookahead = lookahead, lookbehind = lookbehind })
  if textobject then
    local selection_mode = M.detect_selection_mode(query_string)
    if
      function_or_value_to_value(surrounding_whitespace, {
        query_string = query_string,
        selection_mode = selection_mode,
      })
    then
      textobject = include_surrounding_whitespace(bufnr, textobject, selection_mode)
    end
    update_selection(textobject, selection_mode)
  end
end

---@alias TSTextObjects.Method "operator-pending" | "visual"
---@alias TSTextObjects.Mode "nov" | "noV" | "no\22" | "v" | "V" | "\22"

---@param query_string string
---@return TSTextObjects.SelectionMode
function M.detect_selection_mode(query_string)
  -- Update selection mode with different methods based on keymapping mode
  ---@type table<TSTextObjects.Mode, TSTextObjects.Method>
  local keymap_to_method = {
    nov = "operator-pending",
    noV = "operator-pending",
    ["no\22"] = "operator-pending", -- \22 is the scape sequence of <c-v>
    V = "visual",
    v = "visual",
    ["\22"] = "visual", -- \22 is the scape sequence of <c-v>
  }
  local method = keymap_to_method[api.nvim_get_mode().mode]

  local config = global_config.select
  local selection_modes = function_or_value_to_value(config.selection_modes, {
    query_string = query_string,
    method = method,
  }) --[[@as TSTextObjects.SelectionMode|table<string, TSTextObjects.SelectionMode>]]
  local selection_mode ---@type TSTextObjects.SelectionMode
  if type(selection_modes) == "table" then
    selection_mode = selection_modes[query_string] or "v"
  else
    selection_mode = selection_modes or "v"
  end

  local ret_value = selection_mode
  local mode = api.nvim_get_mode().mode --[[@as string]]

  local is_normal_or_charwise_v = mode == "n" or mode == "v"
  if not is_normal_or_charwise_v then
    -- According to "mode()" mapping, if we are in operator pending mode or visual mode,
    -- then last char is {v,V,<C-v>}, exept for "no", which is "o", in which case we honor
    -- last set `selection_mode`
    mode = mode:sub(#mode)
    ret_value = mode == "o" and selection_mode or mode
  end

  return ret_value == "n" and "v" or ret_value
end

return M
