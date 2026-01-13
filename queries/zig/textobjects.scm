; "Classes"
(variable_declaration
  (struct_declaration)) @class.outer

(variable_declaration
  (struct_declaration
    "struct"
    "{"
    _+ @class.inner
    "}"))

; functions
(function_declaration) @function.outer

(function_declaration
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

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
  _+ @block.inner
  "}")

; statements
(statement) @statement.outer

; parameters
(parameters
  "," @parameter.outer
  .
  (parameter) @parameter.inner @parameter.outer)

(parameters
  .
  (parameter) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; arguments
(call_expression
  function: (_)
  arguments: (arguments
    "("
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer
    ")"))

(call_expression
  function: (_)
  arguments: (arguments
    "("
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer
    ")"))

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
  _+ @conditional.inner
  "}")

(while_statement
  condition: (_) @conditional.inner)

; calls
(call_expression) @call.outer

(call_expression
  arguments: (arguments
    "("
    _+ @call.inner
    ")"))
