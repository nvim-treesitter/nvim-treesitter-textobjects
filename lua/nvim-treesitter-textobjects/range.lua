local api = vim.api

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
local Range = {}
Range.__index = Range

---@param range2 TSTextObjects.Range
function Range:__eq(range2)
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
function Range:new(start_row, start_col, start_byte, end_row, end_col, end_byte, parent_id, id, bufnr)
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
function Range:from_node(node, bufnr)
  local start_row, start_col, start_byte, end_row, end_col, end_byte = node:range(true)
  local id = node:id()
  local parent_id = node:parent():id()
  return Range:new(start_row, start_col, start_byte, end_row, end_col, end_byte, parent_id, id, bufnr)
end

--- Returns Range4 taking into account the `offset` directive
---
---@return Range4
function Range:range4()
  if self.metadata and self.metadata.range then
    return self.metadata.range
  end

  return { self.start_row, self.start_col, self.end_row, self.end_col }
end

--- Sets Range4 taking into account the `offset` directive
---
---@param range4 Range4
function Range:set_range4(range4)
  if self.metadata and self.metadata.range then
    self.metadata.range = range4
  end
  self.start_row = range4[1]
  self.start_col = range4[2]
  self.end_row = range4[3]
  self.end_col = range4[4]
end

---@return lsp.Range
function Range:to_lsp_range()
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

---@return Range4
function Range:to_vim_range()
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
  return { srow, scol, erow, ecol }
end

---@return string[]
function Range:get_text()
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
function Range:is_in_range(row, col)
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
function Range:contains(range)
  return self:is_in_range(range.start_row, range.start_col) and self:is_in_range(range.end_row, range.end_col)
end

---@return integer
function Range:length()
  return self.end_byte - self.start_byte
end

return Range
