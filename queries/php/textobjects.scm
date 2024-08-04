; functions
(function_definition
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

(function_definition) @function.outer

(anonymous_function
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

(anonymous_function) @function.outer

; methods
(method_declaration
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "function.inner" @_start @_end)))

(method_declaration) @function.outer

; traits
(trait_declaration
  body: (declaration_list
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(trait_declaration) @class.outer

; interfaces
(interface_declaration
  body: (declaration_list
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(interface_declaration) @class.outer

; enums
(enum_declaration
  body: (enum_declaration_list
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(enum_declaration) @class.outer

; classes
(class_declaration
  body: (declaration_list
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "class.inner" @_start @_end)))

(class_declaration) @class.outer

; loops
(for_statement
  (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end)))

(for_statement) @loop.outer

(foreach_statement
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end)))

(foreach_statement) @loop.outer

(while_statement
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end)))

(while_statement) @loop.outer

(do_statement
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "loop.inner" @_start @_end)))

(do_statement) @loop.outer

; conditionals
(switch_statement
  body: (switch_block
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "conditional.inner" @_start @_end)))

(switch_statement) @conditional.outer

(if_statement
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "conditional.inner" @_start @_end)))

(if_statement) @conditional.outer

(else_clause
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "conditional.inner" @_start @_end)))

(else_if_clause
  body: (compound_statement
    .
    "{"
    .
    (_) @_start @_end
    (_)? @_end
    .
    "}"
    (#make-range! "conditional.inner" @_start @_end)))

; blocks
(_
  (switch_block) @block.inner) @block.outer

; parameters
(arguments
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(arguments
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(formal_parameters
  "," @_start
  .
  (_) @parameter.inner
  (#make-range! "parameter.outer" @_start @parameter.inner))

(formal_parameters
  .
  (_) @parameter.inner
  .
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

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
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

(member_call_expression
  arguments: (arguments
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

(nullsafe_member_call_expression
  arguments: (arguments
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

(scoped_call_expression
  arguments: (arguments
    .
    "("
    .
    (_) @_start
    (_)? @_end
    .
    ")"
    (#make-range! "call.inner" @_start @_end)))

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
