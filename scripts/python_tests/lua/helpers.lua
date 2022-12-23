function Nvim_communicator_rpcnotify(...)
  if vim.g.nvim_communicator_channel_id ~= nil and vim.g.nvim_communicator_channel_id > 0 then
    if not pcall(vim.rpcnotify, vim.g.nvim_communicator_channel_id, ...) then
      print "Nvim Communicator: RPC channel closed. Stop sending all notifications."
      vim.g.nvim_communicator_channel_id = -1
    end
  end
end

function Nvim_communicator_grab_entire_buffer()
  local entire_buf = vim.api.nvim_buf_get_lines(vim.g.nvim_communicator_buffer_id, 0, -1, false)
  Nvim_communicator_rpcnotify("grab_entire_buf", entire_buf)
end

function Nvim_communicator_visual_range()
  -- check vim mode
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" and mode ~= "V" and mode ~= "" then
    return
  end
  -- local visual_selection = vim.api.nvim_buf_get_lines(vim.g.nvim_communicator_buffer_id, vim.fn.getpos("'<")[2] - 1, vim.fn.getpos("'>")[2], false)
  -- start_row = vim.fn.getpos("'<")[2] - 1
  -- start_col = vim.fn.getpos("'<")[3]
  -- end_row = vim.fn.getpos("'>")[2] - 1
  -- end_col = vim.fn.getpos("'>")[3]
  start_row = vim.nvim_buf_get_mark(0, "<")[1] - 1
  start_col = vim.nvim_buf_get_mark(0, "<")[2]
  end_row = vim.nvim_buf_get_mark(0, ">")[1] - 1
  end_col = vim.nvim_buf_get_mark(0, ">")[2]
  Nvim_communicator_rpcnotify("visual_range", mode, start_row, start_col, end_row, end_col)
end
