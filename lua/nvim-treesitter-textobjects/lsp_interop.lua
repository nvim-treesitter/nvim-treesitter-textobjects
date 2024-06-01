local api = vim.api

local shared = require "nvim-treesitter-textobjects.shared"
local global_config = require "nvim-treesitter-textobjects.config"

local M = {}

--- @type integer|nil
local floating_win

local function is_new_signature_handler()
  if debug.getinfo(vim.lsp.handlers.signature_help).nparams == 4 then
    return true
  else
    return false
  end
end

---@param location table<string, any>
---@param context integer|TSTextObjects.Range
---@return integer? preview_bufnr
---@return integer? preview_winnr
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

  local range = location.targetRange or location.range --[[@as lsp.Range]]
  -- don't include a exclusive 0 character line
  if range["end"].character == 0 then
    range["end"].line = range["end"].line - 1
  end
  if type(context) == "table" then
    local start_row, _, end_row, _ = unpack(context:range4()) ---@type integer, integer, integer, integer
    range.start.line = math.min(range.start.line, start_row)
    range["end"].line = math.max(range["end"].line, end_row)
  elseif type(context) == "number" then
    range["end"].line = math.max(range["end"].line, range.start.line + context)
  end

  local config = global_config.lsp_interop
  local opts = config.floating_preview_opts or {}

  local contents = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range["end"].line + 1, false)
  local filetype = vim.bo[bufnr].filetype
  local preview_buf, preview_win = vim.lsp.util.open_floating_preview(contents, filetype, opts)
  vim.bo[preview_buf].filetype = filetype
  return preview_buf, preview_win
end

---@param query_string string
---@param query_group string
---@param context? integer|TSTextObjects.Range
---@return fun(err?: table, method: string, result: table<string, any>|table<string, any>[])
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

    if vim.islist(result) then
      ---@cast result table<string, any>[]
      result = result[1]
      ---@cast result table<string, any>
    end
    local uri = result.uri or result.targetUri
    local range = result.range or result.targetRange --[[@as lsp.Range]]
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

---@param query_string string
---@param query_group? string
---@param lsp_request? string
---@param context? integer|TSTextObjects.Range
function M.peek_definition_code(query_string, query_group, lsp_request, context)
  query_group = query_group or "textobjects"

  if not shared.check_support(api.nvim_get_current_buf(), "textobjects", { query_string }) then
    vim.notify(
      ("The filetype `%s` does not support the textobjects `%s` for the query file `%s`"):format(
        vim.bo.filetype,
        query_string,
        query_group
      ),
      vim.log.levels.WARN
    )
    return
  end

  lsp_request = lsp_request or "textDocument/definition"
  if vim.tbl_contains(vim.api.nvim_list_wins(), floating_win) then
    assert(floating_win, "The floaing window for peeking is not open")
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

return M
