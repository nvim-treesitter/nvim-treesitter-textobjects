local ts_utils = require "nvim-treesitter.ts_utils"
local shared = require "nvim-treesitter.textobjects.shared"
local attach = require "nvim-treesitter.textobjects.attach"
local configs = require "nvim-treesitter.configs"

local M = {}

local function swap_textobject(query_string, direction)
  local bufnr, textobject_range, node = shared.textobject_at_point(query_string)
  if not node then
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

M.attach = attach.make_attach(normal_mode_functions, "swap")
M.detach = attach.make_detach(normal_mode_functions, "swap")

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

-- Inject hooks to every function
local hook = configs.get_module("textobjects.swap").hook
if hook then
  for k, v in pairs(hook) do
    local unhooked = M[k]
    M[k] = function(...)
      if v.before then
        v.before(...)
      end
      unhooked(...)
      if v.after then
        v.after(...)
      end
    end
  end
end

return M
