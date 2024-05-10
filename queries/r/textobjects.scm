; block
; call
(call) @call.outer

(arguments) @call.inner

; class
; comment
(comment) @comment.outer

; conditional
(if_statement
  condition: (_)? @conditional.inner) @conditional.outer

; function
(function_definition
  [
    (call)
    (binary_operator)
    (braced_expression)
  ] @function.inner) @function.outer

; loop
[
  (while_statement)
  (repeat_statement)
  (for_statement)
] @loop.outer

(while_statement
  body: (_) @loop.inner)

(repeat_statement
  body: (_) @loop.inner)

(for_statement
  body: (_) @loop.inner)

; statement
(braced_expression
  (_) @statement.outer)

(program
  (_) @statement.outer)

; parameter
(parameters
  (comma) @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  (comma)? @parameter.outer)

(arguments
  (comma)? @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  (comma)? @parameter.outer)

; number
(float) @number.inner

; assignment
(binary_operator
  lhs: (_) @assignment.inner @assignment.lhs
  rhs: (_) @assignment.rhs) @assignment.outer
