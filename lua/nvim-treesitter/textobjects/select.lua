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
    -- Detect if selection should be made linewise depending keymaping mode.
    -- This should be done before calling `ts_utils.update_selection()` because
    -- it forces 'v' mode.
    local force_linewise = (keymap_mode == "x" and vim.fn.visualmode() == "V") or
      (keymap_mode == "o" and vim.fn.mode(1) == "noV")
    -- Make regular selection
    ts_utils.update_selection(bufnr, textobject)
    -- Possibly make selection linewise
    if force_linewise then
      vim.fn.nvim_exec("normal! V", false)
    end
  end
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
