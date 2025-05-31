local api = vim.api
local global_config = require('nvim-treesitter-textobjects.config')
local shared = require('nvim-treesitter-textobjects.shared')

---@param range Range4
---@param selection_mode TSTextObjects.SelectionMode
local function update_selection(range, selection_mode)
  ---@type integer, integer, integer, integer
  local start_row, start_col, end_row, end_col = unpack(range)
  selection_mode = selection_mode or 'v'

  -- enter visual mode if normal or operator-pending (no) mode
  -- Why? According to https://learnvimscriptthehardway.stevelosh.com/chapters/15.html
  --   If your operator-pending mapping ends with some text visually selected, Vim will operate on that text.
  --   Otherwise, Vim will operate on the text between the original cursor position and the new position.
  local mode = api.nvim_get_mode()
  if mode.mode ~= selection_mode then
    -- Call to `nvim_replace_termcodes()` is needed for sending appropriate command to enter blockwise mode
    selection_mode = api.nvim_replace_termcodes(selection_mode, true, true, true)
    vim.cmd.normal({ selection_mode, bang = true })
  end

  local end_col_offset = 1

  if selection_mode == 'v' and vim.o.selection == 'exclusive' then
    end_col_offset = 0
  end

  -- Position is 1, 0 indexed.
  api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd('normal! o')
  api.nvim_win_set_cursor(0, { end_row + 1, end_col - end_col_offset })
end

local M = {}

---@param bufnr integer
---@param row integer
---@param col integer
---@return string?
local function char_at_position(bufnr, row, col)
  local ok, char = pcall(api.nvim_buf_get_text, bufnr, row, col, row, col + 1, {})
  if ok then
    return char[1]
  end
end

---@param bufnr integer
---@param row integer
---@param col integer
---@return boolean
local function is_whitespace(bufnr, row, col)
  local char = char_at_position(bufnr, row, col)
  if char == nil then
    return false
  end
  if char == '' then
    return true
  end
  return string.match(char, '%s')
end

---@param bufnr integer
---@param row integer
---@param col integer
---@return { [1]: integer, [2]: integer }? position
local function next_position(bufnr, row, col)
  local max_col = #vim.fn.getbufoneline(bufnr, row + 1) - 1
  local max_row = api.nvim_buf_line_count(bufnr) - 1
  if col >= max_col then
    if row >= max_row then
      return nil
    end
    row = row + 1
    col = 0
  else
    col = col + 1
  end
  return { row, col }
end

---@param bufnr integer
---@param row integer
---@param col integer
---@return { [1]: integer, [2]: integer }? position
local function previous_position(bufnr, row, col)
  if col <= 0 then
    if row <= 0 then
      return nil
    end
    row = row - 1
    -- Empty line should be considered as a single character
    col = math.max(#vim.fn.getbufoneline(bufnr, row + 1) - 1, 0)
  else
    col = col - 1
  end
  return { row, col }
end

---@param bufnr integer
---@param range Range4
---@param selection_mode string
---@return Range4?
local function include_surrounding_whitespace(bufnr, range, selection_mode)
  local start_row, start_col, end_row, end_col = unpack(range) ---@type integer, integer, integer, integer
  local extended = false
  local position = { end_row, end_col - 1 }
  local next = next_position(bufnr, unpack(position))
  while next and is_whitespace(bufnr, unpack(next)) do
    extended = true
    position = next ---@type {[1]: integer, [2]: integer}
    next = next_position(bufnr, unpack(position))
  end
  if extended then
    -- don't extend in both directions
    return { start_row, start_col, position[1], position[2] + 1 }
  end

  position = { start_row, start_col }
  local previous = previous_position(bufnr, unpack(position))

  while previous and is_whitespace(bufnr, unpack(previous)) do
    position = previous
    previous = previous_position(bufnr, unpack(position))
  end
  if selection_mode == 'linewise' then
    position = assert(next_position(bufnr, unpack(position)))
  end
  return { position[1], position[2], end_row, end_col }
end

---@generic T
---@param val `T`|fun(opts: table):`T`
---@param opts table
---@return T
local function_or_value_to_value = function(val, opts)
  if type(val) == 'function' then
    return val(opts)
  else
    return val
  end
end

---@param query_string string
---@param query_group? string
function M.select_textobject(query_string, query_group)
  query_group = query_group or 'textobjects'
  local bufnr = vim.api.nvim_get_current_buf()

  local config = global_config.select
  local lookahead = config.lookahead
  local lookbehind = config.lookbehind
  local surrounding_whitespace = config.include_surrounding_whitespace
  local range6 = shared.textobject_at_point(
    query_string,
    query_group,
    bufnr,
    nil,
    { lookahead = lookahead, lookbehind = lookbehind }
  )
  if range6 then
    local range4 = shared.torange4(range6)
    local selection_mode = M.detect_selection_mode(query_string)
    if
      function_or_value_to_value(surrounding_whitespace, {
        query_string = query_string,
        selection_mode = selection_mode,
      })
    then
      ---@diagnostic disable-next-line: cast-local-type
      range4 = include_surrounding_whitespace(bufnr, range4, selection_mode)
    end
    if range4 then
      update_selection(range4, selection_mode)
    end
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
    nov = 'operator-pending',
    noV = 'operator-pending',
    ['no\22'] = 'operator-pending', -- \22 is the scape sequence of <c-v>
    V = 'visual',
    v = 'visual',
    ['\22'] = 'visual', -- \22 is the scape sequence of <c-v>
  }
  local method = keymap_to_method[api.nvim_get_mode().mode]

  local config = global_config.select
  local selection_modes = function_or_value_to_value(config.selection_modes, {
    query_string = query_string,
    method = method,
  }) --[[@as TSTextObjects.SelectionMode|table<string, TSTextObjects.SelectionMode>]]
  local selection_mode ---@type TSTextObjects.SelectionMode
  if type(selection_modes) == 'table' then
    selection_mode = selection_modes[query_string] or 'v'
  else
    selection_mode = selection_modes or 'v'
  end

  local ret_value = selection_mode
  local mode = api.nvim_get_mode().mode

  local is_normal_or_charwise_v = mode == 'n' or mode == 'v'
  if not is_normal_or_charwise_v then
    -- According to "mode()" mapping, if we are in operator pending mode or visual mode,
    -- then last char is {v,V,<C-v>}, exept for "no", which is "o", in which case we honor
    -- last set `selection_mode`
    mode = mode:sub(#mode) --[[@as string]]
    ret_value = mode == 'o' and selection_mode or mode
  end

  return ret_value == 'n' and 'v' or ret_value
end

return M
