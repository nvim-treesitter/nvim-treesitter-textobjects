; inner function textobject
(function_declaration
  body: (block
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

; inner function literals
(func_literal
  body: (block
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

; method as inner function textobject
(method_declaration
  body: (block
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

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
    (struct_type))) @class.outer

(type_declaration
  (type_spec
    (type_identifier)
    (struct_type
      (field_declaration_list
        "{"
        .
        _ @_start @_end
        _? @_end
        .
        "}"
        (#make-range! "class.inner" @_start @_end)))))

(type_declaration
  (type_spec
    (type_identifier)
    (interface_type))) @class.outer

(type_declaration
  (type_spec
    (type_identifier)
    (interface_type
      "{"
      .
      _ @_start @_end
      _? @_end
      .
      "}"
      (#make-range! "class.inner" @_start @_end))))

; struct literals as class textobject
(composite_literal
  (literal_value)) @class.outer

(composite_literal
  (literal_value
    "{"
    .
    _ @_start @_end
    _? @_end
    .
    "}")
  (#make-range! "class.inner" @_start @_end))

; conditionals
(if_statement
  alternative: (_
    (_) @conditional.inner)?) @conditional.outer

(if_statement
  consequence: (block
    "{"
    .
    _ @_start @_end
    _? @_end
    .
    "}"
    (#make-range! "conditional.inner" @_start @_end)))

(if_statement
  condition: (_) @conditional.inner)

; loops
(for_statement) @loop.outer

(for_statement
  body: (block
    .
    "{"
    .
    _ @_start @_end
    _? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end)))

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
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

; parameters
(parameter_list
  "," @_start
  .
  (parameter_declaration) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(parameter_list
  .
  (parameter_declaration) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(parameter_declaration
  name: (identifier)
  type: (_)) @parameter.inner

(parameter_declaration
  name: (identifier)
  type: (_)) @parameter.inner

(parameter_list
  "," @_start
  .
  (variadic_parameter_declaration) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

; arguments
(argument_list
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(argument_list
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

; assignments
(short_var_declaration
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

(assignment_statement
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

(var_declaration
  (var_spec
    name: (_) @assignment.lhs
    value: (_) @assignment.rhs @assignment.inner)) @assignment.outer

(var_declaration
  (var_spec
    name: (_) @assignment.inner
    type: (_))) @assignment.outer

(const_declaration
  (const_spec
    name: (_) @assignment.lhs
    value: (_) @assignment.rhs @assignment.inner)) @assignment.outer

(const_declaration
  (const_spec
    name: (_) @assignment.inner
    type: (_))) @assignment.outer
