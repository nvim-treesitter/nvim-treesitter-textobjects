; Solidity textobjects
; Functions
(function_definition
  body: (_)) @function.outer

(function_definition
  body: (_
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

; Constructors
(constructor_definition
  body: (_)) @function.outer

(constructor_definition
  body: (_
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

; Modifiers
(modifier_definition
  body: (_)) @function.outer

(modifier_definition
  body: (_
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

; Contracts
(contract_declaration
  body: (_) @class.inner) @class.outer

; Interfaces
(interface_declaration
  body: (_) @class.inner) @class.outer

; Libraries
(library_declaration
  body: (_) @class.inner) @class.outer

; Structs
(struct_declaration
  body: (_) @class.inner) @class.outer

; Loops
(for_statement
  body: (_
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end))) @loop.outer

(while_statement
  body: (_
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end))) @loop.outer

; Conditionals
(if_statement
  (statement
    .
    "{"
    .
    (_) @_start @_end
    (_) @_end
    .
    "}"
    (#make-range! "conditional.inner" @_start @_end))) @conditional.outer

(if_statement
  (else_clause
    (statement
      .
      "{"
      .
      (_) @_start @_end
      (_) @_end
      .
      "}"
      (#make-range! "conditional.inner" @_start @_end)))) @conditional.outer

(if_statement) @conditional.outer

; Function calls
(call_expression) @call.outer

(call_expression
  arguments: (call_arguments
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

; Blocks
(_
  (_) @block.inner) @block.outer

; Parameters
(parameter_list
  ","? @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(parameter_list
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

; Arguments
(call_arguments
  ","? @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(call_arguments
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

; Comments
(comment) @comment.outer

; Variable declarations
(variable_declaration
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(variable_declaration
  name: (_) @assignment.inner)

; State variable declarations
(state_variable_declaration
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(state_variable_declaration
  name: (_) @assignment.inner)
