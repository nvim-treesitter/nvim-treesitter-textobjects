;; assignment
[(short_var_declaration
    left: (_) @assignment.lhs
    right: (_)* @assignment.rhs)
  (assignment_statement
    left: (_) @assignment.lhs
    right: (_)* @assignment.rhs)]

[(short_var_declaration
    left: (_) @assignment.inner)
  (assignment_statement
    left: (_) @assignment.inner)]

[(short_var_declaration
    right: (_) @assignment.inner)
  (assignment_statement
    right: (_) @assignment.inner)]

;; block
(_ (block) @block.inner) @block.outer

;; call
(call_expression) @call.outer
(call_expression
  arguments: (argument_list . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

;; class: structs
(struct_declaration
  (struct_field_declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "class.inner" @_start @_end)))

(struct_declaration) @class.outer

;; comment
((comment) @comment.inner @comment.outer
  (#offset! @comment.inner 0 3 0))

;; conditional
(if_expression
  consequence: (block . "{" . (_) @_start @_end (_)? @_end . "}"
    (#make-range! "conditional.inner" @_start @_end))?) @conditional.outer

;; function
(function_declaration
  body: (block . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(function_declaration) @function.outer

;; loop
(for_statement
  body: (block . "{" . (_) @_start @_end (_)? @_end . "}"
    (#make-range! "loop.inner" @_start @_end))?) @loop.outer

;; parameter
(parameter_list
  "," @_start .
  (parameter_declaration) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))

(parameter_list
  . (parameter_declaration) @parameter.inner
  . ","? " "? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

;; return
(return_statement (_)* @return.inner) @return.outer

;; statements
(block (_) @statement.outer)
