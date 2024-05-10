(attribute
  (identifier) @assignment.lhs
  (expression) @assignment.inner @assignment.rhs) @assignment.outer

(attribute
  (identifier) @assignment.inner)

(block
  (body)? @block.inner) @block.outer

(block
  (body
    (_) @statement.outer))

(function_call
  (function_arguments) @call.inner) @call.outer

(comment) @comment.outer

(conditional
  (expression) @conditional.inner) @conditional.outer

(for_cond
  (expression) @conditional.inner) @conditional.outer

(for_expr
  (for_object_expr
    (for_intro) @loop.inner
    (expression) @loop.inner
    (expression) @loop.inner
    (for_cond)? @loop.inner)) @loop.outer

(for_expr
  (for_object_expr
    (for_intro) @loop.inner))

(for_expr
  (for_object_expr
    (expression) @loop.inner))

(for_expr
  (for_tuple_expr
    (for_intro) @loop.inner
    (expression) @loop.inner
    (for_cond)? @loop.inner)) @loop.outer

(for_expr
  (for_tuple_expr
    (for_intro) @loop.inner))

(for_expr
  (for_tuple_expr
    (expression) @loop.inner))

(numeric_lit) @number.inner

(function_arguments
  "," @parameter.outer
  .
  (expression) @parameter.inner @parameter.outer)

(function_arguments
  .
  (expression) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)
