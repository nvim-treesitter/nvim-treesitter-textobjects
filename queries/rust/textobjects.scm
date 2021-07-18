;; functions
(function_item
  (_) @function.inner) @function.outer

;; quantifies as class(es)
(struct_item
  (_) @class.inner) @class.outer

(enum_item
  (_) @class.inner) @class.outer

(union_item
  (_) @class.inner) @class.outer

(trait_item
  (_) @class.inner) @class.outer

(impl_item
  (_) @class.inner) @class.outer

(mod_item
  (_) @class.inner) @class.outer

;; conditionals
(if_expression
  alternative: (_ (_) @conditional.inner)?
  ) @conditional.outer

(if_expression
  alternative: (else_clause (block) @conditional.inner))

(if_expression
  condition: (_) @conditional.inner)

(if_expression
  consequence: (block) @conditional.inner)

(match_arm
  (_)) @conditional.inner

(match_expression) @conditional.outer

(if_let_expression
  consequence: (block)?
  @conditional.inner) @conditional.outer

(if_let_expression
  alternative: (else_clause (block) @conditional.inner))

(if_let_expression
  pattern: (_) @conditional.inner)

;; loops
(loop_expression
  (_)? @loop.inner) @loop.outer

(while_expression
  (_)? @loop.inner) @loop.outer

(while_let_expression
  (_)? @loop.inner) @loop.outer

(for_expression
  body: (block)? @loop.inner) @loop.outer

;; blocks
(_ (block) @block.inner) @block.outer
(unsafe_block (_)? @block.inner) @block.outer

;; calls
(call_expression (_)? @call.inner) @call.outer

;; statements
(block (_) @statement.outer)

;; parameter

((parameters 
  "," @_start . (parameter) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((parameters
  . (parameter) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((type_parameters
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((type_parameters 
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((tuple_pattern
  "," @_start . (identifier) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((tuple_pattern 
  . (identifier) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((tuple_struct_pattern
  "," @_start . (identifier) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((tuple_struct_pattern 
  . (identifier) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((closure_parameters
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((closure_parameters 
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((arguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((arguments 
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((type_arguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((type_arguments 
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

((meta_arguments
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner)) 
((meta_arguments
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end)) 

