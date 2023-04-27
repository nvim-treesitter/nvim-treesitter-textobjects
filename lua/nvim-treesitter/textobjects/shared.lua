local api = vim.api

local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"
local ts_utils = require "nvim-treesitter.ts_utils"
local ts = require "nvim-treesitter.compat"

local M = {}

if not unpack then
  -- luacheck: push ignore 121
  unpack = table.unpack
  -- luacheck: pop
end

--- Similar functions from vim.treesitter, but it accepts node as table type, not necessarily a TSNode
local function _cmp_pos(a_row, a_col, b_row, b_col)
  if a_row == b_row then
    if a_col > b_col then
      return 1
    elseif a_col < b_col then
      return -1
    else
      return 0
    end
  elseif a_row > b_row then
    return 1
  end

  return -1
end

local cmp_pos = {
  lt = function(...)
    return _cmp_pos(...) == -1
  end,
  le = function(...)
    return _cmp_pos(...) ~= 1
  end,
  gt = function(...)
    return _cmp_pos(...) == 1
  end,
  ge = function(...)
    return _cmp_pos(...) ~= -1
  end,
  eq = function(...)
    return _cmp_pos(...) == 0
  end,
  ne = function(...)
    return _cmp_pos(...) ~= 0
  end,
}

-- This can be replaced to vim.treesitter.node_contains once Neovim 0.9 is released
-- In 0.8, it only accepts TSNode type and sometimes it causes issues.
function M.node_contains(node, range)
  local srow_1, scol_1, erow_1, ecol_1 = node:range()
  local srow_2, scol_2, erow_2, ecol_2 = unpack(range)

  -- start doesn't fit
  if cmp_pos.gt(srow_1, scol_1, srow_2, scol_2) then
    return false
  end

  -- end doesn't fit
  if cmp_pos.lt(erow_1, ecol_1, erow_2, ecol_2) then
    return false
  end

  return true
end

-- Convert single query string to list for backwards compatibility and the Vim commands
function M.make_query_strings_table(query_strings)
  return type(query_strings) == "string" and { query_strings } or query_strings
end

-- Get query strings from regex
function M.get_query_strings_from_regex(query_strings_regex, query_group, lang)
  query_strings_regex = M.make_query_strings_table(query_strings_regex)
  query_group = query_group or "textobjects"
  lang = lang or parsers.get_buf_lang(0)
  local available_textobjects = M.available_textobjects(lang, query_group)
  local query_strings = {}
  for _, query_string_regex in ipairs(query_strings_regex) do
    for _, available_textobject in ipairs(available_textobjects) do
      if string.match("@" .. available_textobject, query_string_regex) then
        table.insert(query_strings, "@" .. available_textobject)
      end
    end
  end

  return query_strings
end

function M.available_textobjects(lang, query_group)
  lang = lang or parsers.get_buf_lang()
  query_group = query_group or "textobjects"
  local parsed_queries = ts.get_query(lang, query_group)
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

--- Get the best match at a given point
--- If the point is inside a node, the smallest node is returned
--- If the point is not inside a node, the closest node is returned (if opts.lookahead or opts.lookbehind is true)
---@param matches table list of matches
---@param row number 0-indexed
---@param col number 0-indexed
---@param opts table lookahead and lookbehind options
local function best_match_at_point(matches, row, col, opts)
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
    if m.node and vim.treesitter.is_in_node_range(m.node, row, col) then
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

  local get_range = function(match)
    if match.metadata ~= nil then
      return match.metadata.range
    end

    return { match.node:range() }
  end

  if smallest_range then
    if smallest_range.start then
      local start_range = get_range(smallest_range.start)
      local node_range = get_range(smallest_range)
      return { start_range[1], start_range[2], node_range[3], node_range[4] }, smallest_range.node
    else
      return get_range(smallest_range), smallest_range.node
    end
  elseif lookahead_largest_range then
    return get_range(lookahead_largest_range), lookahead_largest_range.node
  elseif lookbehind_largest_range then
    return get_range(lookbehind_largest_range), lookbehind_largest_range.node
  end
end

--- Get the best match at a given point
--- Similar to best_match_at_point but it will search within the @*.outer capture if possible.
--- For example, @function.inner will select the inner part of what @function.outer would select.
--- Without this logic, @function.inner can select the larger context (e.g. the main function)
--- when it's just before the start of the inner range.
--- Or it will look ahead and choose the next inner range instead of selecting the current function
--- when it's just after the end of the inner range (e.g. the "end" keyword of the function)
function M.textobject_at_point(query_string, query_group, pos, bufnr, opts)
  query_group = query_group or "textobjects"
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
    return
  end

  local matches = queries.get_capture_matches_recursively(bufnr, query_string, query_group)
  if string.match(query_string, "^@.*%.outer$") then
    local range, node = best_match_at_point(matches, row, col, opts)
    return bufnr, range, node
  else
    -- query string is @*.inner or @*
    -- First search the @*.outer instead, and then search the @*.inner within the range of the @*.outer
    local query_string_outer = string.gsub(query_string, "%..*", ".outer")
    if query_string_outer == query_string then
      query_string_outer = query_string .. ".outer"
    end

    local matches_outer = queries.get_capture_matches_recursively(bufnr, query_string_outer, query_group)
    if #matches_outer == 0 then
      -- Outer query doesn't exist or doesn't match anything
      -- Return the best match from the entire buffer, just like the @*.outer case
      local range, node = best_match_at_point(matches, row, col, opts)
      return bufnr, range, node
    end

    -- Note that outer matches don't perform lookahead
    local range_outer, node_outer = best_match_at_point(matches_outer, row, col, {})
    if range_outer == nil then
      -- No @*.outer found
      -- Return the best match from the entire buffer, just like the @*.outer case
      local range, node = best_match_at_point(matches, row, col, opts)
      return bufnr, range, node
    end

    local matches_within_outer = {}
    for _, match in ipairs(matches) do
      if M.node_contains(node_outer, { match.node:range() }) then
        table.insert(matches_within_outer, match)
      end
    end
    if #matches_within_outer == 0 then
      -- No @*.inner found within the range of the @*.outer
      -- Return the best match from the entire buffer, just like the @*.outer case
      local range, node = best_match_at_point(matches, row, col, opts)
      return bufnr, range, node
    else
      -- Find the best match from the cursor position
      local range, node = best_match_at_point(matches_within_outer, row, col, opts)
      if range ~= nil then
        return bufnr, range, node
      else
        -- If failed,
        -- find the best match within the range of the @*.outer
        -- starting from the outer range's start position (not the cursor position)
        -- with lookahead enabled
        range, node = best_match_at_point(matches_within_outer, range_outer[1], range_outer[2], { lookahead = true })
        return bufnr, range, node
      end
    end
  end
end

function M.get_adjacent(forward, node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  local fn = forward and M.next_textobject or M.previous_textobject
  return fn(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
end

function M.next_textobject(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  local node = node or vim.treesitter.get_node_at_cursor()
  local bufnr = bufnr or api.nvim_get_current_buf()
  if not node then
    return
  end

  local _, _, node_end = node:end_()
  local search_start, _
  if overlapping_range_ok then
    _, _, search_start = node:start()
    search_start = search_start + 1
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
      return start >= search_start and end_ >= node_end
    end
  end
  local function scoring_function(match)
    local _, _, node_start = match.node:start()
    return -node_start
  end

  local next_node = queries.find_best_match(bufnr, query_string, query_group, filter_function, scoring_function)

  return next_node and next_node.node
end

function M.previous_textobject(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  local node = node or vim.treesitter.get_node_at_cursor()
  local bufnr = bufnr or api.nvim_get_current_buf()
  if not node then
    return
  end

  local _, _, node_start = node:start()
  local search_end, _
  if overlapping_range_ok then
    _, _, search_end = node:end_()
    search_end = search_end - 1
  else
    _, _, search_end = node:start()
  end

  local function filter_function(match)
    if not same_parent or node:parent() == match.node:parent() then
      local _, _, end_ = match.node:end_()
      local _, _, start = match.node:start()
      return end_ <= search_end and start < node_start
    end
  end

  local function scoring_function(match)
    local _, _, node_end = match.node:end_()
    return node_end
  end

  local previous_node = queries.find_best_match(bufnr, query_string, query_group, filter_function, scoring_function)

  return previous_node and previous_node.node
end

return M
