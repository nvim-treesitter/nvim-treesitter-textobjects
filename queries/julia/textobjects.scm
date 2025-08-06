; Blocks
(compound_statement) @block.outer

(compound_statement
  .
  (_) @block.inner
  (_)? @block.inner .)

(quote_statement) @block.outer

(quote_statement
  .
  (_) @block.inner
  (_)? @block.inner .)

(let_statement) @block.outer

(let_statement
  .
  (_) @block.inner
  (_)? @block.inner .)

; Conditionals
(if_statement
  condition: (_) @conditional.inner) @conditional.outer

(if_statement
  alternative: (elseif_clause
    condition: (_) @conditional.inner))

((if_statement
  condition: (_)
  .
  (_) @conditional.inner
  (_)? @conditional.inner
  .
  [
    "end"
    (elseif_clause)
    (else_clause)
  ]) @conditional.outer
  (elseif_clause
    condition: (_)
    .
    (_) @conditional.inner
    (_)? @conditional.inner .))

(else_clause
  .
  (_) @conditional.inner
  (_)? @conditional.inner .)

; Loops
(for_statement) @loop.outer

(for_statement
  .
  (_) @loop.inner
  (_)? @loop.inner .)

(while_statement
  condition: (_) @loop.inner) @loop.outer

(while_statement
  condition: (_)
  .
  (_) @loop.inner
  (_)? @loop.inner .)

; Type definitions
(struct_definition) @class.outer

(struct_definition
  (type_head)
  .
  (_) @class.inner
  (_)? @class.inner .)

; Function definitions
(function_definition) @function.outer

(function_definition
  (signature)
  .
  (_) @function.inner
  (_)? @function.inner .)

(assignment
  (call_expression)
  (operator)
  (_) @function.inner) @function.outer

(arrow_function_expression
  [
    (identifier)
    (argument_list)
  ]
  "->"
  (_) @function.inner) @function.outer

(macro_definition) @function.outer

(macro_definition
  (signature)
  .
  (_) @function.inner
  (_)? @function.inner .)

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

(macrocall_expression) @call.outer

(macrocall_expression
  (argument_list
    .
    "("
    .
    (_) @call.inner
    (_)? @call.inner
    .
    ")"))

(broadcast_call_expression) @call.outer

(broadcast_call_expression
  (argument_list
    .
    "("
    .
    (_) @call.inner
    (_)? @call.inner
    .
    ")"))

; Parameters
((argument_list
  [
    ","
    ";"
  ] @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)
  (argument_list
    (_) @parameter.inner @parameter.outer
    .
    [
      ","
      ";"
    ] @parameter.outer))

(tuple_expression
  [
    ","
    ";"
  ] @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple_expression
  "("
  .
  (_) @parameter.inner @parameter.outer
  .
  [
    ","
    ";"
  ]? @parameter.outer)

(vector_expression
  [
    ","
    ";"
  ] @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(vector_expression
  .
  (_) @parameter.inner @parameter.outer
  .
  [
    ","
    ";"
  ]? @parameter.outer)

; Assignment
(assignment
  .
  (_) @assignment.lhs
  (_) @assignment.inner @assignment.rhs .) @assignment.outer

(assignment
  .
  (_) @assignment.inner)

(compound_assignment_expression
  .
  (_) @assignment.lhs
  (_) @assignment.inner @assignment.rhs .) @assignment.outer

(compound_assignment_expression
  .
  (_) @assignment.inner)

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
