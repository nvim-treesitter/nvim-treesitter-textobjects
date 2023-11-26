local api = vim.api
local _config = require "nvim-treesitter-textobjects.config"
local shared = require "nvim-treesitter-textobjects.shared"

---@param buf? integer
---@param range Range4
---@param selection_mode string
local function update_selection(buf, range, selection_mode)
  local start_row, start_col, end_row, end_col = shared.get_vim_range(range, buf)

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
---@param textobject Range4
---@param selection_mode string
---@return Range4
local function include_surrounding_whitespace(bufnr, textobject, selection_mode)
  ---@type integer, integer, integer, integer
  local start_row, start_col, end_row, end_col = unpack(textobject)
  local extended = false
  while is_whitespace_after(bufnr, end_row, end_col) do
    extended = true
    end_row, end_col = next_position(bufnr, end_row, end_col, true)

    -- TODO (TheLeoP): this is only to prevent warnings from lsp
    if not end_row or not end_col then
      break
    end
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
  return { start_row, start_col, end_row, end_col }
end

--- TODO (TheLeoP): remove this
---@param val function|any
---@param opts any
local val_or_return = function(val, opts)
  if type(val) == "function" then
    return val(opts)
  else
    return val
  end
end

---@param query_string string
---@param query_group string?
---@param keymap_mode TSTextObjects.KeymapMode
function M.select_textobject(query_string, query_group, keymap_mode)
  if not shared.check_support(api.nvim_get_current_buf(), "textobjects", { query_string }) then
    vim.notify("This filetype is not supported by nvim-treesitter-textobjects", vim.log.levels.WARN)
    return
  end

  query_group = query_group or "textobjects"
  local config = _config.select
  local lookahead = config.lookahead
  local lookbehind = config.lookbehind
  local surrounding_whitespace = config.include_surrounding_whitespace
  local bufnr, textobject =
    shared.textobject_at_point(query_string, query_group, nil, nil, { lookahead = lookahead, lookbehind = lookbehind })
  if textobject then
    local selection_mode = M.detect_selection_mode(query_string, keymap_mode)
    if
      val_or_return(surrounding_whitespace, {
        query_string = query_string,
        selection_mode = selection_mode,
      })
    then
      textobject = include_surrounding_whitespace(bufnr, textobject, selection_mode)
    end
    update_selection(bufnr, textobject, selection_mode)
  end
end

---@alias TSTextObjects.Method "operator-pending" | "visual"
---@alias TSTextObjects.KeymapMode "o" | "s" | "v" | "x"

---@param query_string string
---@param keymap_mode TSTextObjects.KeymapMode
---@return TSTextObjects.SelectionMode
function M.detect_selection_mode(query_string, keymap_mode)
  -- Update selection mode with different methods based on keymapping mode
  ---@type table<TSTextObjects.KeymapMode, TSTextObjects.Method>
  local keymap_to_method = {
    o = "operator-pending",
    s = "visual",
    v = "visual",
    x = "visual",
  }
  local method = keymap_to_method[keymap_mode]

  local config = _config.select
  local selection_modes = val_or_return(config.selection_modes, { query_string = query_string, method = method }) --[[@as TSTextObjects.SelectionMode|table<string, TSTextObjects.SelectionMode>]]
  local selection_mode ---@type TSTextObjects.SelectionMode
  if type(selection_modes) == "table" then
    selection_mode = selection_modes[query_string] or "v"
  else
    selection_mode = selection_modes or "v"
  end

  -- According to "mode()" mapping, if we are in operator pending mode or visual mode,
  -- then last char is {v,V,<C-v>}, exept for "no", which is "o", in which case we honor
  -- last set `selection_mode`
  local visual_mode = api.nvim_get_mode().mode --[[@as string]]
  visual_mode = visual_mode:sub(#visual_mode)
  selection_mode = visual_mode == "o" and selection_mode or visual_mode

  if selection_mode == "n" then
    selection_mode = "v"
  end

  return selection_mode
end

M.keymaps_per_buf = {}

return M
