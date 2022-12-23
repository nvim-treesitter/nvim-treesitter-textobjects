function Nvim_communicator_rpcnotify(...)
  if vim.g.nvim_communicator_channel_id ~= nil and vim.g.nvim_communicator_channel_id > 0 then
    if pcall(vim.rpcnotify, vim.g.nvim_communicator_channel_id, ...) then
      -- rpcnotify is asynchronous and there is no way to know if we received all messages.
      -- So we count how many messages we sent and wait for the same number of messages to be received.
      vim.g.nvim_communicator_num_pending_msgs = vim.g.nvim_communicator_num_pending_msgs + 1
    else
      print "Nvim Communicator: RPC channel closed. Stop sending all notifications."
      vim.g.nvim_communicator_channel_id = -1
    end
  end
end

function Nvim_communicator_grab_entire_buffer()
  local entire_buf = vim.api.nvim_buf_get_lines(vim.g.nvim_communicator_buffer_id, 0, -1, false)
  Nvim_communicator_rpcnotify("grab_entire_buf", entire_buf)
end
