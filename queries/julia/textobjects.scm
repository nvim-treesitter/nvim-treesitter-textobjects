; Blocks
(compound_statement
  .
  (_)? @block.inner
  (_) @block.inner .) @block.outer

(quote_statement
  .
  (_)? @block.inner
  (_) @block.inner .) @block.outer

(let_statement
  .
  (_)? @block.inner
  (_) @block.inner .) @block.outer

; Conditionals
(if_statement
  condition: (_)
  .
  (_)? @conditional.inner
  .
  (_) @conditional.inner
  .
  [
    "end"
    (elseif_clause)
    (else_clause)
  ]) @conditional.outer

(elseif_clause
  condition: (_)
  .
  (_)? @conditional.inner
  (_) @conditional.inner .)

(else_clause
  .
  (_)? @conditional.inner
  (_) @conditional.inner .)

; Loops
(for_statement
  .
  (_)? @loop.inner
  (_) @loop.inner
  .
  "end") @loop.outer

(while_statement
  .
  (_)? @loop.inner
  (_) @loop.inner
  .
  "end") @loop.outer

; Type definitions
(struct_definition
  name: (_)
  .
  (_)? @class.inner
  (_) @class.inner
  .
  "end") @class.outer

(struct_definition
  name: (_)
  (type_parameter_list)*
  .
  (_)? @class.inner
  (_) @class.inner
  .
  "end") @class.outer

; Function definitions
(function_definition
  (signature)
  .
  (_)? @function.inner
  (_) @function.inner
  .
  "end") @function.outer

(assignment
  (call_expression)
  (_) @function.inner) @function.outer

(function_expression
  [
    (identifier)
    (argument_list)
  ]
  "->"
  (_) @function.inner) @function.outer

(macro_definition
  (signature)
  .
  (_)? @function.inner
  (_) @function.inner
  .
  "end") @function.outer

; Calls
(call_expression) @call.outer

(call_expression
  (argument_list
    .
    "("
    .
    (_) @call.inner
    (_)? @call.inner
    .
    ")"))

; Parameters
(vector_expression
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list
  (_) @parameter.inner @parameter.outer
  .
  "," @parameter.outer)

; Comments
[
  (line_comment)
  (block_comment)
] @comment.outer

; Regex
((prefixed_string_literal
  prefix: (identifier) @_prefix) @regex.inner @regex.outer
  (#eq? @_prefix "r")
  (#offset! @regex.inner 0 2 0 -1))
