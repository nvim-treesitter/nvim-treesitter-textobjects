; See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
; function.inner & outer
; ----------------------
; global
(global_function
  body: (_)) @function.outer

(global_function
  body: (function_body
    .
    "{"
    _+ @function.inner
    "}"))

; init
(init_function
  body: (_)) @function.outer

(init_function
  body: (function_body
    .
    "{"
    _+ @function.inner
    "}"))

; bounced
(bounced_function
  body: (_)) @function.outer

(bounced_function
  body: (function_body
    .
    "{"
    _+ @function.inner
    "}"))

; receive
(receive_function
  body: (_)) @function.outer

(receive_function
  body: (function_body
    .
    "{"
    _+ @function.inner
    "}"))

; external
(external_function
  body: (_)) @function.outer

(external_function
  body: (function_body
    .
    "{"
    _+ @function.inner
    "}"))

; contract/trait function
(storage_function
  body: (_)) @function.outer

(storage_function
  body: (function_body
    .
    "{"
    _+ @function.inner
    "}"))

; class.inner & outer
; -------------------
(struct) @class.outer

(struct
  body: (struct_body
    .
    "{"
    _+ @class.inner
    "}"))

(message) @class.outer

(message
  body: (message_body
    .
    "{"
    _+ @class.inner
    "}"))

(contract) @class.outer

(contract
  body: (contract_body
    .
    "{"
    _+ @class.inner
    "}"))

(trait) @class.outer

(trait
  body: (trait_body
    .
    "{"
    _+ @class.inner
    "}"))

; attribute.inner & outer
; -----------------------
("@name"
  "("
  func_name: (func_identifier) @attribute.inner
  ")") @attribute.outer

(contract_attributes
  ("@interface"
    "("
    (string) @attribute.inner
    ")") @attribute.outer)

(trait_attributes
  ("@interface"
    "("
    (string) @attribute.inner
    ")") @attribute.outer)

(trait_attributes
  ("@interface"
    "("
    (string) @attribute.inner
    ")") @attribute.outer)

; loop.inner & outer
; ------------------
(while_statement) @loop.outer

(while_statement
  body: (block_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(repeat_statement) @loop.outer

(repeat_statement
  body: (block_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(do_until_statement) @loop.outer

(do_until_statement
  body: (block_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(foreach_statement) @loop.outer

(foreach_statement
  body: (block_statement
    .
    "{"
    _+ @loop.inner
    "}"))

; conditional.inner & outer
; -------------------------
(if_statement) @conditional.outer

(if_statement
  consequence: (block_statement
    .
    "{"
    _+ @conditional.inner
    "}"))

(if_statement
  alternative: (else_clause
    (block_statement
      .
      "{"
      _+ @conditional.inner
      "}")))

; block.inner & outer
; -------------------
(_
  (block_statement) @block.inner) @block.outer

; call.inner & outer
; ------------------
(method_call_expression) @call.outer

(method_call_expression
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")"))

(static_call_expression) @call.outer

(static_call_expression
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")"))

(instance_expression) @call.outer

(instance_expression
  arguments: (instance_argument_list
    .
    "{"
    _+ @call.inner
    "}"))

(initOf
  name: (identifier) @call.outer
  arguments: (argument_list
    .
    "("
    _+ @call.inner
    ")") @call.outer)

; return.inner & outer
; --------------------
(return_statement
  (_) @return.inner) @return.outer

; number.inner
; ------------
(integer) @number.inner

; parameter.inner & outer
; -----------------------
; second and following
(parameter_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

; first
(parameter_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; second and following
(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

; first
(argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; second and following
(instance_argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

; first
(instance_argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; single parameter
(receive_function
  parameter: (_) @parameter.inner @parameter.outer)

(bounced_function
  parameter: (_) @parameter.inner @parameter.outer)

(external_function
  parameter: (_) @parameter.inner @parameter.outer)

; assignment.inner & outer w/ lhs & rhs
; -------------------------------------
(let_statement
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(storage_variable
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(global_constant
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(storage_constant
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(field
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

; comment.inner & outer
; ---------------------
(comment) @comment.inner @comment.outer

; quantified captures aren't supported yet:
; (comment)+ @comment.outer
