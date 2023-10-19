(class_declaration 
  body: (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(struct_declaration
  body: (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "class.inner" @_start @_end))) @class.outer

(method_declaration
  body: (block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "function.inner" @_start @_end))) @function.outer

(constructor_declaration
  body: (block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "function.inner" @_start @_end))) @function.outer

(lambda_expression 
  body: (block . "{" . (_) @_start @_end (_)? @_end . "}"
  (#make-range! "function.inner" @_start @_end))) @function.outer

;; loops
(for_statement
  body: (_) @loop.inner) @loop.outer

(for_each_statement
  body: (_) @loop.inner) @loop.outer

(do_statement
  (block) @loop.inner) @loop.outer

(while_statement
  (block) @loop.inner) @loop.outer

;; conditionals
(if_statement
  consequence: (_)? @conditional.inner
  alternative: (_)? @conditional.inner) @conditional.outer

(switch_statement
  body: (switch_body) @conditional.inner) @conditional.outer

;; calls
(invocation_expression) @call.outer
(invocation_expression
  arguments: (argument_list . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

;; blocks
(_ (block) @block.inner) @block.outer

;; parameters
((parameter_list
  "," @_start . (parameter) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 

((parameter_list
  . (parameter) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((argument_list
  "," @_start . (argument) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 

((argument_list
  . (argument) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

;; comments
(comment) @comment.outer
