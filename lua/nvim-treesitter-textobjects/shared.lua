local api = vim.api
local ts = vim.treesitter

local M = {}

local EMPTY_ITER = function() end

function M.set_jump()
  vim.cmd "normal! m'"
end

---@param range integer[]
---@param buf integer|nil
---@return integer, integer, integer, integer
function M.get_vim_range(range, buf)
  ---@type integer, integer, integer, integer
  local srow, scol, erow, ecol = unpack(range)
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1

  if ecol == 0 then
    -- Use the value of the last col of the previous row instead.
    erow = erow - 1
    if not buf or buf == 0 then
      ecol = vim.fn.col { erow, "$" } - 1
    else
      ecol = #api.nvim_buf_get_lines(buf, erow - 1, erow, false)[1]
    end
    ecol = math.max(ecol, 1)
  end
  return srow, scol, erow, ecol
end

---@param node TSNode
---@return number
local function node_length(node)
  local _, _, start_byte = node:start()
  local _, _, end_byte = node:end_()
  return end_byte - start_byte
end

---@class QueryInfo
---@field root TSNode
---@field source integer
---@field start integer
---@field stop integer

---@param bufnr integer
---@param query_name string
---@param root TSNode?
---@param root_lang string?
---@return Query?
---@return QueryInfo?
local function prepare_query(bufnr, query_name, root, root_lang)
  local buf_lang = ts.language.get_lang(vim.bo[bufnr].filetype)
  local parser = ts.get_parser(bufnr, buf_lang)

  if not root then
    local first_tree = parser:trees()[1]

    if first_tree then
      root = first_tree:root()
    end
  end

  if not root then
    return
  end

  local range = { root:range() } ---@type integer[]

  if not root_lang then
    local lang_tree = parser:language_for_range(range)

    if lang_tree then
      root_lang = lang_tree:lang()
    end
  end

  if not root_lang then
    return
  end

  -- TODO (TheLeoP): should be cached?
  local query = ts.query.get(root_lang, query_name)
  if not query then
    return
  end

  return query,
    {
      root = root,
      source = bufnr,
      start = range[1],
      -- The end row is exclusive so we need to add 1 to it.
      stop = range[3] + 1,
    }
end

---@param object any
---@param path string[]
---@param value any
local function insert_to_path(object, path, value)
  local curr_obj = object

  for index = 1, (#path - 1) do
    if curr_obj[path[index]] == nil then
      curr_obj[path[index]] = {}
    end

    curr_obj = curr_obj[path[index]]
  end

  curr_obj[path[#path]] = value
end

---@param query Query
---@param bufnr integer
---@param start_row integer
---@param end_row integer
---@return fun():table|nil
local function iter_prepared_matches(query, qnode, bufnr, start_row, end_row)
  local matches = query:iter_matches(qnode, bufnr, start_row, end_row)

  local function iterator()
    local pattern, match, metadata = matches()
    if pattern ~= nil then
      local prepared_match = {}

      -- Extract capture names from each match
      for id, node in pairs(match) do
        local name = query.captures[id] -- name of the capture in the query
        if name ~= nil then
          local path = vim.split(name .. ".node", "%.")
          insert_to_path(prepared_match, path, node)
          local metadata_path = vim.split(name .. ".metadata", "%.")
          insert_to_path(prepared_match, metadata_path, metadata[id])
        end
      end

      return prepared_match
    end
  end
  return iterator
end

---@param bufnr integer the buffer
---@param query_group string the query file to use
---@param root TSNode? the root node
---@param root_lang? string the root node lang, if known
local function iter_group_results(bufnr, query_group, root, root_lang)
  local query, params = prepare_query(bufnr, query_group, root, root_lang)
  if not query then
    return EMPTY_ITER
  end
  assert(params)

  return iter_prepared_matches(query, params.root, params.source, params.start, params.stop)
end

---@param tbl table the table to access
---@param path string the '.' separated path
---@return table|nil result the value at path or nil
local function get_at_path(tbl, path)
  if path == "" then
    return tbl
  end

  local segments = vim.split(path, "%.")
  ---@type table[]|table
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == "table" then
      ---@type table
      -- TODO: figure out the actual type of tbl
      result = result[segment]
    end
  end

  return result
end

---@param bufnr integer the buffer
---@param capture string
---@param query_group string the name of query group (highlights or injections for example)
---@param root TSNode node from where to start the search
---@param lang string the language from where to get the captures.
---@return TSNode[]
local function get_capture_matches(bufnr, capture, query_group, root, lang)
  local captures = { capture }
  local strip_captures = {} ---@type string[]
  for i, capture in ipairs(captures) do
    if capture:sub(1, 1) ~= "@" then
      error 'Captures must start with "@"'
      return {}
    end
    -- Remove leading "@".
    strip_captures[i] = capture:sub(2)
  end

  local matches = {} ---@type TSNode[]
  for match in iter_group_results(bufnr, query_group, root, lang) do
    for _, capture in ipairs(strip_captures) do
      local node = get_at_path(match, capture)
      if node then
        table.insert(matches, node)
      end
    end
  end
  return matches
end

---@param bufnr integer
---@param query_string string
---@param query_group string
---@return TSNode[]
local function get_capture_matches_recursively(bufnr, query_string, query_group)
  local lang = ts.language.get_lang(vim.bo[bufnr].filetype)
  local parser = ts.get_parser(bufnr, lang)

  local matches = {} ---@type TSNode[]
  parser:for_each_tree(function(tree, lang_tree)
    local tree_lang = lang_tree:lang()
    local capture, type_ = query_string, query_group

    if capture then
      vim.list_extend(matches, get_capture_matches(bufnr, capture, type_, tree:root(), tree_lang))
    end
  end)

  return matches
end

---@param bufnr integer
---@param capture_string string
---@param query_group string
---@param filter_predicate fun(match: table): boolean
---@param scoring_function fun(match: table): number
---@param root TSNode?
---@return table|unknown
function M.find_best_match(bufnr, capture_string, query_group, filter_predicate, scoring_function, root)
  if string.sub(capture_string, 1, 1) == "@" then
    --remove leading "@"
    capture_string = string.sub(capture_string, 2)
  end

  local best ---@type table|nil
  local best_score ---@type number

  for maybe_match in iter_group_results(bufnr, query_group, root) do
    local match = get_at_path(maybe_match, capture_string)

    if match and filter_predicate(match) then
      local current_score = scoring_function(match)
      if not best then
        best = match
        best_score = current_score
      end
      if current_score > best_score then
        best = match
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

-- Convert single query string to list for backwards compatibility and the Vim commands
function M.make_query_strings_table(query_strings)
  return type(query_strings) == "string" and { query_strings } or query_strings
end

-- Get query strings from regex
function M.get_query_strings_from_regex(query_strings_regex, query_group, lang)
  query_strings_regex = M.make_query_strings_table(query_strings_regex)
  query_group = query_group or "textobjects"
  lang = lang or ts.language.get_lang(vim.bo.filetype)
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
  lang = lang or ts.language.get_lang(vim.bo.filetype)
  query_group = query_group or "textobjects"
  local parsed_queries = ts.query.get(lang, query_group)
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
---@param opts {lookahead: boolean, lookbehind: boolean} lookahead and lookbehind options
---@return integer[]|nil,
---@return TSNode|nil,
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
      local length = node_length(m.node)
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
        local length = node_length(m.node)
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
        local length = node_length(m.node)
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
---@param query_string string
---@param query_group string
---@param pos? integer[]
---@param bufnr? integer
---@param opts? {lookahead: boolean, lookbehind: boolean} lookahead and lookbehind options
---@return integer|nil bufnr
---@return integer[]|nil range
---@return TSNode|nil node
function M.textobject_at_point(query_string, query_group, pos, bufnr, opts)
  query_group = query_group or "textobjects"
  opts = opts or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lang = ts.language.get_lang(vim.bo.filetype)
  if not lang then
    return
  end

  local row, col = unpack(pos or vim.api.nvim_win_get_cursor(0))
  row = row - 1

  if not string.match(query_string, "^@.*") then
    error 'Captures must start with "@"'
    return
  end

  local matches = get_capture_matches_recursively(bufnr, query_string, query_group)
  if vim.endswith(query_string, "outer") then
    local range, node = best_match_at_point(matches, row, col, opts)
    return bufnr, range, node
  else
    -- query string is @*.inner or @*
    -- First search the @*.outer instead, and then search the @*.inner within the range of the @*.outer
    local query_string_outer = string.gsub(query_string, "%..*", ".outer")
    if query_string_outer == query_string then
      query_string_outer = query_string .. ".outer"
    end

    local matches_outer = get_capture_matches_recursively(bufnr, query_string_outer, query_group)
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
      if ts.node_contains(node_outer, { match.node:range() }) then
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
  node = node or vim.treesitter.get_node()
  bufnr = bufnr or api.nvim_get_current_buf()
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

  local next_node = M.find_best_match(bufnr, query_string, query_group, filter_function, scoring_function)

  return next_node and next_node.node
end

function M.previous_textobject(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  node = node or vim.treesitter.get_node()
  bufnr = bufnr or api.nvim_get_current_buf()
  if not node then
    return
  end

  local _, _, node_start = node:start() ---@type integer, integer, integer
  local search_end, _ ---@type integer, integer
  if overlapping_range_ok then
    _, _, search_end = node:end_() ---@type integer, integer, integer
    search_end = search_end - 1
  else
    _, _, search_end = node:start() ---@type integer, integer, integer
  end

  local function filter_function(match)
    if not same_parent or node:parent() == match.node:parent() then
      local _, _, end_ = match.node:end_() ---@type integer, integer, integer
      local _, _, start = match.node:start() ---@type integer, integer, integer
      return end_ <= search_end and start < node_start
    end
  end

  local function scoring_function(match)
    local _, _, node_end = match.node:end_() ---@type integer, integer, integer
    return node_end
  end

  local previous_node = M.find_best_match(bufnr, query_string, query_group, filter_function, scoring_function)

  return previous_node and previous_node.node
end

return M
