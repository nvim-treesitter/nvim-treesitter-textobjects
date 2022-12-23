vim.api.nvim_create_autocmd({ "VimLeave" }, {
  -- Don't set the buffer. You can leave from another file.
  callback = function()
    Nvim_communicator_rpcnotify "VimLeave"
  end,
})
