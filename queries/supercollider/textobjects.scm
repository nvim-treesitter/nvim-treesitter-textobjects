; assignment
(variable_definition
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

(function_definition
  name: (_) @assignment.lhs
  value: (_) @assignment.inner @assignment.rhs) @assignment.outer

; block
(code_block
  (_)* @block.inner) @block.outer

; class
(class_def
  (class_def_body) @class.inner) @class.outer

; call
(function_call
  arguments: (_
    .
    "("
    _+ @call.inner
    ")")?) @call.outer

; comment
(line_comment) @comment.outer

(block_comment) @comment.outer

; conditional:
(function_call
  name: (_) @_name
  (#eq? @_name "if")
  arguments: (parameter_call_list
    (_) @conditional.inner)?) @conditional.outer

; function
((function_block) @function.inner @function.outer
  (#offset! @function.inner 0 1 0 -1)) ; use offset to skip brackets

; loop
(function_call
  name: (identifier) @_fname
  (#eq? @_fname "while")
  arguments: (parameter_call_list
    (_) @loop.inner)?) @loop.outer

(function_call
  name: (identifier) @_fname
  (#eq? @_fname "for")
  arguments: (parameter_call_list
    (_) @loop.inner .)?) @loop.outer

(function_call
  name: (identifier) @_fname
  (#eq? @_fname "forBy")
  arguments: (parameter_call_list
    (_) @loop.inner .)?) @loop.outer

; number
(number) @number.inner

;parameters
(parameter_call_list
  (_) @parameter.inner @parameter.outer
  .
  (",")? @parameter.outer)

(parameter_call_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(parameter_list
  (_) @parameter.inner @parameter.outer
  .
  (",")? @parameter.outer)

(parameter_list
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

(collection
  (_) @parameter.inner @parameter.outer
  .
  (",")? @parameter.outer)

(collection
  "," @parameter.outer
  .
  (_) @parameter.inner @parameter.outer .)

; return
(return_statement
  (_) @return.inner) @return.outer
