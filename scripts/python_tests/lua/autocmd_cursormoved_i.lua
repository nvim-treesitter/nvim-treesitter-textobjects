vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
  buffer = vim.g.nvim_communicator_buffer_id,
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    cursor_pos_row = cursor_pos[1] - 1
    cursor_pos_col = cursor_pos[2]
    Nvim_communicator_rpcnotify("CursorMovedI", cursor_pos_row, cursor_pos_col)
  end,
})
