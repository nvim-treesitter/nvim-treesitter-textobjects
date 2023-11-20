---@alias TSTextObjects.SelectionMode 'v'|'V'|'<c-v>'

---@class (exact) TSTextObjects.Config.Select
---@field enable boolean
---@field lookahead boolean
---@field lookbehind boolean
---@field keymaps table<string, string|table> TODO (TheLeoP): remove?
---@field selection_modes table<string, TSTextObjects.SelectionMode>|fun(opts: {query_string: string, methodr: TSTextObjects.Method}): TSTextObjects.SelectionMode|table<string, TSTextObjects.SelectionMode>
---@field include_surrounding_whitespace boolean|fun(): boolean

---@class (exact) TSTextObjects.Config.Swap
---@field enable boolean
---@field swap_next table<string, string> TODO (TheLeoP): remove?
---@field swap_previous table<string, string> TODO (TheLeoP): remove?

---@class (exact) TSTextObjects.Config.Move
---@field enable boolean
---@field set_jumps boolean
---@field goto_next_start table<string, string> TODO (TheLeoP): remove?
---@field goto_next_end table<string, string> TODO (TheLeoP): remove?
---@field goto_previous_start table<string, string> TODO (TheLeoP): remove?
---@field goto_previous_end table<string, string> TODO (TheLeoP): remove?
---@field goto_previous table<string, string> TODO (TheLeoP): remove?
---@field goto_next table<string, string> TODO (TheLeoP): remove?

---@class (exact) TSTextObjects.Config.LspInterop
---@field enable boolean
---@field border string|string[]
---@field floating_preview_opts table
---@field peek_definition_code table<string, string> TODO (TheLeoP): remove?

---@class (exact) TSTextObjects.Config.RepeatableMove
---@field enable boolean

---@class (exact) TSTextObjects.Config
---@field select TSTextObjects.Config.Select
---@field swap TSTextObjects.Config.Swap
---@field move TSTextObjects.Config.Move
---@field lsp_interop TSTextObjects.Config.LspInterop
---@field repeatable_move TSTextObjects.Config.RepeatableMove

---@class (exact) TSTextObjects.UserConfig : TSTextObjects.Config
---@field select TSTextObjects.Config.Select
---@field swap TSTextObjects.Config.Swap
---@field move TSTextObjects.Config.Move
---@field lsp_interop TSTextObjects.Config.LspInterop

---@type TSTextObjects.Config
local default_config = {
  select = {
    enable = false,
    lookahead = false,
    lookbehind = false,
    keymaps = {},
    selection_modes = {},
    include_surrounding_whitespace = false,
  },
  swap = {
    enable = false,
    swap_next = {},
    swap_previous = {},
  },
  move = {
    enable = false,
    set_jumps = true,
    goto_next_start = {},
    goto_next_end = {},
    goto_previous_start = {},
    goto_previous_end = {},
    goto_next = {},
    goto_previous = {},
  },
  lsp_interop = {
    enable = false,
    border = "none",
    floating_preview_opts = {},
    peek_definition_code = {},
  },
}

local config = vim.deepcopy(default_config)

local M = {}

---@param cfg TSTextObjects.UserConfig
function M.update(cfg)
  config = vim.tbl_deep_extend("force", config, cfg)
end

---@cast M +TSTextObjects.Config
setmetatable(M, {
  __index = function(_, k)
    return config[k]
  end,
})

return M
