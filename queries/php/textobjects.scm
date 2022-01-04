(function_definition 
 body: (compound_statement) @function.inner) @function.outer

(method_declaration
  body: (compound_statement) @function.inner) @function.outer

(class_declaration
  body: (declaration_list) @class.inner) @class.outer

(foreach_statement
  body: (_)? @loop.inner) @loop.outer

(while_statement
  body: (_)? @loop.inner) @loop.outer

(do_statement
  body: (_)? @loop.inner) @loop.outer

(switch_statement
  body: (_)? @conditional.inner) @conditional.outer

;;blocks
(_ (switch_block) @block.inner) @block.outer

;; parameters
(arguments
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(arguments
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))

(formal_parameters
  "," @_start .
  (_) @parameter.inner
 (#make-range! "parameter.outer" @_start @parameter.inner))
(formal_parameters
  . (_) @parameter.inner
  . ","? @_end
 (#make-range! "parameter.outer" @parameter.inner @_end))
