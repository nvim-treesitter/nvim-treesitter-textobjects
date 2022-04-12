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
  "," @_start .
  (_) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((formal_parameters
  . (_) @parameter.inner
  . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))

((arguments
  "," @_start .
  (_) @parameter.inner
  )
  (#make-range! "parameter.outer" @_start @parameter.inner))

((arguments
  . (_) @parameter.inner
  . ","? @_end
  )
  (#make-range! "parameter.outer" @parameter.inner @_end))
