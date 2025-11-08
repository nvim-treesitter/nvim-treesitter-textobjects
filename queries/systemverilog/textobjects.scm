(function_declaration
  (function_body_declaration
    (tf_port_list)
    .
    _+ @function.inner
    .
    "endfunction")) @function.outer

(task_declaration
  (task_body_declaration
    (tf_port_list)
    .
    _+ @function.inner
    .
    "endtask")) @function.outer

[
  (seq_block)
  (generate_block)
] @block.outer

(seq_block
  "begin"
  (simple_identifier)?
  .
  _+ @block.inner
  .
  "end")

(generate_block
  "begin"
  (simple_identifier)?
  .
  _+ @block.inner
  .
  "end")

[
  (one_line_comment)
  (block_comment)
] @comment.outer
