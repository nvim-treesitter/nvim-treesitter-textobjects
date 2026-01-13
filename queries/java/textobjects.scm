(class_declaration
  body: (class_body) @class.inner) @class.outer

(method_declaration) @function.outer

(method_declaration
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

(constructor_declaration) @function.outer

(constructor_declaration
  body: (constructor_body
    .
    "{"
    _+ @function.inner
    "}"))

(return_statement
  (_)? @return.inner) @return.outer

(for_statement
  body: (_)? @loop.inner) @loop.outer

(enhanced_for_statement
  body: (_)? @loop.inner) @loop.outer

(while_statement
  body: (_)? @loop.inner) @loop.outer

(do_statement
  body: (_)? @loop.inner) @loop.outer

(if_statement
  condition: (_
    (parenthesized_expression) @conditional.inner) @conditional.outer)

(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner) @conditional.outer

(switch_expression
  body: (_)? @conditional.inner) @conditional.outer

; blocks
(block) @block.outer

(method_invocation) @call.outer

(method_invocation
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")"))

; parameters
(formal_parameters
  "," @parameter.outer
  .
  (formal_parameter) @parameter.inner @parameter.outer)

(formal_parameters
  .
  (formal_parameter) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

[
  (line_comment)
  (block_comment)
] @comment.outer

[
  (decimal_integer_literal)
  (decimal_floating_point_literal)
  (hex_integer_literal)
  (binary_integer_literal)
  (octal_integer_literal)
] @number.inner

; scopename
; statement
(statement) @statement.outer

(return_statement) @statement.outer
