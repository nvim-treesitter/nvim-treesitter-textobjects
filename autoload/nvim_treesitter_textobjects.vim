function! nvim_treesitter_textobjects#available_textobjects(arglead, cmdline, cursorpos) abort
    return join(luaeval("vim.tbl_map(function(o) return '@'..o end, require'nvim-treesitter.textobjects.shared'.available_textobjects())"), "\n")
endfunction
