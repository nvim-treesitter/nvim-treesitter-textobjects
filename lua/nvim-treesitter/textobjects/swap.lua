local ts_utils = require "nvim-treesitter.ts_utils"
local shared = require "nvim-treesitter.textobjects.shared"
local attach = require "nvim-treesitter.textobjects.attach"

local M = {}

local function swap_textobject(query_strings, direction)
  query_strings = shared.make_query_strings_table(query_strings)
  local bufnr, textobject_range, node, query_string
  for _, query_string_iter in ipairs(query_strings) do
    bufnr, textobject_range, node = shared.textobject_at_point(query_string_iter)
    if node then
      query_string = query_string_iter
      break
    end
  end
  if not query_string then
    return
  end

  local step = direction > 0 and 1 or -1
  local overlapping_range_ok = false
  local same_parent = true
  for _ = 1, math.abs(direction), step do
    local forward = direction > 0
    local adjacent = shared.get_adjacent(forward, node, query_string, same_parent, overlapping_range_ok, bufnr)
    ts_utils.swap_nodes(textobject_range, adjacent, bufnr, "yes, set cursor!")
  end
end

function M.swap_next(query_string)
  swap_textobject(query_string, 1)
end

function M.swap_previous(query_string)
  swap_textobject(query_string, -1)
end

local normal_mode_functions = { "swap_next", "swap_previous" }

M.attach = attach.make_attach(normal_mode_functions, "swap", "n", { repeatable = true })
M.detach = attach.make_detach(normal_mode_functions, "swap", "n")

M.commands = {
  TSTextobjectSwapNext = {
    run = M.swap_next,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
  TSTextobjectSwapPrevious = {
    run = M.swap_previous,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
}

return M
