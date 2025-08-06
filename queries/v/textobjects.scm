; assignment
[
  (var_declaration
    var_list: (_) @assignment.lhs
    expression_list: (_)* @assignment.rhs)
  (assignment_statement
    left: (_) @assignment.lhs
    right: (_)* @assignment.rhs)
]

[
  (var_declaration
    var_list: (_) @assignment.inner)
  (assignment_statement
    left: (_) @assignment.inner)
]

[
  (var_declaration
    expression_list: (_) @assignment.inner)
  (assignment_statement
    right: (_) @assignment.inner)
]

; block
(_
  (block
    .
    "{"
    _+ @block.inner
    "}")) @block.outer

; call
(call_expression) @call.outer

(call_expression
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")"))

; class: structs
(struct_declaration
  ("{"
    _+ @class.inner
    "}"))

(struct_declaration) @class.outer

; comment
; leave space after comment marker if there is one
((line_comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 3 0 0)
  (#lua-match? @comment.outer "// .*"))

; else remove everything accept comment marker
((line_comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 2 0 0))

(block_comment) @comment.inner @comment.outer

; conditional
(if_expression
  block: (block
    .
    "{"
    _+ @conditional.inner
    "}")?) @conditional.outer

; function
(function_declaration
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

(function_declaration) @function.outer

; loop
(for_statement
  body: (block
    .
    "{"
    _+ @loop.inner
    "}")?) @loop.outer

[
  (int_literal)
  (float_literal)
] @number.inner

; parameter
(parameter_list
  "," @parameter.outer
  .
  (parameter_declaration) @parameter.inner @parameter.outer)

(parameter_list
  .
  (parameter_declaration) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; return
(return_statement
  (_)* @return.inner) @return.outer

; statements
(block
  (_) @statement.outer)
