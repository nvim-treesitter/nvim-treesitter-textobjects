; functions
(function_signature_item) @function.outer

(function_item) @function.outer

(function_item
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

; quantifies as class(es)
(struct_item) @class.outer

(struct_item
  body: (field_declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(enum_item) @class.outer

(enum_item
  body: (enum_variant_list
    .
    "{"
    _+ @class.inner
    "}"))

(union_item) @class.outer

(union_item
  body: (field_declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(trait_item) @class.outer

(trait_item
  body: (declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(impl_item) @class.outer

(impl_item
  body: (declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(mod_item) @class.outer

(mod_item
  body: (declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

; conditionals
(if_expression
  alternative: (_
    (_) @conditional.inner)?) @conditional.outer

(if_expression
  alternative: (else_clause
    (block) @conditional.inner))

(if_expression
  condition: (_) @conditional.inner)

(if_expression
  consequence: (block) @conditional.inner)

(match_arm
  (_)) @conditional.inner

(match_expression) @conditional.outer

; loops
(loop_expression
  body: (block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(while_expression
  body: (block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

(for_expression
  body: (block
    .
    "{"
    _+ @loop.inner
    "}")) @loop.outer

; blocks
(block
  (_)* @block.inner) @block.outer

(unsafe_block
  (_)* @block.inner) @block.outer

; calls
(macro_invocation) @call.outer

(macro_invocation
  (token_tree
    .
    "("
    _+ @call.inner
    ")"))

(call_expression) @call.outer

(call_expression
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")"))

; returns
(return_expression
  (_)? @return.inner) @return.outer

; statements
(block
  (_) @statement.outer)

; comments
(line_comment) @comment.outer

(block_comment) @comment.outer

; parameter
(parameters
  "," @parameter.outer
  .
  [
    (self_parameter)
    (parameter)
    (type_identifier)
  ] @parameter.inner @parameter.outer)

(parameters
  .
  [
    (self_parameter)
    (parameter)
    (type_identifier)
  ] @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(parameters
  [
    (self_parameter)
    (parameter)
    (type_identifier)
  ] @parameter.outer
  .
  "," @parameter.outer .)

(type_parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(type_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(type_parameters
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(tuple_pattern
  "," @parameter.outer
  .
  (identifier) @parameter.inner @parameter.outer)

(tuple_pattern
  .
  (identifier) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(tuple_pattern
  (identifier) @parameter.outer
  .
  "," @parameter.outer .)

(tuple_struct_pattern
  "," @parameter.outer
  .
  (identifier) @parameter.inner @parameter.outer)

(tuple_struct_pattern
  .
  (identifier) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(tuple_struct_pattern
  (identifier) @parameter.outer
  .
  "," @parameter.outer .)

(tuple_expression
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple_expression
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(tuple_expression
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(tuple_type
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple_type
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(tuple_type
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(struct_item
  body: (field_declaration_list
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer))

(struct_item
  body: (field_declaration_list
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer))

; last element, with trailing comma
(struct_item
  body: (field_declaration_list
    (_) @parameter.outer
    .
    "," @parameter.outer .))

(struct_expression
  body: (field_initializer_list
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer))

(struct_expression
  body: (field_initializer_list
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer))

; last element, with trailing comma
(struct_expression
  body: (field_initializer_list
    (_) @parameter.outer
    .
    "," @parameter.outer .))

(closure_parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(closure_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(closure_parameters
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(arguments
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(type_arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(type_arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(type_arguments
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(token_tree
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(token_tree
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; last element, with trailing comma
(token_tree
  (_) @parameter.outer
  .
  "," @parameter.outer .)

(scoped_use_list
  list: (use_list
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer))

(scoped_use_list
  list: (use_list
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer))

; last element, with trailing comma
(scoped_use_list
  list: (use_list
    (_) @parameter.outer
    .
    "," @parameter.outer .))

[
  (integer_literal)
  (float_literal)
] @number.inner

(let_declaration
  pattern: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(let_declaration
  pattern: (_) @assignment.inner)

(assignment_expression
  left: (_) @assignment.lhs
  right: (_) @assignment.inner @assignment.rhs) @assignment.outer

(assignment_expression
  left: (_) @assignment.inner)
