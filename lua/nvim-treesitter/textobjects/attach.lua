local configs = require "nvim-treesitter.configs"
local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"
local M = {}

function M.make_attach(normal_mode_functions, submodule)
  return function(bufnr, lang)
    local config = configs.get_module("textobjects." .. submodule)
    lang = lang or parsers.get_buf_lang(bufnr)

    for _, function_call in pairs(normal_mode_functions) do
      local description = function_call:gsub("_", " ")
      for mapping, config_queries in pairs(config[function_call] or {}) do
        if not queries.get_query(lang, "textobjects") then
          local desc
          if type(config_queries) == "table" then
            desc = config_queries.desc
            config_queries = config_queries.query
          end
          if not desc then
            desc = description:gsub("^%l", string.upper) .. " " .. config_queries
          end
          if config_queries then
            vim.keymap.set("n", mapping, function()
              require("nvim-treesitter.textobjects." .. submodule)[function_call](config_queries)
            end, { buffer = bufnr, silent = true, remap = false, desc = desc })
          end
        end
        config_queries = nil
      end
    end
  end
end

function M.make_detach(normal_mode_functions, submodule)
  return function(bufnr)
    local config = configs.get_module("textobjects." .. submodule)
    local lang = parsers.get_buf_lang(bufnr)

    for mapping, query in pairs(config.keymaps or {}) do
      if not queries.get_query(lang, "textobjects") then
        query = nil
      end
      if query then
        vim.keymap.del({ "o", "x" }, mapping, { buffer = bufnr })
      end
    end
    for _, function_call in pairs(normal_mode_functions) do
      for mapping, query in pairs(config[function_call] or {}) do
        if type(query) == "table" then
          query = query[lang]
        elseif not queries.get_query(lang, "textobjects") then
          query = nil
        end
        if query then
          vim.keymap.del("n", mapping, { buffer = bufnr })
        end
      end
    end
  end
end

return M
