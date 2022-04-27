; inherits: (jsx)
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
  . body: (_) @function.inner) @function.outer

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
  body: (_)? @loop.inner) @loop.outer

(while_statement
  body: (_)? @loop.inner) @loop.outer

(do_statement
  body: (_)? @loop.inner) @loop.outer

(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner) @conditional.outer

(switch_statement
  body: (_)? @conditional.inner) @conditional.outer

(call_expression) @call.outer
(call_expression (arguments) @call.inner)

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
