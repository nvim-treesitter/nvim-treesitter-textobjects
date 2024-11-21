; Blocks
(compound_statement) @block.outer

((compound_statement
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "block.inner" @_start @_end))

(quote_statement) @block.outer

((quote_statement
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "block.inner" @_start @_end))

(let_statement) @block.outer

((let_statement
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "block.inner" @_start @_end))

; Conditionals
(if_statement
  condition: (_) @conditional.inner) @conditional.outer

(if_statement
  alternative: (elseif_clause
    condition: (_) @conditional.inner))

((if_statement
  condition: (_)
  .
  (_) @_start
  (_)? @_end
  .
  [
    "end"
    (elseif_clause)
    (else_clause)
  ])
  (#make-range! "conditional.inner" @_start @_end)) @conditional.outer

((elseif_clause
  condition: (_)
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "conditional.inner" @_start @_end))

((else_clause
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "conditional.inner" @_start @_end))

; Loops
(for_statement) @loop.outer

((for_statement
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "loop.inner" @_start @_end))

(while_statement
  condition: (_) @loop.inner) @loop.outer

((while_statement
  condition: (_)
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "loop.inner" @_start @_end))

; Type definitions
(struct_definition) @class.outer

((struct_definition
  (type_head)
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "class.inner" @_start @_end))

; Function definitions
(function_definition) @function.outer

((function_definition
  (signature)
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "function.inner" @_start @_end))

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

((macro_definition
  (signature)
  .
  (_) @_start
  (_)? @_end .)
  (#make-range! "function.inner" @_start @_end))

; Calls
(call_expression) @call.outer

(call_expression
  (argument_list
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

(macrocall_expression) @call.outer

(macrocall_expression
  (argument_list
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

(broadcast_call_expression) @call.outer

(broadcast_call_expression
  (argument_list
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

; Parameters
((argument_list
  [
    ","
    ";"
  ] @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((argument_list
  (_) @parameter.inner
  .
  [
    ","
    ";"
  ] @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((tuple_expression
  [
    ","
    ";"
  ] @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((tuple_expression
  "("
  .
  (_) @parameter.inner
  .
  [
    ","
    ";"
  ]? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

((vector_expression
  [
    ","
    ";"
  ] @_start
  .
  (_) @parameter.inner)
  (#make-range! "parameter.outer" @_start @parameter.inner))

((vector_expression
  .
  (_) @parameter.inner
  .
  [
    ","
    ";"
  ]? @_end)
  (#make-range! "parameter.outer" @parameter.inner @_end))

; Assignment
(local_statement
  (assignment
    .
    (_) @assignment.lhs
    (_) @assignment.inner @assignment.rhs .)) @assignment.outer

(const_statement
  (assignment
    .
    (_) @assignment.lhs
    (_) @assignment.inner @assignment.rhs .)) @assignment.outer

(global_statement
  (assignment
    .
    (_) @assignment.lhs
    (_) @assignment.inner @assignment.rhs .)) @assignment.outer

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
