;; named function
(binding
  (function_expression
  ) 
) @function.outer

;; anonymous function
(function_expression
  (_) ;; argument
  (_) @function.inner
) @function.outer

(function_expression
  (formals
    (formal) @parameter.inner
  ) 
)
(function_expression
  (_) @parameter.outer
  (_)
)

(comment) @comment.outer

(if_expression
  (_) @conditional.inner
) @conditional.outer

[
  (integer_expression)
  (float_expression)
] @number.inner
