; inner function textobject
(function_declaration
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

; inner function literals
(func_literal
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

; method as inner function textobject
(method_declaration
  body: (block
    .
    "{"
    _+ @function.inner
    "}"))

; outer function textobject
(function_declaration) @function.outer

; outer function literals
(func_literal
  (_)?) @function.outer

; method as outer function textobject
(method_declaration
  body: (block)?) @function.outer

; struct and interface declaration as class textobject?
(type_declaration
  (type_spec
    (type_identifier)
    (struct_type
      (field_declaration_list
        (_)?) @class.inner))) @class.outer

(type_declaration
  (type_spec
    (type_identifier)
    (interface_type) @class.inner)) @class.outer

; struct literals as class textobject
(composite_literal
  (type_identifier)?
  (struct_type
    (_))?
  (literal_value
    (_)) @class.inner) @class.outer

; conditionals
(if_statement
  alternative: (_
    (_) @conditional.inner)?) @conditional.outer

(if_statement
  consequence: (block)? @conditional.inner)

(if_statement
  condition: (_) @conditional.inner)

; loops
(for_statement
  body: (block)? @loop.inner) @loop.outer

; blocks
(_
  (block) @block.inner) @block.outer

; statements
(block
  (_) @statement.outer)

; comments
(comment) @comment.outer

; calls
(call_expression) @call.outer

(call_expression
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")"))

; parameters
(parameter_list
  "," @parameter.outer
  .
  (parameter_declaration) @parameter.inner @parameter.outer)

(parameter_list
  .
  (parameter_declaration) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(parameter_declaration
  name: (identifier)
  type: (_)) @parameter.inner

(parameter_declaration
  name: (identifier)
  type: (_)) @parameter.inner

(parameter_list
  "," @parameter.outer
  .
  (variadic_parameter_declaration) @parameter.inner @parameter.outer)

; arguments
(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; assignments
(short_var_declaration
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

(assignment_statement
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

(var_spec
  name: (_) @assignment.lhs
  value: (_) @assignment.rhs @assignment.inner) @assignment.outer

(var_spec
  name: (_) @assignment.inner
  type: (_)) @assignment.outer

(const_spec
  name: (_) @assignment.lhs
  value: (_) @assignment.rhs @assignment.inner) @assignment.outer

(const_spec
  name: (_) @assignment.inner
  type: (_)) @assignment.outer
