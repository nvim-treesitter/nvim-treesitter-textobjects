; functions
(function_definition
  body: (compound_statement
    .
    "{"
    _+ @function.inner
    "}"))

(function_definition) @function.outer

(anonymous_function
  body: (compound_statement
    .
    "{"
    _+ @function.inner
    "}"))

(anonymous_function) @function.outer

; methods
(method_declaration
  body: (compound_statement
    .
    "{"
    _+ @function.inner
    "}"))

(method_declaration) @function.outer

; traits
(trait_declaration
  body: (declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(trait_declaration) @class.outer

; interfaces
(interface_declaration
  body: (declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(interface_declaration) @class.outer

; enums
(enum_declaration
  body: (enum_declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(enum_declaration) @class.outer

; classes
(class_declaration
  body: (declaration_list
    .
    "{"
    _+ @class.inner
    "}"))

(class_declaration) @class.outer

; loops
(for_statement
  (compound_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(for_statement) @loop.outer

(foreach_statement
  body: (compound_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(foreach_statement) @loop.outer

(while_statement
  body: (compound_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(while_statement) @loop.outer

(do_statement
  body: (compound_statement
    .
    "{"
    _+ @loop.inner
    "}"))

(do_statement) @loop.outer

; conditionals
(switch_statement
  body: (switch_block
    .
    "{"
    _+ @conditional.inner
    "}"))

(switch_statement) @conditional.outer

(if_statement
  body: (compound_statement
    .
    "{"
    _+ @conditional.inner
    "}"))

(if_statement) @conditional.outer

(else_clause
  body: (compound_statement
    .
    "{"
    _+ @conditional.inner
    "}"))

(else_if_clause
  body: (compound_statement
    .
    "{"
    _+ @conditional.inner
    "}"))

; blocks
(_
  (switch_block) @block.inner) @block.outer

; parameters
(arguments
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(arguments
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(formal_parameters
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(formal_parameters
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; comments
(comment) @comment.outer

; call
(function_call_expression) @call.outer

(member_call_expression) @call.outer

(nullsafe_member_call_expression) @call.outer

(scoped_call_expression) @call.outer

(function_call_expression
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")"))

(member_call_expression
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")"))

(nullsafe_member_call_expression
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")"))

(scoped_call_expression
  arguments: (arguments
    .
    "("
    _+ @call.inner
    ")"))

; statement
[
  (expression_statement)
  (declare_statement)
  (return_statement)
  (namespace_use_declaration)
  (namespace_definition)
  (if_statement)
  (empty_statement)
  (switch_statement)
  (while_statement)
  (do_statement)
  (for_statement)
  (foreach_statement)
  (goto_statement)
  (continue_statement)
  (break_statement)
  (try_statement)
  (echo_statement)
  (unset_statement)
  (const_declaration)
  (function_definition)
  (class_declaration)
  (interface_declaration)
  (trait_declaration)
  (enum_declaration)
  (global_declaration)
  (function_static_declaration)
] @statement.outer
