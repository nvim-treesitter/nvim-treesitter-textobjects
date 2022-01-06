;; function textobject
(function_declaration
  body: (block)? @function.inner) @function.outer

;; function literals
(func_literal
	(_)? @function.inner) @function.outer

;; method as function textobject
(method_declaration
  body: (block)? @function.inner) @function.outer

;; struct and interface declaration as class textobject?
(type_declaration
    (type_spec (type_identifier) (struct_type (field_declaration_list (_)?) @class.inner))) @class.outer

(type_declaration
  (type_spec (type_identifier) (interface_type) @class.inner)) @class.outer

;; struct literals as class textobject
(composite_literal
  (type_identifier)?
  (struct_type (_))?
  (literal_value (_)) @class.inner) @class.outer

;; conditionals
(if_statement
  alternative: (_ (_) @conditional.inner)?) @conditional.outer

(if_statement
  consequence: (block)? @conditional.inner)

(if_statement
  condition: (_) @conditional.inner)

;; loops
(for_statement
  body: (block)? @loop.inner) @loop.outer

;; blocks
(_ (block) @block.inner) @block.outer

;; statements
(block (_) @statement.outer)

;; comments
(comment) @comment.outer

;; calls
(call_expression (_)? @call.inner) @call.outer

;; parameters
(parameter_list
  "," @_start .
  (parameter_declaration) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(parameter_list
  . (parameter_declaration) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

(parameter_declaration
  (identifier)
  (identifier) @parameter.inner)

(parameter_declaration
  (identifier) @parameter.inner
  (identifier))

(parameter_list
  "," @_start .
  (variadic_parameter_declaration) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))

;; arguments
(argument_list
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(argument_list
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))
