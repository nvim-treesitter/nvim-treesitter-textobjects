local queries = require "nvim-treesitter.query"

local M = {}

-- TODO: In this function replace `module-template` with the actual name of your module.
function M.init()
  require "nvim-treesitter".define_modules {
    module_template = {
      module_path = "module-template.internal",
      is_supported = function(lang)
        -- TODO: you don't want your queries to be named `awesome-query`, do you ?
        return queries.get_query(lang, 'awesome-query') ~= nil
      end
    }
  }
end

return M
