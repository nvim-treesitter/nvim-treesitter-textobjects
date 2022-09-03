local configs = require "nvim-treesitter.configs"
local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"
local M = {}

function M.make_attach(normal_mode_functions, submodule)
  return function(bufnr, lang)
    lang = lang or parsers.get_buf_lang(bufnr)
    if not queries.get_query(lang, "textobjects") then
      return
    end

    local config = configs.get_module("textobjects." .. submodule)

    for _, function_call in pairs(normal_mode_functions) do
      local function_description = function_call:gsub("_", " "):gsub("^%l", string.upper)
      for mapping, query_metadata in pairs(config[function_call] or {}) do
        local mapping_description, query

        if type(query_metadata) == "table" then
          query = query_metadata.query
          mapping_description = query_metadata.desc
        else
          query = query_metadata
          mapping_description = function_description .. " " .. query_metadata
        end

        vim.keymap.set("n", mapping, function()
          require("nvim-treesitter.textobjects." .. submodule)[function_call](query)
        end, { buffer = bufnr, silent = true, remap = false, desc = mapping_description })
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
