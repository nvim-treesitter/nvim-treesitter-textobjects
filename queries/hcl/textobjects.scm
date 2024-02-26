(attribute
 (identifier) @assignment.lhs
 (expression) @assignment.inner @assignment.rhs) @assignment.outer
(attribute
 (identifier) @assignment.inner)

(block (body)? @block.inner ) @block.outer
(block (body (_) @statement.outer))

(function_call (function_arguments) @call.inner) @call.outer

(comment) @comment.outer

(conditional
 (expression) @conditional.condition
 (expression) @conditional.lhs
 (expression) @conditional.inner @conditional.rhs) @conditional.outer
(conditional
 (expression) @conditional.inner)

(for_expr (for_object_expr (for_intro) @loop.control (expression) @loop.lhs (expression) @loop.rhs (for_cond)? @loop.condition @loop.inner )) @loop.outer
(for_expr (for_object_expr (for_intro) @loop.inner ))
(for_expr (for_object_expr (expression) @loop.inner ))
(for_expr (for_tuple_expr (for_intro) @loop.control (expression) @loop.lhs @loop.rhs  (for_cond)? @loop.condition @loop.inner )) @loop.outer
(for_expr (for_tuple_expr (for_intro) @loop.inner ))
(for_expr (for_tuple_expr (expression) @loop.inner ))

(numeric_lit) @number.inner

((function_arguments
  "," @_start . (expression) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((function_arguments
  . (expression) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

