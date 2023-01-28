local M = {}

local assert = require "luassert"
local Path = require "plenary.path"

-- Test in all possible col position
-- f, F, t, T
-- ; , repeat
-- count repeat
function M.run_builtin_find_test(file, spec)
  assert.are.same(1, vim.fn.filereadable(file), string.format('File "%s" not readable', file))

  -- load reference file
  vim.cmd(string.format("edit %s", file))

  vim.api.nvim_win_set_cursor(0, { spec.row, 0 })
  local line = vim.api.nvim_get_current_line()
  local num_cols = #line

  for col = 0, num_cols - 1 do
    for _, cmd in pairs { "f", "F", "t", "T" } do
      for _, repeat_cmd in pairs { ";", "," } do
        -- Get ground truth using vim's built-in search and repeat
        vim.api.nvim_win_set_cursor(0, { spec.row, col })
        local gt_cols = {}
        vim.cmd([[normal! ]] .. cmd .. spec.char)
        gt_cols[#gt_cols + 1] = vim.fn.col "."
        vim.cmd([[normal! ]] .. repeat_cmd)
        gt_cols[#gt_cols + 1] = vim.fn.col "."
        vim.cmd([[normal! 2]] .. repeat_cmd)
        gt_cols[#gt_cols + 1] = vim.fn.col "."
        vim.cmd([[normal! l]] .. repeat_cmd)
        gt_cols[#gt_cols + 1] = vim.fn.col "."
        vim.cmd([[normal! h]] .. repeat_cmd)
        gt_cols[#gt_cols + 1] = vim.fn.col "."
        vim.cmd([[normal! 2]] .. cmd .. spec.char)
        gt_cols[#gt_cols + 1] = vim.fn.col "."

        -- test using tstextobj repeatable_move.lua
        vim.api.nvim_win_set_cursor(0, { spec.row, col })
        local ts_cols = {}
        vim.cmd([[normal ]] .. cmd .. spec.char)
        assert.are.same(spec.row, vim.fn.line ".", "Command shouldn't move cursor over rows")
        ts_cols[#ts_cols + 1] = vim.fn.col "."
        vim.cmd([[normal ]] .. repeat_cmd)
        assert.are.same(spec.row, vim.fn.line ".", "Command shouldn't move cursor over rows")
        ts_cols[#ts_cols + 1] = vim.fn.col "."
        vim.cmd([[normal 2]] .. repeat_cmd)
        assert.are.same(spec.row, vim.fn.line ".", "Command shouldn't move cursor over rows")
        ts_cols[#ts_cols + 1] = vim.fn.col "."
        vim.cmd([[normal l]] .. repeat_cmd)
        assert.are.same(spec.row, vim.fn.line ".", "Command shouldn't move cursor over rows")
        ts_cols[#ts_cols + 1] = vim.fn.col "."
        vim.cmd([[normal h]] .. repeat_cmd)
        assert.are.same(spec.row, vim.fn.line ".", "Command shouldn't move cursor over rows")
        ts_cols[#ts_cols + 1] = vim.fn.col "."
        vim.cmd([[normal 2]] .. cmd .. spec.char)
        assert.are.same(spec.row, vim.fn.line ".", "Command shouldn't move cursor over rows")
        ts_cols[#ts_cols + 1] = vim.fn.col "."

        assert.are.same(
          gt_cols,
          ts_cols,
          string.format("Command %s works differently than vim's built-in find, col: %d", cmd, col)
        )
      end
    end
  end
  -- clear any changes to avoid 'No write since last change (add ! to override)'
  vim.cmd "edit!"
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

function Runner:builtin_find(file, spec, title)
  title = title and title or tostring(spec.row)
  self.it(string.format("%s[%s]", file, title), function()
    local path = self.base_dir / file
    M.run_builtin_find_test(path.filename, spec)
  end)
end

M.Runner = Runner

return M
