[
  (integer_value)
  (float_value)
  (color_value)
] @number.inner

(declaration
  (property_name) @assignment.lhs
  .
  ":"
  .
  (_) @_start
  (_)? @_end
  .
  ";"
  (#make-range! "assignment.inner" @_start @_end)
  (#make-range! "assignment.rhs" @_start @_end)) @assignment.outer

(declaration
  (property_name) @assignment.inner)

(comment) @comment.outer
