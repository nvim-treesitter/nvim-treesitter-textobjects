vim.api.nvim_create_autocmd({ "ModeChanged" }, {
  buffer = vim.g.nvim_communicator_buffer_id,
  callback = function()
    local old_mode = vim.api.nvim_get_vvar("event")["old_mode"]
    local new_mode = vim.api.nvim_get_vvar("event")["new_mode"]
    if new_mode == "V" or new_mode == "v" or new_mode == "\x16" then
      Nvim_communicator_rpcnotify("visual_enter", old_mode, new_mode)
    end
  end,
})
