local move = require('nvim-treesitter-textobjects.move')
local assert = require('luassert')

-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/883
-- On a buffer with no attached treesitter parser, every movement entry point
-- must be a silent no-op instead of raising Lua errors.
describe('move on a buffer without a treesitter parser:', function()
  it('is a silent no-op instead of raising errors', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'plain text, no parser attached' })
    vim.api.nvim_win_set_buf(0, bufnr)
    assert.is_nil(vim.treesitter.get_parser(bufnr))

    for _, fn in ipairs({
      move.goto_next_start,
      move.goto_next_end,
      move.goto_previous_start,
      move.goto_previous_end,
      move.goto_next,
      move.goto_previous,
    }) do
      local ok, err = pcall(fn, '@function.outer')
      assert.is_true(ok, err)
    end

    -- repeatable moves take no query strings; with no stored move they no-op.
    for _, fn in ipairs({
      move.repeat_last_move,
      move.repeat_last_move_next,
      move.repeat_last_move_previous,
    }) do
      local ok, err = pcall(fn)
      assert.is_true(ok, err)
    end
  end)
end)
