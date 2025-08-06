---@alias TSTextObjects.SelectionMode 'v'|'V'|'<c-v>'

---@alias TSTextObjects.ConfigFunctionArgs {query_string: string, method: TSTextObjects.Method}

---@class (exact) TSTextObjects.Config.Select
---@field lookahead? boolean
---@field lookbehind? boolean
---@field selection_modes? table<string, TSTextObjects.SelectionMode>|fun(opts: TSTextObjects.ConfigFunctionArgs): TSTextObjects.SelectionMode|table<string, TSTextObjects.SelectionMode>
---@field include_surrounding_whitespace? boolean|fun(opts: TSTextObjects.ConfigFunctionArgs): boolean

---@class (exact) TSTextObjects.Config.Move
---@field set_jumps? boolean

---@class (exact) TSTextObjects.Config.LspInterop
---@field floating_preview_opts? table

---@class (exact) TSTextObjects.Config
---@field select TSTextObjects.Config.Select
---@field move TSTextObjects.Config.Move

---@class (exact) TSTextObjects.UserConfig : TSTextObjects.Config
---@field select? TSTextObjects.Config.Select
---@field move? TSTextObjects.Config.Move

---@type TSTextObjects.Config
local default_config = {
  select = {
    lookahead = false,
    lookbehind = false,
    selection_modes = {},
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
}

local config = vim.deepcopy(default_config)

local M = {}

---@param cfg TSTextObjects.UserConfig
function M.update(cfg)
  config = vim.tbl_deep_extend('force', config, cfg)
end

---@cast M +TSTextObjects.Config
setmetatable(M, {
  __index = function(_, k)
    return config[k]
  end,
})

return M
