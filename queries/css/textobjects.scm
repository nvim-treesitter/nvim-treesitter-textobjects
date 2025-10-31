[
  (integer_value)
  (float_value)
  (color_value)
] @number.inner

(declaration
  (property_name) @assignment.lhs
  .
  ":"
  _+ @assignment.inner @assignment.rhs
  ";") @assignment.outer

(declaration
  (property_name) @assignment.inner)

(comment) @comment.outer
