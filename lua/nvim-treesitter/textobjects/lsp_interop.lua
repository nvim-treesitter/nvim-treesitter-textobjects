local attach = require "nvim-treesitter.textobjects.attach"
local shared = require "nvim-treesitter.textobjects.shared"
local configs = require "nvim-treesitter.configs"

local M = {}

local floating_win

local normal_mode_functions = {
  "peek_definition_code",
}

function M.preview_location(location, context)
  -- location may be LocationLink or Location (more useful for the former)
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  local range = location.targetRange or location.range
  -- don't include a exclusive 0 character line
  if range["end"].character == 0 then
    range["end"].line = range["end"].line - 1
  end
  if type(context) == "table" then
    range.start.line = math.min(range.start.line, context[1])
    range["end"].line = math.max(range["end"].line, context[3])
  elseif type(context) == "number" then
    range["end"].line = math.max(range["end"].line, range.start.line + context)
  end

  local config = configs.get_module "textobjects.lsp_interop"
  local opts = {}
  if config.border ~= "none" then
    opts.border = config.border
  end
  local contents = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range["end"].line + 1, false)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype, opts)
end

function M.make_preview_location_callback(textobject, context)
  local context = context or 0
  return vim.schedule_wrap(function(err, method, result)
    if err then
      error(tostring(err))
    end
    if result == nil or vim.tbl_isempty(result) then
      print("No location found: " .. (method or "unknown error"))
      return
    end

    if vim.tbl_islist(result) then
      result = result[1]
    end
    local uri = result.uri or result.targetUri
    local range = result.range or result.targetRange
    if not uri or not range then
      return
    end

    local buf = vim.uri_to_bufnr(uri)
    vim.fn.bufload(buf)

    local _, textobject_at_definition = shared.textobject_at_point(
      textobject,
      { range.start.line + 1, range.start.character },
      buf
    )

    if textobject_at_definition then
      context = textobject_at_definition
    end

    _, floating_win = M.preview_location(result, context)
  end)
end

function M.peek_definition_code(textobject, lsp_request, context)
  lsp_request = lsp_request or "textDocument/definition"
  if vim.tbl_contains(vim.api.nvim_list_wins(), floating_win) then
    vim.api.nvim_set_current_win(floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, lsp_request, params, M.make_preview_location_callback(textobject, context))
  end
end

M.attach = attach.make_attach(normal_mode_functions, "lsp_interop")
M.detach = attach.make_detach(normal_mode_functions, "lsp_interop")
M.commands = {
  TSTextobjectPeekDefinitionCode = {
    run = M.peek_definition_code,
    args = {
      "-nargs=+",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
}

return M
