local api = vim.api
local configs = require "nvim-treesitter.configs"
local parsers = require "nvim-treesitter.parsers"

local shared = require "nvim-treesitter.textobjects.shared"
local ts_utils = require "nvim-treesitter.ts_utils"

local M = {}

local function get_char_after_position(bufnr, row, col)
  if row == nil then
    return nil
  end
  local ok, char = pcall(vim.api.nvim_buf_get_text, bufnr, row, col, row, col + 1, {})
  if ok then
    return char[1]
  end
end

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

local function include_surrounding_whitespace(bufnr, textobject, selection_mode)
  local start_row, start_col, end_row, end_col = unpack(textobject)
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
  while is_whitespace_after(bufnr, next_row, next_col) do
    start_row = next_row
    start_col = next_col
    next_row, next_col = next_position(bufnr, start_row, start_col, false)
  end
  if selection_mode == "linewise" then
    start_row, start_col = next_position(bufnr, start_row, start_col, true)
  end
  return { start_row, start_col, end_row, end_col }
end

local val_or_return = function(val, opts)
  if type(val) == "function" then
    return val(opts)
  else
    return val
  end
end

function M.select_textobject(query_string, query_group, keymap_mode)
  query_group = query_group or "textobjects"
  local lookahead = configs.get_module("textobjects.select").lookahead
  local lookbehind = configs.get_module("textobjects.select").lookbehind
  local surrounding_whitespace = configs.get_module("textobjects.select").include_surrounding_whitespace
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
    ts_utils.update_selection(bufnr, textobject, selection_mode)
  end
end

function M.detect_selection_mode(query_string, keymap_mode)
  -- Update selection mode with different methods based on keymapping mode
  local keymap_to_method = {
    o = "operator-pending",
    s = "visual",
    v = "visual",
    x = "visual",
  }
  local method = keymap_to_method[keymap_mode]

  local config = configs.get_module "textobjects.select"
  local selection_modes = val_or_return(config.selection_modes, { query_string = query_string, method = method })
  local selection_mode
  if type(selection_modes) == "table" then
    selection_mode = selection_modes[query_string] or "v"
  else
    selection_mode = selection_modes or "v"
  end

  if selection_mode == "n" then
    selection_mode = "v"
  end

  return selection_mode
end

M.keymaps_per_buf = {}

function M.attach(bufnr, lang)
  bufnr = bufnr or api.nvim_get_current_buf()
  local config = configs.get_module "textobjects.select"
  lang = lang or parsers.get_buf_lang(bufnr)

  for mapping, query in pairs(config.keymaps) do
    local desc, query_string, query_group
    if type(query) == "table" then
      desc = query.desc
      query_string = query.query
      query_group = query.query_group or "textobjects"
    else
      query_string = query
      query_group = "textobjects"
    end
    if not desc then
      desc = "Select textobject " .. query_string
    end

    local available_textobjects = shared.available_textobjects(lang, query_group)
    local available = false
    for _, available_textobject in ipairs(available_textobjects) do
      if "@" .. available_textobject == query_string then
        available = true
        break
      end
    end

    if not available then
      query_string = nil
    end

    if query_string then
      for _, keymap_mode in ipairs { "o", "x" } do
        local status, _ = pcall(
          vim.keymap.set,
          { keymap_mode },
          mapping,
          string.format(
            "<cmd>lua require'nvim-treesitter.textobjects.select'.select_textobject('%s','%s','%s')<cr>",
            query_string,
            query_group,
            keymap_mode
          ),
          { buffer = bufnr, silent = true, remap = false, desc = desc }
        )
        if status then
          M.keymaps_per_buf[bufnr] = M.keymaps_per_buf[bufnr] or {}
          table.insert(M.keymaps_per_buf[bufnr], { mode = keymap_mode, lhs = mapping })
        end
      end
    end
  end
end

function M.detach(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()

  for _, keymap in ipairs(M.keymaps_per_buf[bufnr] or {}) do
    -- Even if it fails make it silent
    pcall(vim.keymap.del, { keymap.mode }, keymap.lhs, { buffer = bufnr })
  end
  M.keymaps_per_buf[bufnr] = nil
end

M.commands = {
  TSTextobjectSelect = {
    run = M.select_textobject,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
}

return M
