;; Blocks
((compound_statement
  . (_)? @_start
  (_) @_end .)
(#make-range! "block.inner" @_start @_end)) @block.outer

((quote_statement
  . (_)? @_start
  (_) @_end .)
(#make-range! "block.inner" @_start @_end)) @block.outer

((let_statement
  . (_)? @_start
  (_) @_end .)
(#make-range! "block.inner" @_start @_end)) @block.outer

;; Conditionals
((if_statement condition: (_)
    . (_)? @_start
    .
    (_) @_end .
    ["end" (elseif_clause) (else_clause)])
(#make-range! "conditional.inner" @_start @_end)) @conditional.outer
((elseif_clause condition: (_)
  . (_)? @_start
  (_) @_end .)
(#make-range! "conditional.inner" @_start @_end))
((else_clause
  . (_)? @_start
  (_) @_end .)
(#make-range! "conditional.inner" @_start @_end))

;; Loops
(for_statement
 . (_)? @_start
 (_) @_end .
 (#make-range! "loop.inner" @_start @_end)
  "end") @loop.outer
(while_statement
 . (_)? @_start
 (_) @_end .
 (#make-range! "loop.inner" @_start @_end)
  "end") @loop.outer

;; Type definitions
((struct_definition
  name: (_)
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "class.inner" @_start @_end)) @class.outer

((struct_definition
  name: (_)
  (type_parameter_list)*
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "class.inner" @_start @_end)) @class.outer


;; Function definitions
((function_definition
  name: (_) parameters: (_)
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "function.inner" @_start @_end)) @function.outer

(short_function_definition
  name: (_) parameters: (_)
  (_) @function.inner) @function.outer

(function_expression 
  [ (identifier) (parameter_list) ] 
  "->"
  (_) @function.inner) @function.outer

((macro_definition
  name: (_) parameters: (_)
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "function.inner" @_start @_end)) @function.outer

;; Calls
(call_expression) @call.outer
(call_expression
  (argument_list . "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "call.inner" @_start @_end)))

;; Parameters
((vector_expression
    "," @_start . 
    (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 

((argument_list
    "," @_start .
    (_) @parameter.inner)
(#make-range! "parameter.outer" @_start @parameter.inner))

((argument_list
    (_) @parameter.inner
    . "," @_end)
(#make-range! "parameter.outer" @parameter.inner @_end))

((parameter_list
    "," @_start .
    (_) @parameter.inner)
(#make-range! "parameter.outer" @_start @parameter.inner))

((parameter_list
    (_) @parameter.inner
    . [","] @_end)
(#make-range! "parameter.outer" @parameter.inner @_end))

; Comments
[(line_comment) (block_comment)] @comment.outer

; Regex
((prefixed_string_literal
   prefix: (identifier) @_prefix) @regex.inner @regex.outer
 (#eq? @_prefix "r")
 (#offset! @regex.inner 0 2 0 -1))
