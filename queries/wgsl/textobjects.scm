(function_declaration) @function.outer

(function_declaration
  body: (compound_statement
    .
    "{"
    _+ @function.inner
    "}"))

(parameter_list
  "," @parameter.outer
  .
  (parameter) @parameter.inner @parameter.outer)

(parameter_list
  .
  (parameter) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(compound_statement) @block.outer

; loops
(loop_statement
  (_)? @loop.inner) @loop.outer

(for_statement
  (_)? @loop.inner) @loop.outer

(while_statement
  (_)? @loop.inner) @loop.outer

(struct_declaration
  "{"
  _+ @class.inner
  "}") @class.outer

; conditional
(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner) @conditional.outer

(if_statement
  condition: (_) @conditional.inner)

(argument_list_expression
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list_expression
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)
