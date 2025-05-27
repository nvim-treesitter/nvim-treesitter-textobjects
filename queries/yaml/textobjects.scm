; assignment, statement
(block_mapping_pair
  key: (_) @assignment.lhs
  value: (_) @assignment.rhs) @assignment.outer @statement.outer

(block_mapping_pair
  key: (_) @assignment.inner)

(block_mapping_pair
  value: (_) @assignment.inner)

; comment
; leave space after comment marker if there is one
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 2 0 0)
  (#lua-match? @comment.outer "# .*"))

; else remove everything accept comment marker
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 1 0 0))

; number
[
  (integer_scalar)
  (float_scalar)
] @number.inner
