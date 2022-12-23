vim.api.nvim_create_autocmd({ "ModeChanged" }, {
	buffer = vim.g.nvim_communicator_buffer_id,
	callback = function()
		local old_mode = vim.api.nvim_get_vvar("event")["old_mode"]
		local new_mode = vim.api.nvim_get_vvar("event")["new_mode"]
		if
			(old_mode == "v" or old_mode == "V" or old_mode == "\x16")
			and (new_mode ~= "v" and new_mode ~= "V" and new_mode ~= "\x16")
		then
			local start_row = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
			local start_col = vim.api.nvim_buf_get_mark(0, "<")[2]
			local end_row = vim.api.nvim_buf_get_mark(0, ">")[1] - 1
			local end_col = vim.api.nvim_buf_get_mark(0, ">")[2]
			Nvim_communicator_rpcnotify("visual_leave", old_mode, new_mode, start_row, start_col, end_row, end_col)
		end
	end,
})
