; ((struct_expression
;   . "{" @_start "}" @_end .)
;  (#make-range! "class.inner" @_start @_end))

(assignment_statement
  (struct_expression)) @class.outer

; ((union_expression
;   . "{" @_start "}" @_end .)
;  (#make-range! "class.inner" @_start @_end))

(assignment_statement
  (union_expression)) @class.outer

; ((enum_expression
;   . "{" @_start "}" @_end .)
;  (#make-range! "class.inner" @_start @_end))

(assignment_statement
  (enum_expression)) @class.outer

;; functions
(function_declaration
  body: (block) @function.inner) @function.outer

;; loops
(for_expression
  body: (block) @loop.inner) @loop.outer

(while_expression
  body: (block) @loop.inner) @loop.outer

;; blocks
(_ (block) @block.inner) @block.outer

;; parameters
((parameters 
  "," @_start . (parameter) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((parameters
  . (parameter) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

;; arguments
((arguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((arguments 
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

;; comments
(doc_comment) @comment.outer
(line_comment) @comment.outer

;; conditionals
(if_expression
  consequence: (_ (block) @conditional.inner)
  alternative: (block)? @conditional.inner) @conditional.outer

(switch_expression 
  body: (_) @conditional.inner) @conditional.outer

;; calls
(call_expression (arguments) @call.inner) @call.outer
