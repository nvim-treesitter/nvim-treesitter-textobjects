local api = vim.api
local ts = vim.treesitter

local M = {}

local EMPTY_ITER = function() end

function M.set_jump()
  vim.cmd "normal! m'"
end

---@param object any
---@param path string[]
---@param value any
local function insert_to_path(object, path, value)
  ---@type table<string, any|table<string, any>>
  local curr_obj = object

  for index = 1, (#path - 1) do
    if curr_obj[path[index]] == nil then
      curr_obj[path[index]] = {}
    end

    curr_obj = curr_obj[path[index]]
  end

  curr_obj[path[#path]] = value
end

-- luacheck: push ignore 631
---@alias TSTextObjects.Metadata {range: {[1]: number, [2]: number, [3]: number, [4]: number, [5]: number, [6]: number, [7]: string}}
-- luacheck: pop

---@param query vim.treesitter.Query
---@param qnode TSNode
---@param bufnr integer
---@param start_row integer
---@param end_row integer
---@return fun():table<string, any|table<string, any>>?
local function iter_prepared_matches(query, qnode, bufnr, start_row, end_row)
  local matches = query:iter_matches(qnode, bufnr, start_row, end_row)

  local function iterator()
    local pattern, match, metadata = matches()
    if pattern == nil then
      return
    end

    local prepared_match = {}

    -- Extract capture names from each match
    for id, node in pairs(match) do
      local query_name = query.captures[id] -- name of the capture in the query
      if query_name ~= nil then
        local path = vim.split(query_name, "%.")
        local range = M.Range:from_node(node, bufnr)
        range.metadata = metadata[id]
        insert_to_path(prepared_match, path, range)
      end
    end

    if metadata.range and metadata.range[7] then
      ---@cast metadata TSTextObjects.Metadata
      local query_name = metadata.range[7]
      local path = vim.split(query_name, "%.")
      insert_to_path(
        prepared_match,
        path,
        M.Range:new(
          metadata.range[1],
          metadata.range[2],
          metadata.range[3],
          metadata.range[4],
          metadata.range[5],
          metadata.range[6],
          "-1",
          "-1"
        )
      )
    end

    return prepared_match
  end
  return iterator
end

---@param bufnr integer the buffer
---@param query_group string the query file to use
---@param root TSNode the root node
---@param root_lang string the root node lang, if known
local function iter_group_results(bufnr, query_group, root, root_lang)
  -- TODO (TheLeoP): should be cached?
  local query = ts.query.get(root_lang, query_group)
  if not query then
    return EMPTY_ITER
  end

  local range = { root:range() } ---@type Range4
  local start = range[1]
  -- The end row is exclusive so we need to add 1 to it.
  local stop = range[3] + 1

  return iter_prepared_matches(query, root, bufnr, start, stop)
end

---@param tbl table<string, any|table<string, any>> the table to access
---@param path string the '.' separated path
---@return unknown|nil result the value at path or nil
local function get_at_path(tbl, path)
  if path == "" then
    return tbl
  end

  local segments = vim.split(path, "%.")
  ---@type table<string, any|table<string, any>>
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == "table" then
      result = result[segment]
    end
  end

  return result
end

---@param bufnr integer
---@param query_string string
---@param query_group string
---@return TSTextObjects.Range[]
local function get_capture_ranges_recursively(bufnr, query_string, query_group)
  if query_string:sub(1, 1) ~= "@" then
    error 'Captures must start with "@"'
    return {}
  end
  query_string = query_string:sub(2)

  local lang = ts.language.get_lang(vim.bo[bufnr].filetype)
  local parser = ts.get_parser(bufnr, lang)

  local ranges = {} ---@type TSTextObjects.Range[]
  parser:for_each_tree(function(tree, lang_tree)
    local tree_lang = lang_tree:lang()

    for match in iter_group_results(bufnr, query_group, tree:root(), tree_lang) do
      local found = get_at_path(match, query_string)
      if found then
        ---@cast found TSTextObjects.Range
        table.insert(ranges, found)
      end
    end
  end)

  return ranges
end

---@param bufnr integer
---@param capture_string string
---@param query_group string
---@param filter_predicate fun(current_range: TSTextObjects.Range): boolean
---@param scoring_function fun(current_range: TSTextObjects.Range): number
---@return TSTextObjects.Range?
function M.find_best_range(bufnr, capture_string, query_group, filter_predicate, scoring_function)
  local lang = assert(ts.language.get_lang(vim.bo[bufnr].filetype))
  local parser = ts.get_parser(bufnr, lang)
  local first_tree = parser:trees()[1]
  local root = first_tree:root()

  if string.sub(capture_string, 1, 1) == "@" then
    --remove leading "@"
    capture_string = string.sub(capture_string, 2)
  end

  local best ---@type TSTextObjects.Range?
  local best_score ---@type number

  for maybe_match in iter_group_results(bufnr, query_group, root, lang) do
    local range = get_at_path(maybe_match, capture_string)
    ---@cast range TSTextObjects.Range

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

if not unpack then
  -- luacheck: push ignore 121
  unpack = table.unpack
  -- luacheck: pop
end

--- Convert single query string to list for backwards compatibility and the Vim commands
---
---@param query_strings string|string[]
---@return string[]
function M.make_query_strings_table(query_strings)
  if type(query_strings) == "string" then
    return { query_strings }
  else
    return query_strings
  end
end

--- Get query strings from pattern
---@param query_patterns string[]
---@param query_group? string
---@param lang? string
---@return string[]
function M.get_query_strings_from_pattern(query_patterns, query_group, lang)
  query_group = query_group or "textobjects"
  lang = lang or ts.language.get_lang(vim.bo.filetype)
  local available_textobjects = M.available_textobjects(lang, query_group)
  local query_strings = {}
  for _, query_pattern in ipairs(query_patterns) do
    for _, available_textobject in ipairs(available_textobjects) do
      if string.match("@" .. available_textobject, query_pattern) then
        table.insert(query_strings, "@" .. available_textobject)
      end
    end
  end

  return query_strings
end

---@param lang? string
---@param query_group? string
---@return string[]
function M.available_textobjects(lang, query_group)
  lang = lang or ts.language.get_lang(vim.bo.filetype)
  if not lang then
    error(string.format("There ist no languare resgitered for filetype %s", vim.bo.filetype))
  end
  query_group = query_group or "textobjects"
  -- TODO (TheLeoP): should be cached?
  local parsed_queries = ts.query.get(lang, query_group)
  if not parsed_queries then
    return {}
  end
  local found_textobjects = parsed_queries.captures or {}
  for _, pattern in pairs(parsed_queries.info.patterns) do
    for _, q in ipairs(pattern) do
      local query, arg1 = unpack(q) --[=[@as string, string[]]=]
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

--- Get the best `TSTextObjects.Range` at a given point
--- If the point is inside a `TSTextObjects.Range`, the smallest range is returned
--- If the point is not inside a `TSTextObjects.Range`, the closest one is returned
--- (if `opts.lookahead` or `opts.lookbehind` is true)
---@param ranges TSTextObjects.Range[] list of ranges
---@param row number 0-indexed
---@param col number 0-indexed
---@param opts {lookahead: boolean, lookbehind: boolean} lookahead and lookbehind options
---@return TSTextObjects.Range?
local function best_range_at_point(ranges, row, col, opts)
  local range_length ---@type integer
  local smallest_range ---@type TSTextObjects.Range
  local earliest_start ---@type integer

  local lookahead_match_length ---@type integer
  local lookahead_largest_range ---@type TSTextObjects.Range
  local lookahead_earliest_start ---@type integer
  local lookbehind_match_length ---@type integer
  local lookbehind_largest_range ---@type TSTextObjects.Range
  local lookbehind_earliest_start ---@type integer

  for _, range in pairs(ranges) do
    if range and range:is_in_range(row, col) then
      local length = range:length()
      if not range_length or length < range_length then
        smallest_range = range
        range_length = length
      end
      -- for nodes with same length take the one with earliest start
      if range_length and length == smallest_range:length() then
        local start_byte = range.start_byte
        if not earliest_start or start_byte < earliest_start then
          smallest_range = range
          range_length = length
          earliest_start = start_byte
        end
      end
    elseif opts.lookahead then
      local start_line, start_col, start_byte = range.start_row, range.start_col, range.start_byte
      if start_line > row or start_line == row and start_col > col then
        local length = range:length()
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
      local start_line, start_col, start_byte = range.start_row, range.start_col, range.start_byte
      if start_line < row or start_line == row and start_col < col then
        local length = range:length()
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
---@param pos? {[1]: integer, [2]: integer}
---@param bufnr? integer
---@param opts? {lookahead: boolean, lookbehind: boolean} lookahead and lookbehind options
---@return integer bufnr
---@return TSTextObjects.Range? range
function M.textobject_at_point(query_string, query_group, pos, bufnr, opts)
  opts = opts or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  pos = pos or vim.api.nvim_win_get_cursor(0)

  local lang = ts.language.get_lang(vim.bo[bufnr].filetype)
  if not lang then
    error(string.format("There ist no languare resgitered for filetype %s", vim.bo.filetype))
  end

  local row, col = unpack(pos) --[[@as integer, integer]]
  row = row - 1

  if not string.match(query_string, "^@.*") then
    error 'Captures must start with "@"'
  end

  local ranges = get_capture_ranges_recursively(bufnr, query_string, query_group)
  if vim.endswith(query_string, "outer") then
    local range = best_range_at_point(ranges, row, col, opts)
    return bufnr, range
  else
    -- query string is @*.inner or @*
    -- First search the @*.outer instead, and then search the @*.inner within the range of the @*.outer
    local query_string_outer = string.gsub(query_string, "%..*", ".outer")
    if query_string_outer == query_string then
      query_string_outer = query_string .. ".outer"
    end

    local ranges_outer = get_capture_ranges_recursively(bufnr, query_string_outer, query_group)
    if #ranges_outer == 0 then
      -- Outer query doesn't exist or doesn't match anything
      -- Return the best range from the entire buffer, just like the @*.outer case
      local range = best_range_at_point(ranges, row, col, opts)
      return bufnr, range
    end

    -- Note that outer ranges don't perform lookahead
    local range_outer = best_range_at_point(ranges_outer, row, col, {})
    if range_outer == nil then
      -- No @*.outer found
      -- Return the best range from the entire buffer, just like the @*.outer case
      local range = best_range_at_point(ranges, row, col, opts)
      return bufnr, range
    end

    local ranges_within_outer = {}
    for _, range in ipairs(ranges) do
      if range_outer:contains(range) then
        table.insert(ranges_within_outer, range)
      end
    end
    if #ranges_within_outer == 0 then
      -- No @*.inner found within the range of the @*.outer
      -- Return the best range from the entire buffer, just like the @*.outer case
      local range = best_range_at_point(ranges, row, col, opts)
      return bufnr, range
    else
      -- Find the best range from the cursor position
      local range = best_range_at_point(ranges_within_outer, row, col, opts)
      if range ~= nil then
        return bufnr, range
      else
        -- If failed,
        -- find the best range within the range of the @*.outer
        -- starting from the outer range's start position (not the cursor position)
        -- with lookahead enabled
        range =
          best_range_at_point(ranges_within_outer, range_outer.start_row, range_outer.start_col, { lookahead = true })
        return bufnr, range
      end
    end
  end
end

---@class TSTextObjects.Range
---@field start_col integer
---@field start_row integer
---@field start_byte integer
---@field end_col integer
---@field end_row integer
---@field end_byte integer
---@field parent_id any
---@field id any
---@field bufnr integer
---@field metadata? {range?: Range4}
M.Range = {}
M.Range.__index = M.Range

---@param range2 TSTextObjects.Range
function M.Range:__eq(range2)
  if self.bufnr ~= range2.bufnr then
    return false
  end

  if self.id == -1 or range2.id == -1 then
    local srow1, scol1, erow1, ecol1 = unpack(self:range4()) ---@type integer, integer, integer, integer
    local srow2, scol2, erow2, ecol2 = unpack(range2:range4()) ---@type integer, integer, integer, integer
    return srow1 == srow2 and scol1 == scol2 and erow1 == erow2 and ecol1 == ecol2
  end

  return self.id == range2.id
end

---@param start_col integer
---@param start_row integer
---@param start_byte integer
---@param end_col integer
---@param end_row integer
---@param end_byte integer
---@param parent_id string
---@param id string
---@return TSTextObjects.Range
function M.Range:new(start_row, start_col, start_byte, end_row, end_col, end_byte, parent_id, id, bufnr)
  local range = {
    start_col = start_col,
    start_row = start_row,
    start_byte = start_byte,
    end_col = end_col,
    end_row = end_row,
    end_byte = end_byte,
    parent_id = parent_id,
    id = id,
    bufnr = bufnr,
  }
  return setmetatable(range, self)
end

---@param node TSNode
---@param bufnr integer
---@return TSTextObjects.Range
function M.Range:from_node(node, bufnr)
  local start_row, start_col, start_byte, end_row, end_col, end_byte = node:range(true)
  local id = node:id()
  local parent_id = node:parent():id()
  return M.Range:new(start_row, start_col, start_byte, end_row, end_col, end_byte, parent_id, id, bufnr)
end

--- Returns Range4 taking into account the `offset` directive
---
---@return Range4
function M.Range:range4()
  if self.metadata and self.metadata.range then
    return self.metadata.range
  end

  return { self.start_row, self.start_col, self.end_row, self.end_col }
end

--- Sets Range4 taking into account the `offset` directive
---
---@param range4 Range4
function M.Range:set_range4(range4)
  if self.metadata and self.metadata.range then
    self.metadata.range = range4
  end
  self.start_col = range4[1]
  self.start_row = range4[2]
  self.end_col = range4[3]
  self.end_row = range4[4]
end

---@return lsp.Range
function M.Range:to_lsp_range()
  return {
    start = {
      line = self.start_row,
      character = self.start_col,
    },
    ["end"] = {
      line = self.end_row,
      character = self.end_col,
    },
  }
end

---@return integer, integer, integer, integer
function M.Range:to_vim_range()
  local srow, scol, erow, ecol = unpack(self:range4()) ---@type integer, integer, integer, integer
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1

  if ecol == 0 then
    -- Use the value of the last col of the previous row instead.
    erow = erow - 1
    if not self.bufnr or self.bufnr == 0 then
      ecol = vim.fn.col { erow, "$" } - 1
    else
      ecol = #api.nvim_buf_get_lines(self.bufnr, erow - 1, erow, false)[1]
    end
    ecol = math.max(ecol, 1)
  end
  return srow, scol, erow, ecol
end

---@return string[]
function M.Range:get_text()
  if self.start_row == self.end_row then
    local line = api.nvim_buf_get_lines(self.bufnr, self.start_row, self.start_row + 1, false)[1]
    return line and { string.sub(line, self.start_col + 1, self.end_col) } or {}
  else
    local lines = api.nvim_buf_get_lines(self.bufnr, self.start_row, self.end_row + 1, false)
    if vim.tbl_isempty(lines) == nil then
      return lines
    end
    lines[1] = string.sub(lines[1], self.start_col + 1)
    -- end_row might be just after the last line. In this case the last line is not truncated.
    if #lines == self.end_row - self.start_row + 1 then
      lines[#lines] = string.sub(lines[#lines], 1, self.end_col)
    end
    return lines
  end
end

---@param row integer
---@param col integer
---@return boolean
function M.Range:is_in_range(row, col)
  local start_row, start_col, end_row, end_col = unpack(self:range4()) ---@type integer, integer, integer, integer
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

---@param range TSTextObjects.Range
---@return boolean
function M.Range:contains(range)
  return self:is_in_range(range.start_row, range.start_col) and self:is_in_range(range.end_row, range.end_col)
end

---@return integer
function M.Range:length()
  return self.end_byte - self.start_byte
end

---@param forward boolean
---@param range TSTextObjects.Range
---@param query_string string
---@param query_group string
---@param bufnr integer
---@return TSTextObjects.Range?
function M.get_adjacent(forward, range, query_string, query_group, bufnr)
  local fn = forward and M.next_textobject or M.previous_textobject
  return fn(range, query_string, query_group, bufnr)
end

---@param range TSTextObjects.Range
---@param query_string string
---@param query_group string
---@param bufnr integer
---@return TSTextObjects.Range?
function M.next_textobject(range, query_string, query_group, bufnr)
  local node_end = range.end_byte
  local search_start = node_end

  ---@param current_range TSTextObjects.Range
  ---@return boolean
  local function filter_function(current_range)
    if current_range == range then
      return false
    end
    if range.parent_id == current_range.parent_id then
      local start = current_range.start_byte
      local end_ = current_range.end_byte
      return start >= search_start and end_ >= node_end
    end
    return false
  end

  ---@param current_range TSTextObjects.Range
  ---@return integer
  local function scoring_function(current_range)
    local start = current_range.start_byte
    return -start
  end

  local next_range = M.find_best_range(bufnr, query_string, query_group, filter_function, scoring_function)

  return next_range
end

---@param range TSTextObjects.Range
---@param query_string string
---@param query_group? string
---@param bufnr integer
---@return TSTextObjects.Range?
function M.previous_textobject(range, query_string, query_group, bufnr)
  query_group = query_group or "textobjects"

  local node_start = range.start_byte
  local search_end = node_start

  ---@param current_range TSTextObjects.Range
  ---@return boolean
  local function filter_function(current_range)
    if current_range.parent_id == current_range.parent_id then
      local end_ = current_range.end_byte
      local start = current_range.start_byte
      return end_ <= search_end and start < node_start
    end
    return false
  end

  ---@param current_range TSTextObjects.Range
  ---@return integer
  local function scoring_function(current_range)
    local node_end = current_range.end_byte
    return node_end
  end

  local previous_range = M.find_best_range(bufnr, query_string, query_group, filter_function, scoring_function)

  return previous_range
end

---@param bufnr integer
---@param query_group? string
---@param queries? string[]
--- @return boolean
function M.check_support(bufnr, query_group, queries)
  query_group = query_group or "textobjects"

  local buf_lang = ts.language.get_lang(vim.bo[bufnr].filetype)
  if not buf_lang then
    return false
  end
  local parser = ts.get_parser(bufnr, buf_lang)
  if not parser then
    return false
  end
  -- TODO (TheLeoP): should be cached?
  local ok, _queries = pcall(ts.query.get, buf_lang, query_group)
  if not ok or not _queries then
    return false
  end

  if queries then
    if vim.tbl_isempty(queries) then
      return false
    end

    local available_textobjects = M.available_textobjects(buf_lang, query_group)
    for _, query in ipairs(queries) do
      if not vim.list_contains(available_textobjects, query:sub(2)) then
        return false
      end
    end
    return true
  end

  return true
end

---Memoize a function using hash_fn to hash the arguments.
---@generic F: function
---@param fn F
---@param hash_fn fun(...): any
---@return F
function M.memoize(fn, hash_fn)
  local cache = setmetatable({}, { __mode = "kv" }) ---@type table<any,any>

  return function(...)
    local key = hash_fn(...)
    if cache[key] == nil then
      local v = { fn(...) } ---@type any

      for k, value in pairs(v) do
        if value == nil then
          value[k] = vim.NIL
        end
      end

      cache[key] = v
    end

    local v = cache[key]

    for k, value in pairs(v) do
      if value == vim.NIL then
        value[k] = nil
      end
    end

    return unpack(v)
  end
end

return M
