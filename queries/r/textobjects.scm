; block

; call

(call) @call.outer (arguments) @call.inner

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
  ] @function.inner
) @function.outer

; loop

[
  (while)
  (repeat)
  (for)
] @loop.outer

(while body: (_) @loop.inner)

(repeat body: (_) @loop.inner)

(for body: (_) @loop.inner)

; parameter

((formal_parameters
  . [
      (identifier)
      (float)
      (integer)
      (complex)
      (true)
      (false)
      (string)
      (call)
      (namespace_get)
      (namespace_get_internal)
      (default_parameter)
      (dots)
      (na)
      (nan)
      (null)
      (inf)
      (binary)
      (unary)
      (pipe)
      (subset)
      (subset2)
      (dollar)
      (slot)
    ] @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))


((arguments
  . [
      (identifier)
      (float)
      (integer)
      (complex)
      (true)
      (false)
      (string)
      (call)
      (namespace_get)
      (namespace_get_internal)
      (default_argument)
      (dots)
      (na)
      (nan)
      (null)
      (inf)
      (binary)
      (unary)
      (pipe)
      (function_definition)
      (subset)
      (subset2)
      (dollar)
      (slot)
    ] @parameter.inner
    . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))
