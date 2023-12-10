(function_declaration
  body: (statement_block)) @function.outer

(function
  body: (statement_block)) @function.outer

(function_declaration
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(function
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(export_statement
  (function_declaration) @function.outer) @function.outer.start

(arrow_function
  body: (_) @function.inner) @function.outer

(arrow_function
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(method_definition
  body: (statement_block)) @function.outer

(method_definition
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "function.inner" @_start @_end)))

(class_declaration
  body: (class_body) @class.inner) @class.outer

(export_statement
  (class_declaration) @class.outer) @class.outer.start

(for_in_statement
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(for_statement
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(while_statement
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(do_statement
  body: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "loop.inner" @_start @_end))) @loop.outer

(if_statement
  consequence: (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "conditional.inner" @_start @_end))) @conditional.outer

(if_statement
  alternative: (else_clause (statement_block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "conditional.inner" @_start @_end)))) @conditional.outer

(if_statement) @conditional.outer

(switch_statement
  body: (_)? @conditional.inner) @conditional.outer

(call_expression) @call.outer
(call_expression
  arguments: (arguments . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

;; blocks
(_ (statement_block) @block.inner) @block.outer

;; parameters
; function ({ x }) ...
; function ([ x ]) ...
; function (v = default_value)
(formal_parameters
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(formal_parameters
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

; If the array/object pattern is the first parameter, treat its elements as the argument list
(formal_parameters
  . (_
    [(object_pattern "," @_start .  (_) @parameter.inner)
    (array_pattern "," @_start .  (_) @parameter.inner)]
    )
 (#make-range! "parameter.outer" @_start @parameter.inner))
(formal_parameters
  . (_
    [(object_pattern . (_) @parameter.inner . ","? @_end)
    (array_pattern . (_) @parameter.inner . ","? @_end)]
    )
 (#make-range! "parameter.outer" @parameter.inner @_end))


;; arguments
(arguments
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(arguments
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

;; comment
(comment) @comment.outer

;; regex
(regex (regex_pattern) @regex.inner) @regex.outer

;; number
(number) @number.inner

(variable_declarator
 name: (_) @assignment.lhs
 value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(variable_declarator
 name: (_) @assignment.inner)

(object
  (pair
    key: (_) @assignment.lhs
    value: (_) @assignment.inner @assignment.rhs) @assignment.outer)
