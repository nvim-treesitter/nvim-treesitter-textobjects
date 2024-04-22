local ts = vim.treesitter

---@alias TSTextObjects.Point3 {[1]: integer, [2]: integer, [3]: integer}

ts.query.add_directive("make-range!", function(match, pattern, buf, predicate, metadata)
  local query_name = predicate[2]
  local start_node_id = predicate[3]
  local end_node_id = predicate[4]

  local start_nodes = match[start_node_id]
  local end_nodes = match[end_node_id]

  assert(#start_nodes == 1, "#make-range! does not support captures on multiple nodes")
  if end_nodes then
    assert(#end_nodes == 1, "#make-range! does not support captures on multiple nodes")
  end

  local start_node ---@type TSNode|nil
  local end_node ---@type TSNode|nil
  local start_range ---@type Range4|nil
  local end_range ---@type Range4|nil
  if start_nodes then
    start_node = start_nodes[1]
    start_range = metadata[start_node_id] and metadata[start_node_id].range or { start_node:range() }
  end
  if end_nodes then
    end_node = end_nodes[1]
    end_range = metadata[end_node_id] and metadata[end_node_id].range or { end_node:range() }
  end

  ---@type TSTextObjects.Point3
  local start_pos = start_node and { start_node:start(true) } or { end_node:start(true) }
  ---@type TSTextObjects.Point3
  local end_pos = end_node and { end_node:end_(true) } or { start_node:end_(true) }

  local start_row = start_range and start_range[1] or start_pos[1]
  local start_col = start_range and start_range[2] or start_pos[2]
  local start_byte = start_pos[3]
  local end_row = end_range and end_range[3] or end_pos[1]
  local end_col = end_range and end_range[4] or end_pos[2]
  local end_byte = end_pos[3]
  metadata.range = { start_row, start_col, start_byte, end_row, end_col, end_byte, query_name }
end, { force = true, all = true })
