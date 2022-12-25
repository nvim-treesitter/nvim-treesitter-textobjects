vim.api.nvim_buf_attach(vim.g.nvim_communicator_buffer_id, false, {
  on_bytes = function(
    _,
    _,
    _,
    start_row,
    start_col,
    byte_offset,
    old_end_row,
    old_end_col,
    old_end_length,
    new_end_row,
    new_end_col,
    new_end_length
  )
    --print ("on_bytes", start_row, start_col, old_end_row, old_end_col, new_end_row, new_end_col)
    local line_count = vim.api.nvim_buf_line_count(vim.g.nvim_communicator_buffer_id)

    if new_end_row == 0 and new_end_col == 0 and new_end_length == 0 then
      -- this is a delete event
      -- changed = nil
      --
      -- NOTE: deleting lines at the end of file will result in out of bound index (will try to delete one more line than the buffer row length), so the client should handle this. I see this for Nvim 0.8.1.
      Nvim_communicator_rpcnotify(
        "on_bytes_remove",
        start_row,
        start_col,
        byte_offset,
        old_end_row,
        old_end_col,
        old_end_length
      )
    else
      -- this is an insert event
      -- old_end_row, old_end_col, old_end_length are all 0

      -- making new lines at the end of file with 'o' command or pasting will
      -- generate this incorrect event in nvim 0.8.1.
      -- modify the coordinates so that the event includes new line and not go out of bound
      if start_row + new_end_row >= line_count then
        -- from the end of start_row-1
        start_row = start_row - 1
        start_col =
          vim.api.nvim_buf_get_lines(vim.g.nvim_communicator_buffer_id, start_row, start_row + 1, false)[1]:len()
        new_end_col = vim.api
          .nvim_buf_get_lines(vim.g.nvim_communicator_buffer_id, start_row + new_end_row, start_row + new_end_row + 1, false)[1]
          :len()
        -- new_end_row is the same
        -- new_end_length is the same
      end

      local changed
      if new_end_row == 0 then
        changed = vim.api.nvim_buf_get_text(
          vim.g.nvim_communicator_buffer_id,
          start_row,
          start_col,
          start_row + new_end_row,
          start_col + new_end_col,
          {}
        )
      else
        changed = vim.api.nvim_buf_get_text(
          vim.g.nvim_communicator_buffer_id,
          start_row,
          start_col,
          start_row + new_end_row,
          new_end_col,
          {}
        )
      end

      Nvim_communicator_rpcnotify(
        "on_bytes",
        changed,
        start_row,
        start_col,
        byte_offset,
        new_end_row,
        new_end_col,
        new_end_length
      )
    end
  end,
})
