(function_declaration) @function.outer

(function_declaration
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

((parameter_list
  "," @_start
  .
  (parameter) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((parameter_list
  .
  (parameter) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

(compound_statement) @block.outer

; loops
(loop_statement
  (_)? @loop.inner) @loop.outer

(for_statement
  (_)? @loop.inner) @loop.outer

(while_statement
  (_)? @loop.inner) @loop.outer

((struct_declaration
  "{"
  .
  _ @_start
  _ @_end
  .
  "}") @class.outer
  (#make-range! "class.inner" @_start @_end))

; conditional
(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner) @conditional.outer

(if_statement
  condition: (_) @conditional.inner)

((argument_list_expression
  "," @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((argument_list_expression
  .
  (_) @parameter.inner
  .
  ","? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))
