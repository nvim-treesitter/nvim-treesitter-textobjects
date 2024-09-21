(function_declaration
  (function_body_declaration
    (tf_port_list)
    .
    (_) @_start @_end
    (_)? @_end
    .
    "endfunction"
    (#make-range! "function.inner" @_start @_end))) @function.outer

(task_declaration
  (task_body_declaration
    (tf_port_list)
    .
    (_) @_start @_end
    (_)? @_end
    .
    "endtask"
    (#make-range! "function.inner" @_start @_end))) @function.outer

[
  (seq_block)
  (generate_block)
] @block.outer

(seq_block
  "begin"
  (simple_identifier)?
  .
  (_) @_start @_end
  (#not-kind-eq? @_start "simple_identifier")
  (_)? @_end
  .
  "end"
  (#make-range! "block.inner" @_start @_end))

(generate_block
  "begin"
  (simple_identifier)?
  .
  (_) @_start @_end
  (#not-kind-eq? @_start "simple_identifier")
  (_)? @_end
  .
  "end"
  (#make-range! "block.inner" @_start @_end))

(comment) @comment.outer
