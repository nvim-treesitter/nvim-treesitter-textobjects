local config = require "nvim-treesitter-textobjects.config"

local M = {}

---@param options TSTextObjects.UserConfig?
function M.setup(options)
  if options then
    config.update(options)
  end
end

return M
