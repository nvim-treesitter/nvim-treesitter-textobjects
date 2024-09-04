(function_declaration) @function.outer

(function_declaration
  (function_body_declaration
    (tf_port_list)
    .
    (_) @_start @_end
    (_)? @_end
    .
    "endfunction"
    (#make-range! "function.inner" @_start @_end)))

(seq_block) @block.outer

(seq_block
  .
  (_) @_start @_end
  (_)? @_end
  .
  (#make-range! "block.inner" @_start @_end))
