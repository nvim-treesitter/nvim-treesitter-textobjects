local ts = vim.treesitter
local add_bytes = require('vim.treesitter._range').add_bytes

-- lookup table for parserless queries
local lang_to_parser = { ecma = 'javascript', jsx = 'javascript' }

---@alias TSTextObjects.Metadata {range: {[1]: number, [2]: number, [3]: number, [4]: number, [5]: number, [6]: number, [7]: string}}

local M = {}

---@param object table
---@param path string[]
---@param value table
local function insert_to_path(object, path, value)
  ---@type table<string, any|table<string, any>>
  local curr_obj = object

  for index = 1, (#path - 1) do
    if curr_obj[path[index]] == nil then
      curr_obj[path[index]] = {}
    end

    ---@type table<string, any|table<string, any>>
    curr_obj = curr_obj[path[index]]
  end

  ---@type table<string, any|table<string, any>>
  curr_obj[path[#path]] = value
end

---Memoize a function using hash_fn to hash the arguments.
---@generic F: function
---@param fn F
---@param hash_fn fun(...): any
---@return F
local function memoize(fn, hash_fn)
  local cache = setmetatable({}, { __mode = 'kv' }) ---@type table<any,any>

  return function(...)
    local key = hash_fn(...)
    if cache[key] == nil then
      local v = fn(...) ---@type any
      cache[key] = v ~= nil and v or vim.NIL
    end

    local v = cache[key]
    return v ~= vim.NIL and v or nil
  end
end

--- Prepare matches for given query_group and parsed tree
--- memoize by buffer tick and query group
---
---@param bufnr integer the buffer
---@param query_group string the query file to use
---@param root TSNode the root node
---@param root_lang string the root node lang, if known
---@return table[]
local get_query_matches = memoize(function(bufnr, query_group, root, root_lang)
  local query = ts.query.get(root_lang, query_group)
  if not query then
    return {}
  end

  local matches = {} ---@type table[]
  local start_row, _, end_row, _ = root:range()
  -- The end row is exclusive so we need to add 1 to it.
  for pattern, match, metadata in query:iter_matches(root, bufnr, start_row, end_row + 1) do
    if pattern then
      local prepared_match = {}

      -- Extract capture names from each match
      for id, nodes in pairs(match) do
        local query_name = query.captures[id] -- name of the capture in the query
        if query_name ~= nil then
          local path = vim.split(query_name, '%.')
          if metadata[id] and metadata[id].range then
            insert_to_path(prepared_match, path, add_bytes(bufnr, metadata[id].range))
          else
            local srow, scol, sbyte, erow, ecol, ebyte = nodes[1]:range(true)
            if #nodes > 1 then
              local _, _, _, e_erow, e_ecol, e_ebyte = nodes[#nodes]:range(true)
              erow = e_erow
              ecol = e_ecol
              ebyte = e_ebyte
            end
            insert_to_path(prepared_match, path, { srow, scol, sbyte, erow, ecol, ebyte })
          end
        end
      end

      if metadata.range and metadata.range[7] then
        ---@cast metadata TSTextObjects.Metadata
        local query_name = metadata.range[7]
        local path = vim.split(query_name, '%.')
        insert_to_path(prepared_match, path, {
          metadata.range[1],
          metadata.range[2],
          metadata.range[3],
          metadata.range[4],
          metadata.range[5],
          metadata.range[6],
        })
      end

      matches[#matches + 1] = prepared_match
    end
  end
  return matches
end, function(bufnr, query_group, root)
  return string.format('%d-%s-%s', bufnr, root:id(), query_group)
end)

---@param tbl table<string, any|table<string, any>> the table to access
---@param path string the '.' separated path
---@return any|nil result the value at path or nil
local function get_at_path(tbl, path)
  if path == '' then
    return tbl
  end

  local segments = vim.split(path, '%.')
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == 'table' then
      ---@type any
      result = result[segment]
    end
  end

  return result
end

-- TODO(clason): memoize?
---@param bufnr integer
---@param query_string string
---@param query_group string
---@return Range6[]
local function get_capture_ranges_recursively(bufnr, query_string, query_group)
  if query_string:sub(1, 1) ~= '@' then
    error('Captures must start with "@"')
    return {}
  end
  query_string = query_string:sub(2)

  local parser = ts.get_parser(bufnr)
  if not parser then
    return {}
  end

  local ranges = {} ---@type Range6[]
  parser:for_each_tree(function(tree, lang_tree)
    local tree_lang = lang_tree:lang()

    local matches = get_query_matches(bufnr, query_group, tree:root(), tree_lang)
    for _, match in pairs(matches) do
      local found = get_at_path(match, query_string)
      if found then
        ---@cast found Range6
        table.insert(ranges, found)
      end
    end
  end)

  return ranges
end

---@param bufnr integer
---@param capture_string string
---@param query_group string
---@param filter_predicate fun(current_range: Range6): boolean
---@param scoring_function fun(current_range: Range6): number
---@return Range6?
function M.find_best_range(bufnr, capture_string, query_group, filter_predicate, scoring_function)
  local parser = ts.get_parser(bufnr)
  if not parser then
    return {}
  end
  parser:parse(true)

  local first_tree = parser:trees()[1]
  local root = first_tree:root()
  local lang = parser:lang()

  if string.sub(capture_string, 1, 1) == '@' then
    --remove leading "@"
    capture_string = string.sub(capture_string, 2)
  end

  local best ---@type Range6?
  local best_score ---@type number

  local matches = get_query_matches(bufnr, query_group, root, lang)
  for _, maybe_match in pairs(matches) do
    local range = get_at_path(maybe_match, capture_string)
    ---@cast range Range6

    if range and filter_predicate(range) then
      local current_score = scoring_function(range)
      if not best then
        best = range
        best_score = current_score
      end
      if current_score > best_score then
        best = range
        best_score = current_score
      end
    end
  end
  return best
end

---@param range Range4
---@param row integer
---@param col integer
---@return boolean
local function is_in_range(range, row, col)
  local start_row, start_col, end_row, end_col = unpack(range) ---@type integer, integer, integer, integer
  end_col = end_col - 1

  local is_in_rows = start_row <= row and end_row >= row
  local is_after_start_col_if_needed = true
  if start_row == row then
    is_after_start_col_if_needed = col >= start_col
  end
  local is_before_end_col_if_needed = true
  if end_row == row then
    is_before_end_col_if_needed = col <= end_col
  end
  return is_in_rows and is_after_start_col_if_needed and is_before_end_col_if_needed
end

---@param range1 Range4
---@param range2 Range4
---@return boolean
local function contains(range1, range2)
  return is_in_range(range1, range2[1], range2[2]) and is_in_range(range1, range2[3], range2[4])
end

---@param range Range6
---@return Range4
function M.torange4(range)
  return { range[1], range[2], range[4], range[5] }
end

--- Get the best `TSTextObjects.Range` at a given point
--- If the point is inside a `TSTextObjects.Range`, the smallest range is returned
--- If the point is not inside a `TSTextObjects.Range`, the closest one is returned
--- (if `opts.lookahead` or `opts.lookbehind` is true)
---@param ranges Range6[] list of ranges
---@param row number 0-indexed
---@param col number 0-indexed
---@param opts {lookahead: boolean?, lookbehind: boolean?} lookahead and lookbehind options
---@return Range6?
local function best_range_at_point(ranges, row, col, opts)
  local range_length ---@type integer
  local smallest_range ---@type Range6
  local earliest_start ---@type integer

  local lookahead_match_length ---@type integer
  local lookahead_largest_range ---@type Range6
  local lookahead_earliest_start ---@type integer
  local lookbehind_match_length ---@type integer
  local lookbehind_largest_range ---@type Range6
  local lookbehind_earliest_start ---@type integer

  for _, range in pairs(ranges) do
    if range and is_in_range(M.torange4(range), row, col) then
      local length = range[6] - range[3]
      if not range_length or length < range_length then
        smallest_range = range
        range_length = length
      end
      -- for nodes with same length take the one with earliest start
      if range_length and length == smallest_range[6] - smallest_range[3] then
        local start_byte = range[3]
        if not earliest_start or start_byte < earliest_start then
          smallest_range = range
          range_length = length
          earliest_start = start_byte
        end
      end
    elseif opts.lookahead then
      local start_line, start_col, start_byte = range[1], range[2], range[3]
      if start_line > row or start_line == row and start_col > col then
        local length = range[6] - range[3]
        if
          not lookahead_earliest_start
          or lookahead_earliest_start > start_byte
          or (lookahead_earliest_start == start_byte and lookahead_match_length < length)
        then
          lookahead_match_length = length
          lookahead_largest_range = range
          lookahead_earliest_start = start_byte
        end
      end
    elseif opts.lookbehind then
      local start_line, start_col, start_byte = range[1], range[2], range[3]
      if start_line < row or start_line == row and start_col < col then
        local length = range[6] - range[3]
        if
          not lookbehind_earliest_start
          or lookbehind_earliest_start < start_byte
          or (lookbehind_earliest_start == start_byte and lookbehind_match_length > length)
        then
          lookbehind_match_length = length
          lookbehind_largest_range = range
          lookbehind_earliest_start = start_byte
        end
      end
    end
  end

  if smallest_range then
    return smallest_range
  elseif lookahead_largest_range then
    return lookahead_largest_range
  elseif lookbehind_largest_range then
    return lookbehind_largest_range
  end
end

--- Get the best range at a given point
--- Similar to `best_range_at_point` but it will search within the `@*.outer` capture if possible.
--- For example, `@function.inner` will select the inner part of what `@function.outer` would select.
--- Without this logic, `@function.inner` can select the larger context (e.g. the main function)
--- when it's just before the start of the inner range.
--- Or it will look ahead and choose the next inner range instead of selecting the current function
--- when it's just after the end of the inner range (e.g. the "end" keyword of the function)
---@param query_string string
---@param query_group string
---@param bufnr? integer
---@param pos? {[1]: integer, [2]: integer}
---@param opts? {lookahead: boolean?, lookbehind: boolean?} lookahead and lookbehind options
---@return Range6?
function M.textobject_at_point(query_string, query_group, bufnr, pos, opts)
  opts = opts or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  pos = pos or vim.api.nvim_win_get_cursor(0)

  local row, col = unpack(pos) --[[@as integer, integer]]
  row = row - 1

  if not string.match(query_string, '^@.*') then
    error('Captures must start with "@"')
  end

  local ranges = get_capture_ranges_recursively(bufnr, query_string, query_group)
  if vim.endswith(query_string, 'outer') then
    local range = best_range_at_point(ranges, row, col, opts)
    return range
  else
    -- query string is @*.inner or @*
    -- First search the @*.outer instead, and then search the @*.inner within the range of the @*.outer
    local query_string_outer = string.gsub(query_string, '%..*', '.outer')
    if query_string_outer == query_string then
      query_string_outer = query_string .. '.outer'
    end

    local ranges_outer = get_capture_ranges_recursively(bufnr, query_string_outer, query_group)
    if #ranges_outer == 0 then
      -- Outer query doesn't exist or doesn't match anything
      -- Return the best range from the entire buffer, just like the @*.outer case
      local range = best_range_at_point(ranges, row, col, opts)
      return range
    end

    -- Note that outer ranges don't perform lookahead
    local range_outer = best_range_at_point(ranges_outer, row, col, {})
    if range_outer == nil then
      -- No @*.outer found
      -- Return the best range from the entire buffer, just like the @*.outer case
      local range = best_range_at_point(ranges, row, col, opts)
      return range
    end

    local ranges_within_outer = {}
    for _, range in ipairs(ranges) do
      if contains(M.torange4(range_outer), M.torange4(range)) then
        table.insert(ranges_within_outer, range)
      end
    end
    if #ranges_within_outer == 0 then
      -- No @*.inner found within the range of the @*.outer
      -- Return the best range from the entire buffer, just like the @*.outer case
      local range = best_range_at_point(ranges, row, col, opts)
      return range
    else
      -- Find the best range from the cursor position
      local range = best_range_at_point(ranges_within_outer, row, col, opts)
      if range ~= nil then
        return range
      else
        -- If failed,
        -- find the best range within the range of the @*.outer
        -- starting from the outer range's start position (not the cursor position)
        -- with lookahead enabled
        range = best_range_at_point(
          ranges_within_outer,
          range_outer[1],
          range_outer[2],
          { lookahead = true }
        )
        return range
      end
    end
  end
end

---@param lang? string
---@param query_group? string
---@return string[]
M.available_textobjects = memoize(function(lang, query_group)
  if not lang then
    return {}
  end

  query_group = query_group or 'textobjects'
  local parsed_queries =
    ts.query.get(lang_to_parser[lang] and lang_to_parser[lang] or lang, query_group)
  if not parsed_queries then
    return {}
  end

  return parsed_queries.captures or {}
end, function(lang, query_group)
  return string.format('%s-%s', lang, query_group)
end)

---@param bufnr integer
---@param query_group? string
---@param queries? string[]
--- @return boolean
function M.check_support(bufnr, query_group, queries)
  query_group = query_group or 'textobjects'

  local filetype = vim.bo[bufnr].filetype
  local buf_lang = ts.language.get_lang(filetype) or filetype
  if not buf_lang then
    return false
  end
  local parser = ts.get_parser(bufnr, buf_lang)
  if not parser then
    return false
  end

  local available_textobjects = M.available_textobjects(buf_lang, query_group)
  if not available_textobjects then
    return false
  end

  if queries then
    if vim.tbl_isempty(queries) then
      return false
    end

    for _, query in ipairs(queries) do
      if not vim.list_contains(available_textobjects, query:sub(2)) then
        return false
      end
    end
    return true
  end

  return true
end

return M
