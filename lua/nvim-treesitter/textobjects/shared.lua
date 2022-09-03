local api = vim.api

local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"
local ts_utils = require "nvim-treesitter.ts_utils"

local M = {}

if not unpack then
  -- luacheck: push ignore 121
  unpack = table.unpack
  -- luacheck: pop
end

-- Convert single query string to list for backwards compatibility and the Vim commands
function M.make_query_strings_table(query_strings)
  return type(query_strings) == "string" and { query_strings } or query_strings
end

function M.available_textobjects(lang)
  lang = lang or parsers.get_buf_lang()
  local parsed_queries = queries.get_query(lang, "textobjects")
  if not parsed_queries then
    return {}
  end
  local found_textobjects = parsed_queries.captures or {}
  for _, p in pairs(parsed_queries.info.patterns) do
    for _, q in ipairs(p) do
      local query, arg1 = unpack(q)
      if query == "make-range!" and not vim.tbl_contains(found_textobjects, arg1) then
        table.insert(found_textobjects, arg1)
      end
    end
  end
  return found_textobjects
  --patterns = {
  --[2] = { { "make-range!", "function.inner", 2, 3 } },
  --[4] = { { "make-range!", "function.inner", 2, 3 } },
  --[11] = { { "make-range!", "parameter.outer", 2, 12 } },
  --[12] = { { "make-range!", "parameter.outer", 12, 3 } },
  --[13] = { { "make-range!", "parameter.outer", 2, 12 } },
  --[14] = { { "make-range!", "parameter.outer", 12, 3 } }
  --}
end

function M.textobject_at_point(query_string, pos, bufnr, opts)
  opts = opts or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lang = parsers.get_buf_lang(bufnr)
  if not lang then
    return
  end

  local row, col = unpack(pos or vim.api.nvim_win_get_cursor(0))
  row = row - 1

  if not string.match(query_string, "^@.*") then
    error 'Captures must start with "@"'
  end
  local matches = queries.get_capture_matches_recursively(bufnr, query_string, "textobjects")

  local match_length
  local smallest_range
  local earliest_start

  local lookahead_match_length
  local lookahead_largest_range
  local lookahead_earliest_start
  local lookbehind_match_length
  local lookbehind_largest_range
  local lookbehind_earliest_start

  for _, m in pairs(matches) do
    if m.node and ts_utils.is_in_node_range(m.node, row, col) then
      local length = ts_utils.node_length(m.node)
      if not match_length or length < match_length then
        smallest_range = m
        match_length = length
      end
      -- for nodes with same length take the one with earliest start
      if match_length and length == smallest_range then
        local start = m.start
        if start then
          local _, _, start_byte = m.start.node:start()
          if not earliest_start or start_byte < earliest_start then
            smallest_range = m
            match_length = length
            earliest_start = start_byte
          end
        end
      end
    elseif opts.lookahead then
      local start_line, start_col, start_byte = m.node:start()
      if start_line > row or start_line == row and start_col > col then
        local length = ts_utils.node_length(m.node)
        if
          not lookahead_earliest_start
          or lookahead_earliest_start > start_byte
          or (lookahead_earliest_start == start_byte and lookahead_match_length < length)
        then
          lookahead_match_length = length
          lookahead_largest_range = m
          lookahead_earliest_start = start_byte
        end
      end
    elseif opts.lookbehind then
      local start_line, start_col, start_byte = m.node:start()
      if start_line < row or start_line == row and start_col < col then
        local length = ts_utils.node_length(m.node)
        if
          not lookbehind_earliest_start
          or lookbehind_earliest_start < start_byte
          or (lookbehind_earliest_start == start_byte and lookbehind_match_length > length)
        then
          lookbehind_match_length = length
          lookbehind_largest_range = m
          lookbehind_earliest_start = start_byte
        end
      end
    end
  end

  if smallest_range then
    if smallest_range.start then
      local start_range = { smallest_range.start.node:range() }
      local node_range = { smallest_range.node:range() }
      return bufnr, { start_range[1], start_range[2], node_range[3], node_range[4] }, smallest_range.node
    else
      return bufnr, { smallest_range.node:range() }, smallest_range.node
    end
  elseif lookahead_largest_range then
    return bufnr, { lookahead_largest_range.node:range() }, lookahead_largest_range.node
  elseif lookbehind_largest_range then
    return bufnr, { lookbehind_largest_range.node:range() }, lookbehind_largest_range.node
  end
end

function M.get_adjacent(forward, node, query_string, same_parent, overlapping_range_ok, bufnr)
  local fn = forward and M.next_textobject or M.previous_textobject
  return fn(node, query_string, same_parent, overlapping_range_ok, bufnr)
end

function M.next_textobject(node, query_string, same_parent, overlapping_range_ok, bufnr)
  local node = node or ts_utils.get_node_at_cursor()
  local bufnr = bufnr or api.nvim_get_current_buf()
  if not node then
    return
  end

  local _, _, node_end = node:end_()
  local search_start, _
  if overlapping_range_ok then
    _, _, search_start = node:start()
  else
    _, _, search_start = node:end_()
  end
  local function filter_function(match)
    if match.node == node then
      return
    end
    if not same_parent or node:parent() == match.node:parent() then
      local _, _, start = match.node:start()
      local _, _, end_ = match.node:end_()
      return start > search_start and end_ >= node_end
    end
  end
  local function scoring_function(match)
    local _, _, node_start = match.node:start()
    return -node_start
  end

  local next_node = queries.find_best_match(bufnr, query_string, "textobjects", filter_function, scoring_function)

  return next_node and next_node.node
end

function M.previous_textobject(node, query_string, same_parent, overlapping_range_ok, bufnr)
  local node = node or ts_utils.get_node_at_cursor()
  local bufnr = bufnr or api.nvim_get_current_buf()
  if not node then
    return
  end

  local _, _, node_start = node:start()
  local search_end, _
  if overlapping_range_ok then
    _, _, search_end = node:end_()
    search_end = search_end + 1
  else
    _, _, search_end = node:start()
  end

  local function filter_function(match)
    if not same_parent or node:parent() == match.node:parent() then
      local _, _, end_ = match.node:end_()
      local _, _, start = match.node:start()
      return end_ < search_end and start < node_start
    end
  end

  local function scoring_function(match)
    local _, _, node_end = match.node:end_()
    return node_end
  end

  local previous_node = queries.find_best_match(bufnr, query_string, "textobjects", filter_function, scoring_function)

  return previous_node and previous_node.node
end

return M
