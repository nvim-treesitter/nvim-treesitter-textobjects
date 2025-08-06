local M = {}

---@param options TSTextObjects.UserConfig?
function M.setup(options)
  if options then
    require('nvim-treesitter-textobjects.config').update(options)
  end
end

return M
