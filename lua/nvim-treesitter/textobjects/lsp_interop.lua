local attach = require "nvim-treesitter.textobjects.attach"
local shared = require "nvim-treesitter.textobjects.shared"
local configs = require "nvim-treesitter.configs"

local M = {}

local floating_win

-- peeking is not interruptive so it is okay to use in visual mode.
-- in fact, visual mode peeking is very helpful because you may not want
-- to jump to the definition.
local nx_mode_functions = {
  "peek_definition_code",
}

local function is_new_signature_handler()
  if debug.getinfo(vim.lsp.handlers.signature_help).nparams == 4 then
    return true
  else
    return false
  end
end

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
  local opts = config.floating_preview_opts or {}

  if config.border ~= "none" then
    opts.border = config.border
  end
  local contents = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range["end"].line + 1, false)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local preview_buf, preview_win = vim.lsp.util.open_floating_preview(contents, filetype, opts)
  vim.api.nvim_buf_set_option(preview_buf, "filetype", filetype)
  return preview_buf, preview_win
end

function M.make_preview_location_callback(query_string, query_group, context)
  query_group = query_group or "textobjects"
  context = context or 0
  local callback = function(err, method, result)
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

    local _, textobject_at_definition =
      shared.textobject_at_point(query_string, query_group, { range.start.line + 1, range.start.character }, buf)

    if textobject_at_definition then
      context = textobject_at_definition
    end

    _, floating_win = M.preview_location(result, context)
  end

  local signature_handler = callback

  if is_new_signature_handler() then
    signature_handler = function(err, result, handler_context)
      callback(err, handler_context.method, result)
    end
  end

  return vim.schedule_wrap(signature_handler)
end

function M.peek_definition_code(query_string, query_group, lsp_request, context)
  query_group = query_group or "textobjects"
  lsp_request = lsp_request or "textDocument/definition"
  if vim.tbl_contains(vim.api.nvim_list_wins(), floating_win) then
    vim.api.nvim_set_current_win(floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(
      0,
      lsp_request,
      params,
      M.make_preview_location_callback(query_string, query_group, context)
    )
  end
end

M.attach = attach.make_attach(nx_mode_functions, "lsp_interop", { "n", "x" })
M.detach = attach.make_detach "lsp_interop"
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
