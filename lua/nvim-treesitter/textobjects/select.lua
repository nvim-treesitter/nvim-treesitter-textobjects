local api = vim.api
local configs = require "nvim-treesitter.configs"
local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"

local shared = require "nvim-treesitter.textobjects.shared"
local ts_utils = require "nvim-treesitter.ts_utils"

local M = {}

function M.select_textobject(query_string, keymap_mode)
  local lookahead = configs.get_module("textobjects.select").lookahead
  local lookbehind = configs.get_module("textobjects.select").lookbehind
  local bufnr, textobject =
    shared.textobject_at_point(query_string, nil, nil, { lookahead = lookahead, lookbehind = lookbehind })
  if textobject then
    ts_utils.update_selection(bufnr, textobject, M.detect_selection_mode(query_string, keymap_mode))
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
  local selection_mode = config.selection_modes[query_string] or "v"
  if method == "visual" then
    selection_mode = vim.fn.visualmode()
  elseif method == "operator-pending" then
    local ctrl_v = vim.api.nvim_replace_termcodes("<c-v>", true, true, true)
    local t = {
      noV = "V",
      ["no" .. ctrl_v] = "<c-v>",
    }
    selection_mode = t[vim.fn.mode(1)] or selection_mode
  end

  local t = {
    v = "charwise",
    V = "linewise",
    ["<c-v>"] = "blockwise",
  }
  return t[selection_mode]
end

function M.attach(bufnr, lang)
  local buf = bufnr or api.nvim_get_current_buf()
  local config = configs.get_module "textobjects.select"
  lang = lang or parsers.get_buf_lang(buf)

  for mapping, query in pairs(config.keymaps) do
    if not queries.get_query(lang, "textobjects") then
      query = nil
    end
    if query then
      local desc = "treesitter select: " .. query
      local cmd_o = ":lua require'nvim-treesitter.textobjects.select'.select_textobject('" .. query .. "', 'o')<CR>"
      api.nvim_buf_set_keymap(buf, "o", mapping, cmd_o, { silent = true, noremap = true, desc = desc })
      local cmd_x = ":lua require'nvim-treesitter.textobjects.select'.select_textobject('" .. query .. "', 'x')<CR>"
      api.nvim_buf_set_keymap(buf, "x", mapping, cmd_x, { silent = true, noremap = true, desc = desc })
    end
  end
end

function M.detach(bufnr)
  local buf = bufnr or api.nvim_get_current_buf()
  local config = configs.get_module "textobjects.select"
  local lang = parsers.get_buf_lang(bufnr)

  for mapping, query in pairs(config.keymaps) do
    if not queries.get_query(lang, "textobjects") then
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
