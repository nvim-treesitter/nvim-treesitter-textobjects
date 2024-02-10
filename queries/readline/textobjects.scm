(variable_setting) @statement.outer

(comment) @comment.outer

((comment) @comment.inner
  (#offset! @comment.inner 0 1 0 0))

[
  (alternative)
  (consequence)
  (test)
] @conditional.inner

(conditional_construct) @conditional.outer

[
  (number_value)
  (version_number)
] @number.inner
