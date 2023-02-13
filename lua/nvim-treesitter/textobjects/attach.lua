local configs = require "nvim-treesitter.configs"
local M = {}

local function make_dot_repeatable(fn)
  return function()
    _G._nvim_treesitter_textobject_last_function = fn
    vim.o.opfunc = "v:lua._nvim_treesitter_textobject_last_function"
    vim.api.nvim_feedkeys("g@l", "n", false)
  end
end

M.keymaps_per_submodule = {}

function M.make_attach(functions, submodule, keymap_modes, opts)
  if type(keymap_modes) == "string" then
    keymap_modes = { keymap_modes }
  elseif type(keymap_modes) ~= "table" then
    keymap_modes = { "n" }
  end
  opts = opts or {}

  M.keymaps_per_submodule[submodule] = M.keymaps_per_submodule[submodule] or {}
  local keymaps_per_buf = M.keymaps_per_submodule[submodule]

  return function(bufnr, lang)
    -- lang = lang or parsers.get_buf_lang(bufnr)
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
        for _, mode in pairs(keymap_modes) do
          local status, _ = pcall(
            vim.keymap.set,
            mode,
            mapping,
            fn,
            { buffer = bufnr, silent = true, remap = false, desc = mapping_description }
          )
          if status then
            keymaps_per_buf[bufnr] = keymaps_per_buf[bufnr] or {}
            table.insert(keymaps_per_buf[bufnr], { mode = mode, lhs = mapping })
          end
        end
      end
    end
  end
end

function M.make_detach(submodule)
  return function(bufnr)
    M.keymaps_per_submodule[submodule] = M.keymaps_per_submodule[submodule] or {}
    local keymaps_per_buf = M.keymaps_per_submodule[submodule]

    bufnr = bufnr or vim.api.nvim_get_current_buf()

    for _, keymap in ipairs(keymaps_per_buf[bufnr] or {}) do
      -- Even if it fails make it silent
      pcall(vim.keymap.del, { keymap.mode }, keymap.lhs, { buffer = bufnr })
    end
    keymaps_per_buf[bufnr] = nil
  end
end

return M
