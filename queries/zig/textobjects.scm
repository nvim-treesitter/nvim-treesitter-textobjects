; "Classes"
(variable_declaration
  (struct_declaration)) @class.outer

(variable_declaration
  (struct_declaration
    "struct"
    "{"
    .
    _ @_start @_end
    _? @_end
    .
    "}")
  (#make-range! "class.inner" @_start @_end))

; functions
(function_declaration) @function.outer

(function_declaration
  body: (block
    .
    "{"
    .
    _ @_start @_end
    _? @_end
    .
    "}")
  (#make-range! "function.inner" @_start @_end))

; loops
(for_statement) @loop.outer

(for_statement
  body: (_) @loop.inner)

(while_statement) @loop.outer

(while_statement
  body: (_) @loop.inner)

; blocks
(block) @block.outer

(block
  "{"
  .
  _ @_start @_end
  _? @_end
  .
  "}"
  (#make-range! "block.inner" @_start @_end))

; statements
(statement) @statement.outer

; parameters
(parameters
  "," @_start
  .
  (parameter) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(parameters
  .
  (parameter) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

; arguments
(call_expression
  function: (_)
  "("
  "," @_start
  .
  (_) @parameter.inner
  ")"
  (#make-range! "parameter.outer" @_start @parameter.inner))

(call_expression
  function: (_)
  "("
  .
  (_) @parameter.inner
  .
  ","? @_end
  ")"
  (#make-range! "parameter.outer" @parameter.inner @_end))

; comments
(comment) @comment.outer

; conditionals
(if_statement) @conditional.outer

(if_statement
  condition: (_) @conditional.inner)

(if_statement
  body: (_) @conditional.inner)

(switch_expression) @conditional.outer

(switch_expression
  "("
  (_) @conditional.inner
  ")")

(switch_expression
  "{"
  .
  _ @_start
  _? @_end
  .
  "}"
  (#make-range! "conditional.inner" @_start @_end))

(while_statement
  condition: (_) @conditional.inner)

; calls
(call_expression) @call.outer

(call_expression
  "("
  .
  _ @_start
  _? @_end
  .
  ")"
  (#make-range! "call.inner" @_start @_end))
