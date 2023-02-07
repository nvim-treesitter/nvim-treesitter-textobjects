local M = {}

local assert = require "luassert"
local Path = require "plenary.path"

function M.run_equal_cmds_test(file, spec)
  assert.are.same(1, vim.fn.filereadable(file), string.format('File "%s" not readable', file))

  -- load reference file
  vim.cmd(string.format("edit %s", file))

  local first_cmd_lines = nil
  for _, cmd in pairs(spec.cmds) do
    -- set cursor pos
    vim.api.nvim_win_set_cursor(0, { spec.row, spec.col })
    -- run command
    vim.cmd([[normal ]] .. vim.api.nvim_replace_termcodes(cmd, true, true, true))

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    if first_cmd_lines == nil then
      first_cmd_lines = lines
    end

    -- clear any changes (avoid no write since last change)
    -- call before assert
    vim.cmd "edit!"

    assert.are.same(
      first_cmd_lines,
      lines,
      string.format("Commands %s and %s produces different results", spec.cmds[1], cmd)
    )
  end
end

local Runner = {}
Runner.__index = Runner

-- Helper to avoid boilerplate when defining tests
-- @param it  the "it" function that busted defines globally in spec files
-- @param base_dir  all other paths will be resolved relative to this directory
-- @param buf_opts  buffer options passed to set_buf_indent_opts
function Runner:new(it, base_dir, buf_opts)
  local runner = {}
  runner.it = it
  runner.base_dir = Path:new(base_dir)
  runner.buf_opts = buf_opts
  return setmetatable(runner, self)
end

function Runner:equal_cmds(file, spec, title)
  title = title and title or string.format("%s,%s", spec.row, spec.col)
  self.it(string.format("%s[%s]", file, title), function()
    local path = self.base_dir / file
    M.run_equal_cmds_test(path.filename, spec)
  end)
end

M.Runner = Runner

return M
