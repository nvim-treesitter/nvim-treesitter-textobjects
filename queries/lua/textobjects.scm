; block

(_ (block) @block.inner) @block.outer

; call

(function_call) @call.outer

(function_call
  (arguments) @call.inner
  (#match? @call.inner "^[^\\(]"))

(function_call
  arguments: (arguments . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

; class

; comment

(comment) @comment.outer

; conditional

(if_statement
  alternative: (_ (_) @conditional.inner)?) @conditional.outer

(if_statement
  consequence: (block)? @conditional.inner)

(if_statement
  condition: (_) @conditional.inner)

; frame

; function

[
  (function_declaration)
  (function_definition)
] @function.outer

(function_declaration body: (_) @function.inner)

(function_definition body: (_) @function.inner)

; return

(return_statement
  (_)? @return.inner) @return.outer

; loop

[
  (while_statement)
  (for_statement)
  (repeat_statement)
] @loop.outer

(while_statement body: (_) @loop.inner)

(for_statement body: (_) @loop.inner)

(repeat_statement body: (_) @loop.inner)

; parameter

(arguments
  . (_) @parameter.inner
  . ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(parameters
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

(table_constructor
  (field) @parameter.inner
  ","? @_end
  (#make-range! "parameter.outer" @parameter.inner @_end))

(arguments
  "," @_start
  . (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))

(parameters
  "," @_start
  . (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))

; number
(number) @number.inner

(assignment_statement
 (variable_list) @assignment.lhs
 (expression_list) @assignment.inner @assignment.rhs) @assignment.outer

(assignment_statement
 (variable_list) @assignment.inner)

; scopename

; statement
