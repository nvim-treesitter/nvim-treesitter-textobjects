; block
; call
(call) @call.outer

(arguments) @call.inner

; class
; comment
(comment) @comment.outer

; conditional
(if
  condition: (_)? @conditional.inner) @conditional.outer

; function
[
  (function_definition)
  (lambda_function)
] @function.outer

(function_definition
  [
    (call)
    (binary)
    (brace_list)
  ] @function.inner) @function.outer

(lambda_function
  [
    (call)
    (binary)
    (brace_list)
  ] @function.inner) @function.outer

; loop
[
  (while)
  (repeat)
  (for)
] @loop.outer

(while
  body: (_) @loop.inner)

(repeat
  body: (_) @loop.inner)

(for
  body: (_) @loop.inner)

; statement
(brace_list
  (_) @statement.outer)

(program
  (_) @statement.outer)

; parameter
(formal_parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(formal_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; number
(float) @number.inner

; assignment
(left_assignment
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(left_assignment
  name: (_) @assignment.inner)

(right_assignment
  value: (_) @assignment.inner @assignment.lhs
  name: (_) @assignment.rhs) @assignment.outer

(right_assignment
  name: (_) @assignment.inner)

(equals_assignment
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(equals_assignment
  name: (_) @assignment.inner)

(super_assignment
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(super_assignment
  name: (_) @assignment.inner)

(super_right_assignment
  value: (_) @assignment.inner @assignment.lhs
  name: (_) @assignment.rhs) @assignment.outer

(super_right_assignment
  name: (_) @assignment.inner)
