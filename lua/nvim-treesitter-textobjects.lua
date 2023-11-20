local config = require "nvim-treesitter-textobjects.config"
local api = vim.api

local M = {}

local available_text_objects = function(arg_lead)
  local options = vim.tbl_map(function(o)
    return "@" .. o
  end, require("nvim-treesitter-textobjects.shared").available_textobjects())

  local filtered_options = vim.tbl_filter(
    --- @param name string
    function(name)
      return vim.startswith(name, arg_lead)
    end,
    options
  )

  return filtered_options
end

---@param fn function
local function f_args(fn)
  return function(opts)
    fn(unpack(opts.fargs))
  end
end

local function create_user_cmds()
  if config.lsp_interop.enable then
    local lsp_interop = require "nvim-treesitter-textobjects.lsp_interop"
    api.nvim_create_user_command("TSTextobjectPeekDefinitionCode", f_args(lsp_interop.peek_definition_code), {
      nargs = "+",
      complete = available_text_objects,
    })
  end

  if config.move.enable then
    local move = require "nvim-treesitter-textobjects.move"
    api.nvim_create_user_command(
      "TSTextobjectGotoNextStart",
      f_args(move.goto_next_start),
      { nargs = 1, complete = available_text_objects }
    )
    api.nvim_create_user_command(
      "TSTextobjectGotoNextEnd",
      f_args(move.goto_next_end),
      { nargs = 1, complete = available_text_objects }
    )
    api.nvim_create_user_command("TSTextobjectGotoPreviousStart", f_args(move.goto_previous_start), {
      nargs = 1,
      complete = available_text_objects,
    })
    api.nvim_create_user_command(
      "TSTextobjectGotoPreviousEnd",
      f_args(move.goto_previous_end),
      { nargs = 1, complete = available_text_objects }
    )
  end

  if config.repeatable_move.enable then
    local repeatable_move = require "nvim-treesitter-textobjects.repeatable_move"
    api.nvim_create_user_command("TSTextobjectGotoNextStart", f_args(repeatable_move.repeat_last_move), {})
    api.nvim_create_user_command(
      "TSTextobjectRepeatLastMoveOpposite",
      f_args(repeatable_move.repeat_last_move_opposite),
      {}
    )
    api.nvim_create_user_command("TSTextobjectRepeatLastMoveNext", f_args(repeatable_move.repeat_last_move_next), {})
    api.nvim_create_user_command(
      "TSTextobjectRepeatLastMovePrevious",
      f_args(repeatable_move.repeat_last_move_previous),
      {}
    )
    api.nvim_create_user_command("TSTextobjectBuiltinf", f_args(repeatable_move.builtin_f), {})
    api.nvim_create_user_command("TSTextobjectBuiltinF", f_args(repeatable_move.builtin_F), {})
    api.nvim_create_user_command("TSTextobjectBuiltint", f_args(repeatable_move.builtin_t), {})
    api.nvim_create_user_command("TSTextobjectBuiltinT", f_args(repeatable_move.builtin_T), {})
  end

  if config.select.enable then
    local select = require "nvim-treesitter-textobjects.select"
    api.nvim_create_user_command(
      "TSTextobjectSelect",
      f_args(select.select_textobject),
      { nargs = 1, complete = available_text_objects }
    )
  end

  if config.select.enable then
    local swap = require "nvim-treesitter-textobjects.swap"
    api.nvim_create_user_command(
      "TSTextobjectSwapNext",
      f_args(swap.swap_next),
      { nargs = 1, complete = available_text_objects }
    )
    api.nvim_create_user_command(
      "TSTextobjectSwapPrevious",
      swap.swap_previous,
      { nargs = 1, complete = available_text_objects }
    )
  end
end

local augroup = api.nvim_create_augroup("tresitter-textobjects", { clear = true })

local function crate_autocmds()
  -- TODO (TheLeoP): better logic and check attach.lua

  if config.lsp_interop.enable then
    api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(args)
        require("nvim-treesitter-textobjects.lsp_interop").attach(args.buf)
        require("nvim-treesitter-textobjects.lsp_interop").detach(args.buf)
      end,
      desc = "Reattach tresitter-textobjects lsp_interop",
    })
  end

  if config.move.enable then
    api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(args)
        require("nvim-treesitter-textobjects.move").attach(args.buf)
        require("nvim-treesitter-textobjects.move").detach(args.buf)
      end,
      desc = "Reattach tresitter-textobjects move",
    })
  end

  if config.select.enable then
    api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(args)
        require("nvim-treesitter-textobjects.select").attach(args.buf)
        require("nvim-treesitter-textobjects.select").detach(args.buf)
      end,
      desc = "Reattach tresitter-textobjects select",
    })
  end

  if config.swap.enable then
    api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(args)
        require("nvim-treesitter-textobjects.swap").attach(args.buf)
        require("nvim-treesitter-textobjects.swap").detach(args.buf)
      end,
      desc = "Reattach tresitter-textobjects swap",
    })
  end
end

local did_init = false
---@param options TSTextObjects.UserConfig?
function M.setup(options)
  if options then
    config.update(options)
  end

  if not did_init then
    did_init = true
    create_user_cmds()
    crate_autocmds()
  end
end

return M
