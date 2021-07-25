; Blocks
((compound_expression
  . (_)? @_start
  (_) @_end .)
(#make-range! "block.inner" @_start @_end)) @block.outer
((let_statement
  . (_)? @_start
  (_) @_end .)
(#make-range! "block.inner" @_start @_end)) @block.outer

; Calls
(call_expression
  (argument_list) @call.inner) @call.outer

; Objects (class)
((struct_definition
  name: (_)
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "class.inner" @_start @_end)) @class.outer

((struct_definition
  name: (_) type_parameters: (_)
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "class.inner" @_start @_end)) @class.outer

; Comments
[(comment) (triple_string)]@comment.outer

; Conditionals
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

; Functions
(assignment_expression 
  (call_expression (_)) 
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

((function_definition
  name: (_) parameters: (_)
  . (_)? @_start
  (_) @_end .
  "end"
)(#make-range! "function.inner" @_start @_end)) @function.outer

; Loops
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

; Parameters
((subscript_expression
    "," @_start . 
    (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 

((subscript_expression
    . (_) @parameter.inner 
    . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

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
