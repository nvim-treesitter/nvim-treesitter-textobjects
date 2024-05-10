; ==============================================================================
; @attribute.inner
; @attribute.outer
; ==============================================================================
; @function.inner
; @function.outer
(proc_declaration
  body: (statement_list) @function.inner) @function.outer

(func_declaration
  body: (statement_list) @function.inner) @function.outer

(method_declaration
  body: (statement_list) @function.inner) @function.outer

(iterator_declaration
  body: (statement_list) @function.inner) @function.outer

(converter_declaration
  body: (statement_list) @function.inner) @function.outer

(template_declaration
  body: (statement_list) @function.inner) @function.outer

(macro_declaration
  body: (statement_list) @function.inner) @function.outer

(proc_expression
  body: (statement_list) @function.inner) @function.outer

(func_expression
  body: (statement_list) @function.inner) @function.outer

(iterator_expression
  body: (statement_list) @function.inner) @function.outer

; ==============================================================================
; @class.inner
; @class.outer
; NOTE: seems pointless to handle just object declarations differently
; ==============================================================================
; @conditional.inner
; @conditional.outer
[
  (if)
  (when)
  (conditional_declaration)
  (case)
  (variant_declaration)
  (elif_branch)
  (else_branch)
  (of_branch)
] @conditional.outer

(if
  condition: (_) @conditional.inner)

(if
  consequence: (statement_list) @conditional.inner)

(when
  condition: (_) @conditional.inner)

(when
  consequence: (statement_list) @conditional.inner)

(conditional_declaration
  condition: (_) @conditional.inner)

(conditional_declaration
  consequence: (field_declaration_list) @conditional.inner)

(elif_branch
  condition: (_) @conditional.inner)

(elif_branch
  consequence: [
    (statement_list)
    (field_declaration_list)
  ] @conditional.inner)

(else_branch
  consequence: [
    (statement_list)
    (field_declaration_list)
  ] @conditional.inner)

(case
  value: (_) @conditional.inner)

(variant_declaration
  (variant_discriminator_declaration) @conditional.inner)

(of_branch
  values: (expression_list) @conditional.inner)

(of_branch
  consequence: [
    (statement_list)
    (field_declaration_list)
  ] @conditional.inner)

; ==============================================================================
; @loop.inner
; @loop.outer
[
  (for)
  (while)
] @loop.outer

(for
  left: (_) @loop.inner
  right: (_) @loop.inner)

(for
  body: (statement_list) @loop.inner)

(while
  condition: (_) @loop.inner)

(while
  body: (statement_list) @loop.inner)

; ==============================================================================
; @call.inner
; @call.outer
(call
  (argument_list) @call.inner) @call.outer

; NOTE: parenthesis are included in @call.inner
; ==============================================================================
; @block.inner
; @block.outer
(case
  ":"
  _+ @block.inner) @block.outer

(object_declaration
  (field_declaration_list) @block.inner) @block.outer

(tuple_type
  (field_declaration_list
    .
    "["
    _+ @block.inner
    "]" .)) @block.outer

(enum_declaration
  .
  "enum"
  _+ @block.inner) @block.outer

(using_section
  .
  "using"
  _+ @block.inner) @block.outer

(const_section
  .
  "const"
  _+ @block.inner) @block.outer

(let_section
  .
  "let"
  _+ @block.inner) @block.outer

(var_section
  .
  "var"
  _+ @block.inner) @block.outer

(type_section
  .
  "type"
  _+ @block.inner)

(_
  (statement_list) @block.inner) @block.outer

; ==============================================================================
; @parameter.inner
; @parameter.outer
; parameters when declaring
(parameter_declaration_list
  [
    ","
    ";"
  ] @parameter.outer
  .
  (parameter_declaration) @parameter.inner @parameter.outer)

(parameter_declaration_list
  .
  (parameter_declaration) @parameter.inner @parameter.outer
  .
  [
    ","
    ";"
  ]? @parameter.outer)

; generic parameters when declaring
(generic_parameter_list
  "," @parameter.outer
  .
  (parameter_declaration) @parameter.inner @parameter.outer)

(generic_parameter_list
  .
  (parameter_declaration) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; arguments when calling
(argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; containers
(array_construction
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(array_construction
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(tuple_construction
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple_construction
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(curly_construction
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(curly_construction
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; generic arguments when calling
; subscript operator
; generic types
(bracket_expression
  right: (argument_list
    "," @parameter.outer
    .
    (_) @parameter.inner @parameter.outer))

(bracket_expression
  right: (argument_list
    .
    (_) @parameter.inner @parameter.outer
    .
    ","? @parameter.outer))

; import x,x
; import except x,x
; include x,x
; from import x,x
; bind x,x
; mixin x,x
; case of x,x
; try except x,x
(expression_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(expression_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; pragmas
(pragma_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(pragma_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; variable_declaration
; for
; identifier_declaration `x,y: type = value`
(symbol_declaration_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(symbol_declaration_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; infix_expression
(infix_expression
  operator: (_) @parameter.outer
  right: (_) @parameter.inner @parameter.outer)

(infix_expression
  left: (_) @parameter.inner @parameter.outer
  operator: (_) @parameter.outer)

; tuple_type inline
(field_declaration_list
  [
    ","
    ";"
  ] @parameter.outer
  .
  (field_declaration) @parameter.inner @parameter.outer)

(field_declaration_list
  .
  (field_declaration) @parameter.inner @parameter.outer
  .
  [
    ","
    ";"
  ]? @parameter.outer)

; enum
(enum_declaration
  "," @parameter.outer
  .
  (enum_field_declaration) @parameter.inner @parameter.outer)

(enum_declaration
  .
  (enum_field_declaration) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; tuple_deconstruct_declaration
(tuple_deconstruct_declaration
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(tuple_deconstruct_declaration
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; concept parameter list
; concept refinement list
(parameter_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(parameter_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

(refinement_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(refinement_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; dot_generic_call `v.call[:type, type]()
(generic_argument_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer)

(generic_argument_list
  .
  (_) @parameter.inner @parameter.outer
  .
  ","? @parameter.outer)

; ==============================================================================
; @regex.inner
; @regex.outer
; ==============================================================================
; @comment.inner
; @comment.outer
(comment
  (comment_content) @comment.inner) @comment.outer

(block_comment
  (comment_content) @comment.inner) @comment.outer

(documentation_comment
  (comment_content) @comment.inner) @comment.outer

(block_documentation_comment
  (comment_content) @comment.inner) @comment.outer

; ==============================================================================
; @assignment.inner
; @assignment.outer
; @assignment.lhs
; @assignment.rhs
(variable_declaration
  (symbol_declaration_list) @assignment.lhs
  type: (type_expression)? @assignment.lhs
  value: (_) @assignment.rhs @assignment.inner) @assignment.outer

(type_declaration
  (type_symbol_declaration) @assignment.lhs
  .
  "="
  .
  (_) @assignment.rhs @assignment.inner) @assignment.outer

(assignment
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

; default parameter in proc decl
; keyword argument in call
; array construction
(colon_expression
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

; object construction
; tuple construction
; table construction
(equal_expression
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs @assignment.inner) @assignment.outer

; object declaration fields
; tuple declaration fields
(field_declaration
  (symbol_declaration_list) @assignment.lhs
  type: (type_expression)? @assignment.lhs
  value: (_)? @assignment.rhs @assignment.inner) @assignment.outer

; enum types
(enum_field_declaration
  (symbol_declaration) @assignment.lhs
  "="?
  value: (_)? @assignment.rhs @assignment.inner) @assignment.outer

; ==============================================================================
; @return.inner
; @return.outer
(return_statement
  (_) @return.inner) @return.outer

; ==============================================================================
; @statement.outer
[
  ; simple
  (import_statement)
  (import_from_statement)
  (export_statement)
  (include_statement)
  (discard_statement)
  (return_statement)
  (raise_statement)
  (yield_statement)
  (break_statement)
  (continue_statement)
  (assembly_statement)
  (bind_statement)
  (mixin_statement)
  (pragma_statement)
  ; complex
  (while)
  (static_statement)
  (defer)
  ; declarations
  (proc_declaration)
  (func_declaration)
  (method_declaration)
  (iterator_declaration)
  (macro_declaration)
  (template_declaration)
  (converter_declaration)
  (using_section)
  (const_section)
  (let_section)
  (var_section)
  (type_section)
  ; expression statements
  (block)
  (if)
  (when)
  (case)
  (try)
  (for)
  (assignment)
  ; NOTE: not including
  ; simple_expression, call, infix_expression, prefix_expression
  ; because it would confusing
] @statement.outer

; ==============================================================================
; @scopename.inner
; ==============================================================================
; @number.inner
[
  (integer_literal)
  (float_literal)
] @number.inner
