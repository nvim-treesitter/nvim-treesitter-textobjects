local queries = require "nvim-treesitter.query"
local configs = require "nvim-treesitter.configs"
local utils = require "nvim-treesitter.utils"

local M = {}

M.has_textobjects = function(lang) return queries.has_query_files(lang, 'textobjects') end

local function has_some_textobject_mapping(lang)
  for _, v in pairs(configs.get_module('textobjects.select').keymaps) do
    if type(v) == 'table' then
      if v[lang] then
        return true
      end
    end
  end
  return false
end

function M.init()
  require "nvim-treesitter".define_modules {
    textobjects = {
      select = {
        module_path = "nvim-treesitter.textobjects.select",
        enable = false,
        disable = {},
        is_supported = function(lang)
          return M.has_textobjects(lang) or has_some_textobject_mapping(lang)
        end,
        keymaps = {}
      },
      move = {
        module_path = "nvim-treesitter.textobjects.move",
        enable = false,
        disable = {},
        is_supported = M.has_textobjects,
        goto_next_start = {},
        goto_next_end = {},
        goto_previous_start = {},
        goto_previous_end = {}
      },
      swap = {
        module_path = "nvim-treesitter.textobjects.swap",
        enable = false,
        disable = {},
        is_supported = M.has_textobjects,
        swap_next = {},
        swap_previous = {}
      },
      lsp_interop = {
        module_path = "nvim-treesitter.textobjects.lsp_interop",
        enable = false,
        disable = {},
        is_supported = M.has_textobjects,
        peek_definition_code = {},
      }
    }
  }
  for _, m in ipairs({'select', 'move', 'swap', 'lsp_interop'}) do
    utils.setup_commands('textobjects.'..m, require ('nvim-treesitter.textobjects.'..m).commands)
  end
end

return M
