; https://fennel-lang.org/reference
(comment) @comment.outer

(_
  .
  "("
  ")" .) @statement.outer

; functions & parameters
(list
  .
  (symbol) @_fn
  (symbol)? @_fn_name
  (sequence
    (_) @parameter.inner)
  (_)* @function.inner
  (#any-of? @_fn "fn" "lambda" "λ")) @function.outer

; call
(list
  .
  (symbol) @_fn_name
  (_)* @call.inner
  (#not-any-of? @_fn_name "if" "do" "while" "for" "each" "let" "when" "fn")) @call.outer

; conditionals
(list
  (symbol) @_cond
  (_)
  (_)* @conditional.inner
  (#any-of? @_cond "if" "when")) @conditional.outer

; loops
(list
  .
  (symbol) @_sym
  .
  (_)
  .
  (_)* @loop.inner
  (#any-of? @_sym "each" "while" "for")) @loop.outer
