local api = vim.api
local configs = require'nvim-treesitter.configs'
local parsers = require'nvim-treesitter.parsers'
local queries = require'nvim-treesitter.query'

local shared = require'nvim-treesitter.textobjects.shared'
local ts_utils = require'nvim-treesitter.ts_utils'

local M = {}

function M.select_textobject(query_string, keymap_mode)
  local bufnr, textobject = shared.textobject_at_point(query_string)
  if textobject then
    ts_utils.update_selection(bufnr, textobject, M.detect_selection_mode(keymap_mode))
  end
end

function M.detect_selection_mode(keymap_mode)
  local selection_mode = "charwise"
  local ctrl_v = vim.api.nvim_replace_termcodes("<C-v>", true, true, true)

  -- Update selection mode with different methods based on keymapping mode
  local keymap_to_method = {
    o = "operator-pending", s = "visual", v = "visual", x = "visual"
  }
  local method = keymap_to_method[keymap_mode]

  if method == "visual" then
    selection_mode = vim.fn.visualmode()
  elseif method == "operator-pending" then
    local t = { noV = "linewise" }
    t["no" .. ctrl_v] = "blockwise"
    selection_mode = t[vim.fn.mode(1)]
  end

  return selection_mode
end

function M.attach(bufnr, lang)
  local buf = bufnr or api.nvim_get_current_buf()
  local config = configs.get_module("textobjects.select")
  local lang = lang or parsers.get_buf_lang(buf)

  for mapping, query in pairs(config.keymaps) do
    if type(query) == 'table' then
      query = query[lang]
    elseif not queries.get_query(lang, 'textobjects') then
      query = nil
    end
    if query then
      local cmd_o = ":lua require'nvim-treesitter.textobjects.select'.select_textobject('"..query.."', 'o')<CR>"
      api.nvim_buf_set_keymap(buf, "o", mapping, cmd_o, {silent = true, noremap = true })
      local cmd_x = ":lua require'nvim-treesitter.textobjects.select'.select_textobject('"..query.."', 'x')<CR>"
      api.nvim_buf_set_keymap(buf, "x", mapping, cmd_x, {silent = true, noremap = true })
    end
  end
end

function M.detach(bufnr)
  local buf = bufnr or api.nvim_get_current_buf()
  local config = configs.get_module("textobjects.select")
  local lang = parsers.get_buf_lang(bufnr)

  for mapping, query in pairs(config.keymaps) do
    if type(query) == 'table' then
      query = query[lang]
    elseif not queries.get_query(lang, 'textobjects') then
      query = nil
    end
    if query then
      api.nvim_buf_del_keymap(buf, "o", mapping)
      api.nvim_buf_del_keymap(buf, "x", mapping)
    end
  end
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
