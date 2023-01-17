local configs = require "nvim-treesitter.configs"
local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"
local M = {}

local function make_dot_repeatable(fn)
  return function()
    _G._nvim_treesitter_textobject_last_function = fn
    vim.o.opfunc = "v:lua._nvim_treesitter_textobject_last_function"
    vim.api.nvim_feedkeys("g@l", "n", false)
  end
end

function M.make_attach(functions, submodule, keymap_modes, opts)
  if type(keymap_modes) == "string" then
    keymap_modes = { keymap_modes }
  elseif type(keymap_modes) ~= "table" then
    keymap_modes = { "n" }
  end
  opts = opts or {}

  return function(bufnr, lang)
    lang = lang or parsers.get_buf_lang(bufnr)
    if not queries.get_query(lang, "textobjects") then
      return
    end

    local config = configs.get_module("textobjects." .. submodule)

    for _, function_call in pairs(functions) do
      local function_description = function_call:gsub("_", " "):gsub("^%l", string.upper)
      for mapping, query_metadata in pairs(config[function_call] or {}) do
        local mapping_description, query, query_group

        if type(query_metadata) == "table" then
          query = query_metadata.query
          query_group = query_metadata.query_group or "textobjects"
          mapping_description = query_metadata.desc
        else
          query = query_metadata
          query_group = "textobjects"
          mapping_description = function_description .. " " .. query_metadata
        end

        local fn = function()
          require("nvim-treesitter.textobjects." .. submodule)[function_call](query, query_group)
        end
        if opts.dot_repeatable then
          fn = make_dot_repeatable(fn)
        end
        vim.keymap.set(
          keymap_modes,
          mapping,
          fn,
          { buffer = bufnr, silent = true, remap = false, desc = mapping_description }
        )
      end
    end
  end
end

function M.make_detach(functions, submodule, keymap_modes)
  if type(keymap_modes) == "string" then
    keymap_modes = { keymap_modes }
  elseif type(keymap_modes) ~= "table" then
    keymap_modes = { "n" }
  end

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
    for _, function_call in pairs(functions) do
      for mapping, query in pairs(config[function_call] or {}) do
        if type(query) == "table" then
          query = query[lang]
        elseif not queries.get_query(lang, "textobjects") then
          query = nil
        end
        if query then
          for _, mode in ipairs(keymap_modes) do
            if vim.fn.mapcheck(mapping, mode, false) ~= "" then
              vim.keymap.del(mode, mapping, { buffer = bufnr })
            end
          end
        end
      end
    end
  end
end

return M
