; assignments
(variable
  (_) @assignment.lhs @assignment.inner
  value: (_) @assignment.rhs) @assignment.outer

(variable
  value: (_) @assignment.inner)

; blocks
(section
  (section_header)
  (_)+ @block.inner) @block.outer

; comments
(comment) @comment.outer

; statements
(section
  (section_header)
  (_) @statement.outer)
