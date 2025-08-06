; procedures
(procedure_declaration
  (_
    (block
      .
      "{"
      _+ @function.inner
      "}"))) @function.outer

; returns
(return_statement
  (_)? @return.inner) @return.outer

; call function in module
(member_expression
  (call_expression)) @call.outer

; call arguments
(call_expression
  function: (_)
  .
  argument: (_) @call.inner
  argument: (_) @call.inner .)

; block
(block
  .
  "{"
  _+ @block.inner
  "}") @block.outer

; classes
(struct_declaration
  "{"
  _+ @class.inner
  "}") @class.outer

(union_declaration
  "{"
  _+ @class.inner
  "}") @class.outer

(enum_declaration
  "{"
  _+ @class.inner
  "}") @class.outer

; comments
(comment) @comment.outer

(block_comment) @comment.outer

; assignment
; works also for multiple targets in lhs. ex. 'res, ok := get_res()'
(assignment_statement
  .
  (_) @assignment.lhs
  (_) @assignment.lhs
  .
  (_) @assignment.rhs @assignment.inner .) @assignment.outer

; attribute
(attribute
  (_) @attribute.inner) @attribute.outer

; number
(number) @number.inner

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

(call_expression
  function: (_)
  "," @parameter.outer
  .
  argument: (_) @parameter.inner @parameter.outer)

(call_expression
  function: (_)
  .
  argument: (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)
