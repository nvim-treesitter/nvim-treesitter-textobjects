function! nvim_treesitter_textobjects#available_textobjects(arglead, cmdline, cursorpos) abort
    return join(luaeval("vim.tbl_map(function(o) return '@'..o end, require'nvim-treesitter.textobjects.shared'.available_textobjects())"), "\n")
endfunction

function! nvim_treesitter_textobjects#repeatable(cmd) abort
    function! s:inner(...) closure abort
        execute a:cmd
    endfunction
    let &operatorfunc=get(funcref('s:inner'), 'name')
    return 'g@l'
endfunction
