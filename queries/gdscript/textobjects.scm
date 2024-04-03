(function_definition
  body: (_) @function.inner) @function.outer

(constructor_definition
  body: (_) @function.inner) @function.outer

(class_definition
  body: (_) @class.inner) @class.outer

(if_statement
  body: (_) @conditional.inner) @conditional.outer

(if_statement
  alternative: (_
    (_) @conditional.inner)?) @conditional.outer

(if_statement
  condition: (_) @conditional.inner)

[
  (for_statement)
  (while_statement)
] @loop.outer

(while_statement
  body: (_) @loop.inner)

(for_statement
  body: (_) @loop.inner)

(comment) @comment.outer

(parameters
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(parameters
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(arguments
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(arguments
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(array
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(array
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))
