[
  (loop_generate_construct)
  (loop_statement)
] @loop.outer

[
  (conditional_statement)
  (case_item)
] @conditional.outer

(comment) @comment.outer

(function_declaration) @function.outer

(always_construct) @block.outer

[
  (module_declaration)
] @class.outer
